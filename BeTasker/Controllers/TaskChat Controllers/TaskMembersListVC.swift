//
//  TaskMembersListVC.swift
//  BeTasker
//
//  Created by kishlay kishore on 02/04/25.
//

import UIKit
import IQKeyboardManagerSwift
import SDWebImage

class TaskMembersListVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var vwSearch: UIView!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var viewEmpty: UIControl!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var tblUsers: UITableView!
    
    // MARK: - Variables
    let refreshControl = UIRefreshControl()
    var arrMembers = [MembersDataViewModel]()
    var filteredarrMembers = [MembersDataViewModel]()
    weak var delegate: PrTeamMember?
    var taskId: Int?
    var taskTitle: String?
    var taskData: TasksViewModel?
    var isTaskAdmin: Bool = false
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.btnDone.applyShadow(radius: 3, opacity: 0.1, offset: CGSize(width: 0.0, height: 3.0))
        self.btnDone.layer.cornerRadius = self.btnDone.frame.height / 2
        self.vwSearch.applyShadow(radius: 8, opacity: 0.1, offset: CGSize(width: 0.0, height: 4.0))
        refreshControl.addTarget(self, action: #selector(RefreshList), for: .valueChanged)
        tblUsers.addSubview(refreshControl)
        NotificationCenter.default.addObserver(self, selector: #selector(RefreshList), name: .updateTaskMembersList, object: nil)
        txtSearch.delegate  = self
        txtSearch.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        getTaskdetails()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        setBackButton(isImage: true)
        if isTaskAdmin {
            setRightButton(isImage: true, image: UIImage(named: "plus") ?? UIImage(), inset: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
        }
        self.setNavigationBarImage(for: nil, color: UIColor.colorFFFFFF000000, txtcolor: UIColor.color191919, requireShadowLine: true, isTans: true)
        self.title = "Destinataires".localized + " \(taskTitle ?? "")".localized
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
    
    func toGetAdminTag(indexId: Int) -> String {
        let adminUser = taskData?.taskAssignerUserId
        return indexId == adminUser ? "Administrateur".localized : "Membre".localized
    }
    
    private func addLabelToImage(image: UIImage, label: UILabel) -> UIImage? {
        let tempView = UIStackView(frame: CGRect(x: 0, y: 0, width: 80, height: 50))
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: image.size.height, height: image.size.height))
        imageView.contentMode = .scaleAspectFit
        tempView.axis = .vertical
        tempView.alignment = .center
        tempView.spacing = 8
        imageView.image = image
        tempView.addArrangedSubview(imageView)
        tempView.addArrangedSubview(label)
        let renderer = UIGraphicsImageRenderer(bounds: tempView.bounds)
        let image = renderer.image { rendererContext in
            tempView.layer.render(in: rendererContext.cgContext)
        }
        return image
    }
    
    // MARK: - Button Action Methods
    @IBAction func emptyViewBtnTapped(_ sender: UIButton) {
        self.btnInviteTapAction(sender)
    }
    
    @IBAction func btnInviteTapAction(_ sender: Any) {
        Global.setVibration()
        let vc = Constants.Home.instantiateViewController(withIdentifier: "TeamUsersListVC") as! TeamUsersListVC
        vc.arrExcludedMembers = self.arrMembers
        vc.delegate = self
        vc.isFromFilter = true
        vc.workspaceId = taskData?.workSpaceId
        let nvc = UINavigationController(rootViewController: vc)
        nvc.isModalInPresentation = true
        self.present(nvc, animated: true, completion: nil)
    }
    
    @IBAction func doneAction(_ sender: Any) {
        Global.setVibration()
        let selectedUsers = filteredarrMembers.filter({ $0.isSelected })
        guard selectedUsers.count > 0 else {
            Common.showAlertMessage(message: "Veuillez sélectionner au moins un utilisateur.".localized, alertType: .error, isPreferLightStyle: false)
            return
        }
        self.delegate?.setSelectedMembers(arrMembers: selectedUsers)
        self.dismiss(animated: true)
    }
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension TaskMembersListVC: UITableViewDelegate, UITableViewDataSource {
    
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
            cell.lblName.text = data.fullName
            cell.lblTag.text = data.randomId.withHash
            cell.imgCheck.isHidden = true
            cell.imgUser.sd_imageIndicator = SDWebImageActivityIndicator.white
            cell.imgUser.sd_imageTransition = SDWebImageTransition.fade
            let img = #imageLiteral(resourceName: "profile")
            cell.imgUser.sd_setImage(with: data.profilePicURL, placeholderImage: img)
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let isMe = filteredarrMembers[indexPath.row].isMe
        if isTaskAdmin || (!isTaskAdmin && isMe) {
            return swipeActionsForMemberList(indexPath: indexPath)
        }
        // No swipe actions for other cases
        return nil
    }
    
    private func swipeActionsForMemberList(indexPath: IndexPath) -> UISwipeActionsConfiguration {
        let deleteAction = UIContextualAction(
            style: .normal,
            title: nil,
            handler: { [weak self] (_, _, completionHandler) in
                let data = self?.filteredarrMembers[indexPath.row]
                self?.triggerDeleteAction(data:data)
                completionHandler(true)
            }
        )
        let deleteLabelImage = UIImage(named: "trash_icon")
        let deleteLabel = UILabel()
        deleteLabel.text = "Supprimer"
        deleteLabel.font = UIFont(name: "Graphik-Regular", size: 12)
        deleteLabel.sizeToFit()
        deleteLabel.textColor = .white
        
        deleteAction.image = addLabelToImage(image: deleteLabelImage!, label: deleteLabel)
        deleteAction.backgroundColor = UIColor.colorF630301
        
        let actions: [UIContextualAction] = [deleteAction]
        
        let configuration = UISwipeActionsConfiguration(actions: actions)
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
        
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
extension TaskMembersListVC: UITextFieldDelegate {
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

extension TaskMembersListVC: PrClose {
    func closedDelegateAction() {
        RefreshList()
    }
}

// MARK: - Add Users Collection View Delegate
extension TaskMembersListVC: PrTeamMember {
    func setSelectedMembers(arrMembers: [MembersDataViewModel]) {
        let ids = arrMembers.map({"\($0.id)"}).joined(separator: ",")
        var selectedUsers = taskData?.arrUsers.map({"\($0.id)"}).joined(separator: ",") ?? ""
        var items = selectedUsers.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        if !items.contains(ids) {
            items.append(ids)
        }
        selectedUsers = items.joined(separator: ",")
        self.updateTaskMember(selectedUsers: selectedUsers)
    }
}

// MARK: - Api methods
extension TaskMembersListVC {
    @objc func RefreshList() {
        getTaskdetails()
    }
    
    func getTaskdetails() {
        if refreshControl.isRefreshing == false {
            Global.showLoadingSpinner(sender: self.view)
        }
        TasksViewModel.getTaskDetails(id: taskId ?? 0, type: "task") { [weak self] taskData in
            DispatchQueue.main.async {
                Global.dismissLoadingSpinner(self?.view)
                self?.refreshControl.endRefreshing()
                guard let self = self else { return }
                Global.dismissLoadingSpinner(self.view)
                if let taskdetails = taskData {
                    self.taskData = taskdetails
                    var arr = [MembersDataViewModel]()
                    
                    if taskdetails.arrUsers.count > 0 {
                        for i in 0..<taskdetails.arrUsers.count {
                            let data = taskdetails.arrUsers[i]
                            let dataModel = MembersDataModel(id: data.id ,user_id: data.id, member_user_id: data.memberId,first_name: data.name,profile_pic: data.profilePic, isSelected: true, random_id: data.randomId)
                            arr.append(MembersDataViewModel(data: dataModel))
                        }
                    }
                    self.arrMembers = arr
                    self.filterDataBasedOnText(searchText: self.txtSearch.text ?? "")
                    self.tblUsers.reloadData()
                }
            }
        }
    }
    
    func updateTaskMember(selectedUsers: String) {
        Global.showLoadingSpinner(sender: self.view)
        let params: [String: Any] = [
            "title": taskData?.title ?? "",
            "description": taskData?.description ?? "",
            "is_photo": taskData?.isPhotoRequired ?? false ? 1 : 0,
            "is_message": taskData?.isMessageRequired ?? false ? 1 : 0,
            "client_secret": Constants.kClientSecret,
            "is_notification": taskData?.isUrgent ?? false ? 1 : 0,
            "member_ids": selectedUsers,
            "delete_image_ids": "",
            "display_link": taskData?.displayLink ?? "",
            "is_schedule": taskData?.isScheduled ?? false ? 1 : 0,
            "task_id": taskData?.taskId ?? 0,
            "workspcae_id": taskData?.workSpaceId ?? 0,
            "file_name": ""
        ]
        
        HpAPI.taskCreateUpdate.DataAPI(params: params, shouldShowError: true, shouldShowSuccess: false, key: nil) { (response: Result<GeneralModel, Error>) in
            DispatchQueue.main.async {
                Global.dismissLoadingSpinner(self.view)
                switch response {
                case .success(_):
                    self.RefreshList()
                    NotificationCenter.default.post(name: .updateTaksList, object: nil)
                    break
                case .failure(_):
                    break
                }
            }
        }
    }
    
    private func triggerDeleteAction(data: MembersDataViewModel?) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: Messages.txtDeleteTaskMember, message: Messages.txtDeleteTaskMemberConfirmation, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title:  "Supprimer".localized, style: .destructive, handler: { _ in
                guard let data = data else { return }
                self.arrMembers.removeAll { $0.id == data.id }
                let ids = self.arrMembers.map({"\($0.id)"}).joined(separator: ",")
                self.updateTaskMember(selectedUsers: ids)
            }))
            alert.addAction(UIAlertAction.init(title: Messages.txtCancel, style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
