//
//  ArchivedTaskListVC.swift
//  teamAlerts
//
//  Created by MAC on 07/02/25.
//

import Foundation

import UIKit
import SDWebImage
import IQKeyboardManagerSwift
import BottomPopup
import Combine


class ArchivedTaskListVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var vwContainer: UIView!
    @IBOutlet weak var imgFilter: UIImageView!
    @IBOutlet weak var vwFilter: UIView!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var viewEmpty: UIView!
    @IBOutlet weak var vwButton: UIView!
    @IBOutlet weak var selectorView: UIView!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var emptytextLbl: UILabel!
    @IBOutlet weak var emptyTextTitleLabel: UILabel!
    @IBOutlet weak var emptyTextButton: UILabel!
    @IBOutlet weak var emptyButtonImgView: UIImageView!
    @IBOutlet weak var emptyLogoImageview: UIImageView!
    
    // MARK: - Variables
    private var containerHeight: CGFloat = Constants.kScreenHeight // Variable to store vwContainer height
    weak var searchTimer: Timer?
    let refreshControl: UIRefreshControl = UIRefreshControl()
    var listFor: EnumTaskListType = .assignedToMe //"AssignReceived" //AssignReceived,AssignSend
    var currentWorkSpace: WorkSpaceDataViewModel?
    weak var delegate: PrRefreshData?
    var arrGroupedtasks: [GroupedTasksViewModel] = []
    //var arrTaskMessageData: [TaskMessageData] = []
    var messageDataCache: [Int: TaskMessageData] = [:]
    var cancellables = Set<AnyCancellable>()
    
    // MARK: - View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //reset filter
        tblView.showsVerticalScrollIndicator = false
        tblView.showsHorizontalScrollIndicator = false
        vwContainer.layer.cornerRadius = 24
        vwContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        FilterDataCache.remove()
        //        self.vwButton.applyShadow(radius: 3, opacity: 0.1, offset: CGSize(width: 0.0, height: 3.0))
        DispatchQueue.main.async {
            self.vwButton.setShadowWithColor(color: .black, opacity: 0.1, offset: CGSize(width: 0.0, height: 3.0), radius: 3, viewCornerRadius: self.vwButton.frame.height/2)
        }
        self.tblView.register(UINib(nibName: "ArchiveTaskTblCell", bundle: nil), forCellReuseIdentifier: "ArchiveTaskTblCell")
        //updateSelector(for: receivedButton) // Default state
        selectorView.layer.shadowColor = UIColor.black.cgColor
        selectorView.layer.shadowOpacity = 0.1
        selectorView.layer.shadowOffset = CGSize(width: 0, height: 4)
        selectorView.layer.shadowRadius = 8
        refreshControl.addTarget(self, action: #selector(pullRefresh), for: .valueChanged)
        tblView.refreshControl = refreshControl
        NotificationCenter.default.addObserver(self, selector: #selector(receiveDetailsNotification), name: .appNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(pullRefresh), name: .updateTaksList, object: nil)
        self.txtSearch.addTarget(self, action: #selector(textChangedTracker(_ :)), for: .editingChanged)
        //MARK: - get profile data
        allAPIs()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enableAutoToolbar = true
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: - Helpers Methods
    private func updateSelector(for idx: Int) {
        Global.setVibration()
        listFor = idx == 0 ? EnumTaskListType.assignedToMe : EnumTaskListType.assignedByMe
        pullRefresh()
    }
    
    func updateEmptyTexts() {
        if listFor == .assignedByMe {
            self.emptytextLbl.text = "Commencez maintenant et envoyez une nouvelle tâche à vos équipes.".localized
            self.emptyTextButton.text = "Nouvelle task".localized
            self.emptyTextTitleLabel.text = "Faites-le !".localized
            self.emptyLogoImageview.image = UIImage(named: "green-share-icon")
            self.emptyButtonImgView.image = UIImage(named: "ic_PlusWhite")
        } else {
            self.emptytextLbl.text = "Pour recevoir de nouvelles task\npartagez votre compte avec vos équipes.".localized
            self.emptyTextButton.text = "Partager mon ID".localized
            self.emptyTextTitleLabel.text = "Alright ! All done !".localized
            self.emptyLogoImageview.image = UIImage(named: "check-mark-green-new")
            self.emptyButtonImgView.image = UIImage(named: "ic_shareWhite")
        }
    }
    
    @objc func textChangedTracker(_ textfield: UITextField) {
        if searchTimer != nil {
            searchTimer?.invalidate()
            searchTimer = nil
        }
        searchTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(searchData), userInfo: nil, repeats: false)
    }
    
    @objc func searchData() {
        guard (txtSearch.text?.trim().count) ?? 0 >= 3 || (txtSearch.text?.trim().count) == 0 else { return }
        self.pullRefresh()
    }
    
    private func triggerDeleteAction(data:TasksViewModel?) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: Messages.txtDeleteTask, message: Messages.txtDeleteConfirmationTask, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title:  "Supprimer".localized, style: .destructive, handler: { _ in
                self.triggerTrailinghAction(taskToArchive: data, isRestore: false)
            }))
            alert.addAction(UIAlertAction.init(title: Messages.txtCancel, style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - Button Action Methods
    @IBAction func filterTask(_ sender: Any) {
        Global.setVibration()
        guard let popupViewController = Constants.Home.instantiateViewController(withIdentifier: "NewFilterVC") as? NewFilterVC else { return }
        popupViewController.listFor = listFor
        popupViewController.delegate = self
        popupViewController.workspaceId = currentWorkSpace?.id
        present(popupViewController, animated: true, completion: nil)
        
    }
    
    @IBAction func shareMyAccountClicked(_ sender: UIButton) {
        Global.setVibration()
        if listFor == .assignedToMe {
            guard let popupViewController = Constants.Profile.instantiateViewController(withIdentifier: "DisplayScannerVC") as? DisplayScannerVC else { return }
            present(popupViewController, animated: true, completion: nil)
        } else {
            let vc = Constants.Home.instantiateViewController(withIdentifier: "AddTaskVC") as! AddTaskVC
            vc.currentWorkSpace = self.currentWorkSpace
            let nvc = UINavigationController(rootViewController: vc)
            nvc.isModalInPresentation = true
            //nvc.modalPresentationStyle = .automatic
            self.present(nvc, animated: true, completion: nil)
        }
    }
    
}

extension ArchivedTaskListVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrGroupedtasks.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrGroupedtasks[section].arrTasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArchiveTaskTblCell", for: indexPath) as! ArchiveTaskTblCell
        cell.vwBottomline.isHidden = indexPath.row >= 0
        if isLastRow(indexPath: indexPath, tableView: tableView) {
            cell.vwBottomline.isHidden = false
        }
        let data = arrGroupedtasks[indexPath.section].arrTasks[indexPath.row]
        cell.setupTableData(data: data, messageData: nil)
        
        if let cached = messageDataCache[data.taskId] {
            cell.setupTableData(data: data, messageData: cached)
        } else {
            fetchTaskMessageDataPublisher(taskId: data.taskId)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Message fetch error:", error.localizedDescription)
                    }
                }, receiveValue: { [weak self, weak tableView] messageData in
                    guard let self = self,
                          let tableView = tableView,
                          let currentIndexPath = tableView.indexPath(for: cell),
                          currentIndexPath == indexPath else { return }
                    self.messageDataCache[data.taskId] = messageData
                    cell.setupTableData(data: data, messageData: messageData)
                })
                .store(in: &cancellables)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableHeaderCell") as! TableHeaderCell
        cell.lblTitle.text = arrGroupedtasks[section].archiveTitle.uppercased()
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let data = arrGroupedtasks[indexPath.section].arrTasks[indexPath.row]
        // only allow swipe if user is admin
        let taskAdmin = currentWorkSpace?.isAdmin ?? false || (data.taskAssignerUserId == HpGlobal.shared.userInfo?.userId)
        if taskAdmin {
            return swipeActionsForArchiveList(indexPath: indexPath)
        }
        
        // No swipe actions for other cases
        return nil
    }
    
    private func swipeActionsForArchiveList(indexPath: IndexPath) -> UISwipeActionsConfiguration {
        let restoreAction = UIContextualAction(
            style: .normal,
            title: nil,
            handler: { [weak self] (_, _, completionHandler) in
                let data = self?.arrGroupedtasks[indexPath.section].arrTasks[indexPath.row]
                
                self?.triggerTrailinghAction(taskToArchive: data, isRestore: true)
                completionHandler(true)
            }
        )
        let iconImage = UIImage(named: "restore_icon")
        let readLabel = UILabel()
        readLabel.text = "Restorer"
        readLabel.font = UIFont(name: "Graphik-Regular", size: 12)
        readLabel.sizeToFit()
        readLabel.textColor = .white
        
        restoreAction.image = addLabelToImage(image: iconImage!, label: readLabel)
        restoreAction.backgroundColor = UIColor.color3A66FF
        
        let deleteAction = UIContextualAction(
            style: .normal,
            title: nil,
            handler: { [weak self] (_, _, completionHandler) in
                let data = self?.arrGroupedtasks[indexPath.section].arrTasks[indexPath.row]
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
        
        let actions: [UIContextualAction] = [deleteAction,restoreAction]
        
        let configuration = UISwipeActionsConfiguration(actions: actions)
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
        
    }
    
    private func triggerTrailinghAction(taskToArchive:TasksViewModel?,isRestore:Bool) {
        taskDeleteOrRestore(taskData: taskToArchive, isRestore: isRestore) {[weak self] done in
            DispatchQueue.main.async {
                guard let self = self else { return }
                TasksViewModel.addArchiveTextMessage(chatNodeId: "\(taskToArchive?.taskId ?? 0)", isRestore: true)
                self.pullRefresh()
                self.delegate?.refreshData()
            }
        }
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Global.setVibration()
        let data = arrGroupedtasks[indexPath.section].arrTasks[indexPath.row]
        let taskAdmin = currentWorkSpace?.isAdmin ?? false || (data.taskAssignerUserId == HpGlobal.shared.userInfo?.userId)
        
        let vc = Constants.Chat.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
        vc.taskData = data
        vc.isfromArchive = true
        vc.isTaskAdmin = taskAdmin
        vc.delegate = self
        let nav = UINavigationController(rootViewController: vc)
        nav.isModalInPresentation = true
        self.present(nav, animated: true)
    }
    
}
extension ArchivedTaskListVC: UITextFieldDelegate {
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

extension ArchivedTaskListVC: PrTabSelected {
    func selectedTab(idx: Int) {
        print("===TAB===> ", idx)
        updateSelector(for: idx)
    }
}

extension ArchivedTaskListVC: PrRefreshData {
    func refreshData() {
        let filterData = FilterDataCache.get()
        self.imgFilter.isHighlighted = filterData.isFilterApplied
        pullRefresh()
    }
}

extension ArchivedTaskListVC {
    @objc func pullRefresh() {
        //        getTaskList(listFor: listFor.rawValue)
        let currenWorkSpaceId = UserDefaults.standard.integer(forKey: Constants.kSelectedWorkSpaceId)
        
        getTasks(listFor: listFor.rawValue, currenWorkSpaceId: currenWorkSpaceId, searchTxt: txtSearch.text?.trim() ?? "") {[weak self] (data) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.refreshControl.endRefreshing()
                self.messageDataCache.removeAll()
                self.arrGroupedtasks = data
                self.viewEmpty.isHidden = data.count > 0
                self.vwButton.isHidden = data.count > 0
                self.tblView.reloadData()
                //self.getAllPresentNodeChatData()
                self.updateEmptyTexts()
            }
        }
    }
    
    /// Function to check which all message contains read by key
    func getMessageisReadStatus(nodeMessages:[ChatViewModel]) -> Bool {
        guard let userData = HpGlobal.shared.userInfo,
              let latestMessage = nodeMessages.max(by: { $0.chatDateTime < $1.chatDateTime })
        else { return false }
        
        if latestMessage.readBy.contains(where: { $0 == "\(userData.userId)" }) {
            return true
        } else {
            return false
        }
    }
    
    /// Function to get the read count for all chat array
    func getUnreadMessageCount(in messages: [ChatViewModel]) -> Int {
        guard let userData = HpGlobal.shared.userInfo else { return 0 }
        return messages.filter { message in
            !(message.readBy.contains("\(userData.userId)"))
        }.count
    }
    
    
    /// Get Chat messages  API
    func fetchChatMessagesPublisher(chatNodeId: String, isArchiveDataRequired: Bool = false) -> Future<[ChatViewModel], Error> {
        return Future { promise in
            TasksViewModel.getAllChatMessagesFirebase(chatNodeId: chatNodeId, isArchiveDataRequired: isArchiveDataRequired) { data in
                promise(.success(data))
            }
        }
    }
    
    /// Convert Chat Data To TaskMessageData API
    func fetchTaskMessageDataPublisher(taskId: Int) -> AnyPublisher<TaskMessageData, Error> {
        fetchChatMessagesPublisher(chatNodeId: "\(taskId)")
            .map { messages in
                return TaskMessageData(taskId: taskId, messageCount: messages.count == 0 ? 1 : messages.count, unreadMessageCount: self.getUnreadMessageCount(in: messages), isRead: self.getMessageisReadStatus(nodeMessages: messages))
            }
            .eraseToAnyPublisher()
    }
    
    func getTasks(listFor: String,currenWorkSpaceId:Int,searchTxt:String, completion: @escaping(_ data: [GroupedTasksViewModel])->()) {
        let params: [String: Any] = [
            "search_key": searchTxt,
            "page": 1,
            "limit": 10000,
            "workspcae_id":currenWorkSpaceId,
            "list_for":listFor
        ]
        TasksViewModel.getArchivedTaskList(parameters:params) {[weak self] data in
            DispatchQueue.main.async {
                guard self != nil else { return }
                completion(data)
                
            }
        }
    }
    
    func GetWorkSpaces(shouldShowLoader: Bool,completion: @escaping(_ workSpaceList: [WorkSpaceDataViewModel])->()) {
        WorkSpaceViewModel.GetWorkSpaceList( page: 1, limit: 1000, sender: self, shouldShowLoader: shouldShowLoader) { arrMembers, totalTask  in
            DispatchQueue.main.async {
                completion(arrMembers)
                
            }
        }
    }
    
    func taskDeleteOrRestore(taskData:TasksViewModel?,isRestore:Bool,completion: @escaping(_ done: Bool)->()) {
        guard let taskData = taskData else { return }
        //guard imageNames != "" else { return }
        let params: [String: Any] = [
            "task_id": taskData.taskId,
            "client_secret": Constants.kClientSecret,
            //completion_id:
        ]
        
        Global.showLoadingSpinner(sender: self.view)
        var hdpiApiname = HpAPI.taskArchiveDelete
        if isRestore {
            hdpiApiname = HpAPI.taskArchiveRestore
        }
        hdpiApiname.DataAPI(params: params, shouldShowError: true, shouldShowSuccess: false, key: nil) { (response: Result<GeneralModel, Error>) in
            DispatchQueue.main.async {
                Global.dismissLoadingSpinner(self.view)
                switch response {
                case .success(_):
                    completion(true)
                    break
                case .failure(_):
                    completion(false)
                    break
                }
            }
        }
    }
    
//    func getAllPresentNodeChatData() {
//        self.arrTaskMessageData.removeAll()
//        let dispatchGroup = DispatchGroup()
//        for arrTask in arrGroupedtasks {
//            for task in arrTask.arrTasks {
//                dispatchGroup.enter()
//                TasksViewModel.getAllChatMessagesFirebase(chatNodeId: "\(task.taskId)") { data in
//                    self.arrTaskMessageData.append(TaskMessageData(taskId: task.taskId, messageCount: data.count, unreadMessageCount: self.getUnreadMessageCount(in: data), isRead: true))
//                    do { dispatchGroup.leave() }
//                }
//            }
//        }
//        dispatchGroup.notify(queue: .main) { [weak self] in
//            self?.tblView.reloadData()
//        }
//    }
    
    func allAPIs() {
        let gcd = DispatchGroup()
        let queue = DispatchQueue(label: "com.BeTasker.HomeTaskAPIs", qos: .background, attributes: .concurrent)
        let semaphore = DispatchSemaphore(value: 10) // Allow 1 concurrent API calls
        
        let searchText = txtSearch.text?.trim() ?? ""
        let currenWorkSpaceId = UserDefaults.standard.integer(forKey: Constants.kSelectedWorkSpaceId)
        
        queue.async(group: gcd) { // Use group parameter to automatically manage enter and leave
            gcd.enter()
            self.getTasks(listFor: self.listFor.rawValue, currenWorkSpaceId: currenWorkSpaceId, searchTxt: searchText) {[weak self] (data) in
                self?.messageDataCache.removeAll()
                self?.arrGroupedtasks = data
                semaphore.signal()
                gcd.leave()
            }
            semaphore.wait() // Wait for semaphore
        }
        
        gcd.notify(queue: .main) {
            self.viewEmpty.isHidden = self.arrGroupedtasks.count > 0
            self.vwButton.isHidden = self.arrGroupedtasks.count > 0
            self.tblView.reloadData()
            //self.getAllPresentNodeChatData()
            self.updateEmptyTexts()
            
        }
    }
}


class TableHeaderCell: UITableViewCell {
    @IBOutlet weak var lblTitle: UILabel!
}
