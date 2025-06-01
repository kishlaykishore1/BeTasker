//
//  TeamUsersListVC.swift
//  BeTasker
//
//  Created by B2Cvertical A++ on 20/01/25.
//

import UIKit
import SDWebImage
import IQKeyboardManagerSwift

protocol PrTeamMember: AnyObject {
    func setSelectedMembers(arrMembers: [MembersDataViewModel])
}

class TeamUsersListVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var vwSearch: UIView!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var viewEmpty: UIControl!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var tblUsers: UITableView!
    
    // MARK: - Variables
    let refreshControl = UIRefreshControl()
    var arrMembers = [MembersDataViewModel]()
    var arrMembersFromBackScreen = [MembersDataViewModel]()
    var filteredarrMembers = [MembersDataViewModel]()
    var requestStatus = false
    var page: Int = 1
    var limit: Int = 10000
    var isPresented = false
    weak var delegate: PrTeamMember?
    var arrExcludedMembers = [MembersDataViewModel]()
    var isFromFilter = false
    var isFromWorkSpaceScreen = false
    var workspaceId: Int?
    var selecetedWorkspace: WorkSpaceDataViewModel?
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        arrMembersFromBackScreen = arrMembers
        DispatchQueue.main.async {
            self.btnDone.applyShadow(radius: 3, opacity: 0.1, offset: CGSize(width: 0.0, height: 3.0))
            self.btnDone.layer.cornerRadius = self.btnDone.frame.height / 2
            self.vwSearch.applyShadow(radius: 8, opacity: 0.1, offset: CGSize(width: 0.0, height: 4.0))
        }
        
        refreshControl.addTarget(self, action: #selector(RefreshList), for: .valueChanged)
        tblUsers.addSubview(refreshControl)
        NotificationCenter.default.addObserver(self, selector: #selector(RefreshList), name: .updateMembersList, object: nil)
        txtSearch.delegate  = self
        txtSearch.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        if isFromWorkSpaceScreen {
            getMembers(shouldShowLoader: true)
        } else {
            getWorkspaceMembers(shouldShowLoader: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        setBackButton(isImage: true)
        if !isFromFilter {
            setRightButton(isImage: true, image: UIImage(named: "plus") ?? UIImage(), inset: UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2))
        }
        self.setNavigationBarImage(for: nil, color: UIColor.colorFFFFFF000000, txtcolor: UIColor.color191919, requireShadowLine: true, isTans: true)
        self.title = "Sélectionnez vos contacts".localized
    }
    
    override func backBtnTapAction() {
        Global.setVibration()
        self.dismiss(animated: true)
    }
    
    override func rightBtnTapAction(sender: UIButton) {
        btnInviteTapAction(sender)
    }
    
    // MARK: - Helper Methods
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        self.filterDataBasedOnText(searchText: textField.text ?? "")
    }
    
    func filterDataBasedOnText(searchText:String) {
        self.filteredarrMembers.removeAll()
        if searchText.count != 0 {
            self.filteredarrMembers = self.searchMembers(by: searchText.lowercased(), in: arrMembers)
        } else {
            self.filteredarrMembers = self.arrMembers
        }
        self.viewEmpty.isHidden = self.filteredarrMembers.count > 0
        self.tblUsers.reloadData()
    }
    
    func searchMembers(by searchText: String, in members: [MembersDataViewModel]) -> [MembersDataViewModel] {
        let options: NSString.CompareOptions = [.caseInsensitive, .diacriticInsensitive]
        
        return members.filter { member in
            return member.fullNameFormatted.range(of: searchText, options: options) != nil || "\(member.memberUserId)".range(of: searchText, options: options) != nil
        }
    }
    
    // MARK: - Button Action Methods
    @IBAction func emptyViewBtnTapped(_ sender: UIButton) {
        self.btnInviteTapAction(sender)
    }
    
    @IBAction func btnInviteTapAction(_ sender: Any) {
        Global.setVibration()
        let vc = Constants.Profile.instantiateViewController(withIdentifier: "AddGroupMemberVC") as! AddGroupMemberVC
        vc.delegate = self
        vc.currentSelectedWorkspace = self.selecetedWorkspace
        vc.isfromWorkspace = self.isFromWorkSpaceScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func searchTextChanged(_ sender: UITextField) {
        
    }
    
    @IBAction func doneAction(_ sender: Any) {
        Global.setVibration()
        let selectedUsers = filteredarrMembers.filter({ $0.isSelected })
        guard selectedUsers.count > 0 else {
            Common.showAlertMessage(message: "Please select atleast one user.", alertType: .error, isPreferLightStyle: false)
            return
        }
        self.delegate?.setSelectedMembers(arrMembers: selectedUsers)
        self.dismiss(animated: true)
    }
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension TeamUsersListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredarrMembers.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TeamUsersCell", for: indexPath) as! TeamUsersCell
        cell.selectionStyle = .none
        if filteredarrMembers.count > indexPath.row {
            
            cell.vwBottomline.isHidden = indexPath.row >= 0
            if isLastRow(indexPath: indexPath, tableView: tableView) {
                cell.vwBottomline.isHidden = false
            }
            
            let data = filteredarrMembers[indexPath.row]
            cell.lblName.text = data.fullNameFormatted
            cell.lblTag.text = data.randomId.withHash
            cell.imgCheck.isHighlighted = data.isSelected
            cell.imgUser.sd_imageIndicator = SDWebImageActivityIndicator.white
            cell.imgUser.sd_imageTransition = SDWebImageTransition.fade
            let img = #imageLiteral(resourceName: "profile")
            cell.imgUser.sd_setImage(with: data.profilePicURL, placeholderImage: img)
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Global.setVibration()
        filteredarrMembers[indexPath.row].isSelected = !filteredarrMembers[indexPath.row].isSelected
        for i in 0..<self.filteredarrMembers.count {
            if let idx = self.arrMembers.firstIndex(where: {$0.id == self.filteredarrMembers[i].id}) {
                self.arrMembers[idx].isSelected = !self.arrMembers[idx].isSelected
            }
        }
        tableView.reloadData()
    }
}
// MARK: - TextField Delegate Methods
extension TeamUsersListVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        IQKeyboardManager.shared.enableAutoToolbar = true
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
}
extension TeamUsersListVC: PrClose {
    func closedDelegateAction() {
        RefreshList()
    }
}

