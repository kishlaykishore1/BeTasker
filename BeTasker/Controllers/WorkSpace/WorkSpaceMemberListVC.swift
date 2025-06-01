//
//  WorkSpaceMemberListVC.swift
//  teamAlerts
//
//  Created by MAC on 29/01/25.
//

import UIKit
import SDWebImage

class WorkSpaceMemberListVC: UIViewController {
    
    //MARK: IBOutlets
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var viewEmpty: UIView!
    
    //MARK: Properties
    let refreshControl = UIRefreshControl()
    var currentWorkSpace: WorkSpaceDataViewModel?
    var arrMembers = [MembersDataViewModel]()
    var workSpaceId: Int?
    var canManageMembers = false
    var requestStatus = false
    var page: Int = 1
    var limit: Int = 10000
    var isPresented = false
    
    var arrAdminUsers:[MembersDataViewModel] = [MembersDataViewModel]()
    var arrMemberUsers:[MembersDataViewModel] = [MembersDataViewModel]()
    var isEdited = false
    weak var delegate: PrClose?
    var selectedAdminUserType = false
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        viewEmpty.isHidden = true
        if let currentWorkSpace {
            self.title = "Membres".localized + " " + currentWorkSpace.workSpaceName
        } else {
            self.title = "Membres Workspace 1".localized
        }
        tblView.delegate = self
        tblView.dataSource = self
        
