//
//  MyContactsListVC.swift
//  BeTasker
//
//  Created by kishlay kishore on 06/03/25.
//

import UIKit
import SDWebImage

class MyContactsListVC: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var viewEmpty: UIView!
    
    // MARK: - Properties
    let refreshControl = UIRefreshControl()
    var arrMembers = [MembersDataViewModel]()
    var groupId: Int?
    var canManageMembers = false
    var requestStatus = false
    var page: Int = 1
    var limit: Int = 10000
    var isPresented = false
    
    // MARK: - View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewEmpty.isHidden = true
        tblView.delegate = self
        tblView.dataSource = self
        
        setBackButton(isImage: true)
        setRightButton(isImage: true, image: #imageLiteral(resourceName: "add-user-org"))
        
        refreshControl.addTarget(self, action: #selector(RefreshList), for: .valueChanged)
        tblView.addSubview(refreshControl)
        
        NotificationCenter.default.addObserver(self, selector: #selector(RefreshList), name: .updateMembersList, object: nil)
        
        GetMembers(shouldShowLoader: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.title = "Mes contacts".localized
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.color191919 as Any,
            .font: UIFont(name: Constants.KGraphikMedium, size: 14)!
        ]
        let attributes2: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.color191919 as Any,
            .font: UIFont(name: Constants.KGraphikMedium, size: 33)!
        ]
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        self.navigationController?.navigationBar.largeTitleTextAttributes = attributes2
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func backBtnTapAction() {
        Global.setVibration()
        self.navigationController?.backToViewController(vc: ProfileVC.self)
    }
    
    override func rightBtnTapAction(sender: UIButton) {
        btnInviteTapAction(sender)
    }
    
    // MARK: - Button Action Method
    @IBAction func showTable(_ sender: UIControl) {
        btnInviteTapAction(sender)
    }
    
    func btnMoreTapaction(member: MembersDataViewModel, sender: UIButton, idx: Int) {
        Global.setVibration()
        
        let alert = UIAlertController(title: "\(member.fullNameFormatted)", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Supprimer le contact".localized, style: .destructive, handler: { _ in
            Global.setVibration()
            let alert  = UIAlertController(title: "Supprimer le contact".localized, message: "Êtes-vous sûr de vouloir supprimer ce contact ?".localized, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: Messages.txtDeleteConfirm, style: .destructive, handler: { _ in
                MembersViewModel.DeleteMember(sender: self, id: member.id, groupId: 0) { isDone in
                    DispatchQueue.main.async {
                        if isDone {
                            self.arrMembers.remove(at: idx)
                            self.viewEmpty.isHidden = self.arrMembers.count > 0
                            self.tblView.reloadData()
                            NotificationCenter.default.post(name: .updateMembersList, object: nil)
                        }
                    }
                }
            }))
            alert.addAction(UIAlertAction(title: Messages.txtCancel, style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction.init(title: Messages.txtCancel, style: .cancel, handler: nil))
        alert.popoverPresentationController?.sourceView = sender
        alert.popoverPresentationController?.sourceRect = sender.bounds
        alert.popoverPresentationController?.permittedArrowDirections = .up
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func btnInviteTapAction(_ sender: Any) {
        Global.setVibration()
        if PremiumManager.shared.canAddNewUsers(memberCount: arrMembers.count) {
            let vc = Constants.Profile.instantiateViewController(withIdentifier: "AddGroupMemberVC") as! AddGroupMemberVC
            vc.delegate = self
            self.present(vc, animated: true, completion: nil)
        } else {
            PremiumManager.shared.openPremiumScreen()
        }
    }
}

extension MyContactsListVC: PrClose {
    func closedDelegateAction() {
        RefreshList()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension MyContactsListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrMembers.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MembersTblViewCell", for: indexPath) as! MembersTblViewCell
        cell.selectionStyle = .none
        if arrMembers.count > indexPath.row {
            let data = arrMembers[indexPath.row]
            cell.lblName.text = data.fullNameFormatted
            cell.lblEmail.text = data.randomId.withHash
            cell.imgProfile.sd_imageIndicator = SDWebImageActivityIndicator.white
            cell.imgProfile.sd_imageTransition = SDWebImageTransition.fade
            let img = #imageLiteral(resourceName: "profile")
            cell.imgProfile.sd_setImage(with: data.profilePicURL, placeholderImage: img)
            cell.moreMenuClosure = {[weak self] sender in
                self?.btnMoreTapaction(member: data, sender: sender, idx: indexPath.row)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Global.setVibration()
    }
}

extension MyContactsListVC {
    
    @objc func RefreshList() {
        GetMembers(shouldShowLoader: false)
    }
    
    func GetMembers(shouldShowLoader: Bool) {
        MembersViewModel.GetMembersList(groupId: groupId ?? 0, page: page, limit: limit, sender: self, shouldShowLoader: shouldShowLoader) { arrMembers in
            DispatchQueue.main.async {
                let members = arrMembers.filter { !$0.isMe }
                self.refreshControl.endRefreshing()
                self.arrMembers = members
                self.viewEmpty.isHidden = members.count > 0
                self.tblView.reloadData()
                NotificationCenter.default.post(name: .groupMembersNotification, object: members)
            }
        }
    }
    
    func resendInvitation(id: Int) {
        let params: [String: Any] = [
            "lc": Constants.lc,
            "invite_id": id,
            "group_id": self.groupId ?? 0
        ]
        Global.showLoadingSpinner(sender: self.view)
        HpAPI.resendInvitation.DataAPI(params: params, shouldShowError: true, shouldShowSuccess: true, key: nil) { (response: Result<GeneralModel, Error>) in
            DispatchQueue.main.async {
                Global.dismissLoadingSpinner(self.view)
                self.RefreshList()
                switch response {
                case .success(_):
                    break
                case .failure(_):
                    break
                }
            }
        }
    }
    
}