// MARK: - Api methods
extension TeamUsersListVC {
    @objc func RefreshList(isFromAddMember: Bool = false) {
        if isFromWorkSpaceScreen {
            getMembers(shouldShowLoader: false)
        } else {
            getWorkspaceMembers(shouldShowLoader: false)
        }
        
    }
    
    func getMembers(shouldShowLoader: Bool) {
        MembersViewModel.GetMembersList(groupId: 0, page: page, limit: limit, sender: self, shouldShowLoader: shouldShowLoader) { [weak self] arrMembers in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.refreshControl.endRefreshing()
                var arr = arrMembers
                
                for i in 0..<self.arrMembersFromBackScreen.count {
                    if let idx = arr.firstIndex(where: {$0.id == self.arrMembersFromBackScreen[i].id}) {
                        arr[idx].isSelected = true
                    }
                }
                
                if self.arrExcludedMembers.count > 0 {
                    for i in 0..<self.arrExcludedMembers.count {
                        if let idx = arr.firstIndex(where: {$0.memberUserId == self.arrExcludedMembers[i].memberUserId}) {
                            arr.remove(at: idx)
                        }
                    }
                }
                self.arrMembers = arr
                self.filterDataBasedOnText(searchText: self.txtSearch.text ?? "")
                //self.viewEmpty.isHidden = self.filteredarrMembers.count > 0
                self.tblUsers.reloadData()
                NotificationCenter.default.post(name: .groupMembersNotification, object: arrMembers)
            }
        }
    }
    
    func getWorkspaceMembers(shouldShowLoader: Bool) {
        MembersViewModel.GetWorkSpaceMembersList(workSpaceId: workspaceId ?? 0, page: page, limit: limit, sender: self, shouldShowLoader: shouldShowLoader) { [weak self] arrMembers in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.refreshControl.endRefreshing()
                var arr = arrMembers
                
                for i in 0..<self.arrMembersFromBackScreen.count {
                    if let idx = arr.firstIndex(where: {$0.id == self.arrMembersFromBackScreen[i].id}) {
                        arr[idx].isSelected = true
                    }
                }
                
                if  self.arrExcludedMembers.count > 0 {
                    for i in 0..<self.arrExcludedMembers.count {
                        if let idx = arr.firstIndex(where: {$0.memberUserId == self.arrExcludedMembers[i].memberUserId}) {
                            arr.remove(at: idx)
                        }
                    }
                }
                self.arrMembers = arr
                self.filterDataBasedOnText(searchText: self.txtSearch.text ?? "")
                self.tblUsers.reloadData()
                NotificationCenter.default.post(name: .groupMembersNotification, object: arrMembers)
            }
        }
    }
    
    func resendInvitation(id: Int) {
        let params: [String: Any] = [
            "lc": Constants.lc,
            "invite_id": id,
            "group_id": 0
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

// MARK: - Table View Cell Class
class TeamUsersCell: UITableViewCell {
    @IBOutlet weak var vwTopline: UIView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblTag: UILabel!
    @IBOutlet weak var imgCheck: UIImageView!
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var vwBottomline: UIView!
}