        refreshControl.addTarget(self, action: #selector(RefreshList), for: .valueChanged)
        tblView.addSubview(refreshControl)
        
        NotificationCenter.default.addObserver(self, selector: #selector(RefreshList), name: .updateMembersList, object: nil)
        
        GetMembers(shouldShowLoader: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Graphik-Medium", size: 30)!,NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.1490196078, green: 0.1490196078, blue: 0.1490196078, alpha: 1)]
        setBackButton(isImage: true)
        if currentWorkSpace?.isAdmin ?? false {
            setRightButton(isImage: true, image: #imageLiteral(resourceName: "add-user-org"))
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func backBtnTapAction() {
        Global.setVibration()
        if isEdited {
            if let currentWorkSpace {
                let selectedMemberUsers = arrMemberUsers.map({"\($0.id)"}).joined(separator: ",")
                let selectedAdminUsers = arrAdminUsers.map({"\($0.id)"}).joined(separator: ",")
                self.WorkSpaceAddUpdate(name: currentWorkSpace.workSpaceName, memberIds: selectedMemberUsers, adminIds: selectedAdminUsers)
            } else {
                closeVC()
            }
        } else{
            closeVC()
        }
    }
    
    func WorkSpaceAddUpdate(name:String,memberIds:String,adminIds:String) {
        var params: [String: Any] = [
            "title": name,
            //"file_name": fileName,
            "administrators_ids": adminIds,
            "member_ids": memberIds,
            "client_secret": Constants.kClientSecret
        ]
        if let workSpaceId {
            params["workspaces_id"] = workSpaceId
        }
        Global.showLoadingSpinner(sender: self.view)
        HpAPI.workSpaceCreateUpdate.DataAPI(params: params, shouldShowError: true, shouldShowSuccess: true, key: nil) { (response: Result<GeneralModel, Error>) in
            DispatchQueue.main.async {
                Global.dismissLoadingSpinner(self.view)
                switch response {
                case .success(_):
                    self.delegate?.closedDelegateAction()
                    self.closeVC()
                    break
                case .failure(_):
                    print("workSpaceCreateUpdate api failed")
                    break
                }
            }
        }
    }
    
    func closeVC() {
        if isPresented {
            self.dismiss(animated: true)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func rightBtnTapAction(sender: UIButton) {
        btnAddMemberAction()
    }
    
    @IBAction func showTable(_ sender: UIControl) {
        btnAddMemberAction()
    }
    
    func btnMoreTapaction(member: MembersDataViewModel, isMe: Bool, memberType: String, sender: UIButton, idx: Int) {
        Global.setVibration()
        
        let alert = UIAlertController(title: "\(member.fullNameFormatted)", message: nil, preferredStyle: .actionSheet)
        
        if let workspace = currentWorkSpace {
            if workspace.isAdmin || workspace.isWorkspaceCreator {
                let changeMemberTypeAction = UIAlertAction(title: memberType == "Administrateur".localized ? "Passer Membre".localized : "Passer Admin".localized, style: .default, handler: { _ in
                    if memberType == "Administrateur".localized {
                        self.showGrantMemberRoleConfirmation(member: member)
                    } else {
                        self.showGrantAdminConfirmation(member: member)
                    }
                })
                alert.addAction(changeMemberTypeAction)
            }
        }
        
        let deleteAction = UIAlertAction(title: isMe ? "Me retirer".localized : "Retirer l’utilisateur".localized, style: .destructive, handler: { _ in
            self.showDeleteWorkSpaceConfirmation(member: member, sender: sender, idx: idx)
        })
        alert.addAction(deleteAction)
        
        alert.addAction(UIAlertAction.init(title: Messages.txtCancel, style: .cancel, handler: nil))
        alert.popoverPresentationController?.sourceView = sender
        alert.popoverPresentationController?.sourceRect = sender.bounds
        alert.popoverPresentationController?.permittedArrowDirections = .up
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    func showGrantAdminConfirmation(member: MembersDataViewModel) {
        DispatchQueue.main.async {
            let alert  = UIAlertController(title: "Confirmer l’action".localized, message: "Êtes-vous certain de vouloir modifier le rôle de cet utilisateur en Administrateur ? Attention ! Il aura désormais les mêmes accès que vous.".localized, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: Messages.txtDeleteConfirm, style: .default, handler: { _ in
                self.changeUserTypeOnClick(member: member)
            }))
            alert.addAction(UIAlertAction(title: Messages.txtCancel, style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func showGrantMemberRoleConfirmation(member: MembersDataViewModel) {
        DispatchQueue.main.async {
            let alert  = UIAlertController(title: "Confirmer l’action".localized, message: "Êtes-vous certain de vouloir modifier les accès de cet utilisateur ?".localized, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: Messages.txtDeleteConfirm, style: .default, handler: { _ in
                self.changeUserTypeOnClick(member: member)
            }))
            alert.addAction(UIAlertAction(title: Messages.txtCancel, style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func showDeleteWorkSpaceConfirmation(member: MembersDataViewModel, sender: UIButton, idx: Int) {
        Global.setVibration()
        let alert  = UIAlertController(title: "Supprimer de l'espace de travail".localized, message: "Êtes-vous sûr de vouloir supprimer de l'espace de travail ?".localized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Messages.txtDeleteConfirm, style: .destructive, handler: { _ in
            
            self.arrMembers.remove(at: idx)
            self.arrAdminUsers = self.arrMembers.filter{
                $0.type == "Administrateur".localized
            }
            self.arrMemberUsers = self.arrMembers.filter{
                $0.type != "Administrateur".localized
            }
            self.viewEmpty.isHidden = self.arrMembers.count > 0
            self.isEdited = true
            self.tblView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: Messages.txtCancel, style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func changeUserTypeOnClick(member: MembersDataViewModel) {
        Global.setVibration()
        let selectedMemberID = member.id
        let isAdmin = member.type == "Administrateur".localized
        
        if isAdmin {
            arrAdminUsers.removeAll { $0.id == selectedMemberID }
            if !arrMemberUsers.contains(where: { $0.id == selectedMemberID }) {
                arrMemberUsers.append(member)
            }
        } else {
            arrMemberUsers.removeAll { $0.id == selectedMemberID }
            if !arrAdminUsers.contains(where: { $0.id == selectedMemberID }) {
                arrAdminUsers.append(member)
            }
        }
        
        let selectedMemberUsers = arrMemberUsers.map {"\($0.id)"}.joined(separator: ",")
        let selectedAdminUsers = arrAdminUsers.map {"\($0.id)"}.joined(separator: ",")
        self.WorkSpaceAddUpdate(name: currentWorkSpace?.workSpaceName ?? "", memberIds: selectedMemberUsers, adminIds: selectedAdminUsers)
    }

    
    @IBAction func btnAddMemberAction() {
        Global.setVibration()
        let alert = UIAlertController(title: "Sélectionnez le type de membre".localized, message: nil, preferredStyle: .actionSheet)
        
        
        let adminAction = UIAlertAction(title: "Administrateur".localized, style: .default, handler: { _ in
            self.selectedAdminUserType = true
            self.addMemberAction()
            
        })
        alert.addAction(adminAction)
        let memberAction = UIAlertAction(title: "Membre".localized, style: .default, handler: { _ in
            self.selectedAdminUserType = false
            self.addMemberAction()
            
        })
        alert.addAction(memberAction)
        
        alert.addAction(UIAlertAction.init(title: Messages.txtCancel, style: .cancel, handler: nil))
        alert.popoverPresentationController?.permittedArrowDirections = .up
        self.present(alert, animated: true, completion: nil)
    }
    
    func addMemberAction() {
        let vc = Constants.Home.instantiateViewController(withIdentifier: "TeamUsersListVC") as! TeamUsersListVC
        vc.arrMembers = self.arrMembers
        vc.arrExcludedMembers = self.arrMembers
        vc.isFromWorkSpaceScreen = true
        vc.delegate = self
        let nvc = UINavigationController(rootViewController: vc)
        nvc.isModalInPresentation = true
        self.present(nvc, animated: true, completion: nil)
    }
}

extension WorkSpaceMemberListVC: PrClose {
    func closedDelegateAction() {
        RefreshList()
    }
}
extension WorkSpaceMemberListVC: PrTeamMember {
    func setSelectedMembers(arrMembers: [MembersDataViewModel]) {
        
        var newArrMembers = arrMembers
        
        for i in 0..<newArrMembers.count {
            if self.selectedAdminUserType {
                newArrMembers[i].type = "Administrateur".localized
            } else {
                newArrMembers[i].type = "Membre".localized
            }
        }
        self.arrMembers  = self.arrMembers +  newArrMembers
        self.arrAdminUsers = self.arrMembers.filter{
            $0.type == "Administrateur".localized
        }
        self.arrMemberUsers = self.arrMembers.filter{
            $0.type != "Administrateur".localized
        }
        self.isEdited = true
        self.tblView.reloadData()
    }
}
//MARK: UITableViewDelegate, UITableViewDataSource
extension WorkSpaceMemberListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrMembers.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MembersTblViewCell", for: indexPath) as! MembersTblViewCell
        cell.selectionStyle = .none
        if arrMembers.count > indexPath.row {
            let data = arrMembers[indexPath.row]
            cell.lblName.text = data.fullNameFormatted
            cell.lblEmail.text = data.randomId.withHash + " • " + data.type
            cell.imgProfile.sd_imageIndicator = SDWebImageActivityIndicator.white
            cell.imgProfile.sd_imageTransition = SDWebImageTransition.fade
            let img = #imageLiteral(resourceName: "profile")
            cell.imgProfile.sd_setImage(with: data.profilePicURL, placeholderImage: img)
            cell.btnMenu.isHidden = data.memberUserId == currentWorkSpace?.userId
            cell.moreMenuClosure = { [weak self] sender in
                let loginUserId = HpGlobal.shared.userInfo?.userId
                self?.btnMoreTapaction(member: data, isMe: data.memberUserId == loginUserId, memberType: data.type, sender: sender, idx: indexPath.row)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Global.setVibration()
    }
}

extension WorkSpaceMemberListVC {
    @objc func RefreshList() {
        GetMembers(shouldShowLoader: false)
    }
    func GetMembers(shouldShowLoader: Bool) {
        MembersViewModel.GetWorkSpaceMembersList(workSpaceId: workSpaceId ?? 0, page: page, limit: limit, sender: self, shouldShowLoader: shouldShowLoader) { arrMembers in
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
                self.arrAdminUsers.removeAll()
                self.arrMemberUsers.removeAll()
                self.arrMembers = arrMembers
                self.viewEmpty.isHidden = arrMembers.count > 0
                
                self.arrAdminUsers = arrMembers.filter{
                    $0.type == "Administrateur".localized
                }
                self.arrMemberUsers = arrMembers.filter{
                    $0.type != "Administrateur".localized
                }
                
                self.tblView.reloadData()
            }
        }
    }
    
    
}

