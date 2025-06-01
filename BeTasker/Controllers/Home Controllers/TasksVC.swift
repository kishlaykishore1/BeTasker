//
//  TasksVC.swift
//  teamAlerts
//
//  Created by B2Cvertical A++ on 25/11/24.
//

import UIKit
import SDWebImage
import IQKeyboardManagerSwift
import Combine
import StoreKit

@objc protocol PrTabSelected: AnyObject {
    @objc optional func selectedTab(idx: Int)
    @objc optional func shouldAllowTabSwitch() -> Bool
}

protocol PrRefreshData: AnyObject {
    func refreshData()
}

struct TaskMessageData {
    var taskId: Int
    var messageCount: Int
    var unreadMessageCount: Int
    var isRead: Bool
}

class TasksVC: BaseViewController {
    
    // MARK: - Outlets
    //@IBOutlet weak var imgFilter: UIImageView!
    //@IBOutlet weak var vwFilter: UIView!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var statusCollectionView: UICollectionView!
    @IBOutlet weak var viewEmpty: UIView!
    @IBOutlet weak var vwButton: UIView!
    @IBOutlet weak var selectorView: UIView!
    @IBOutlet weak var workSpaceTitleContainerView: UIView!
    @IBOutlet weak var wsArrowImgView: UIImageView!
    @IBOutlet weak var wsRedDotView: UIView!
    @IBOutlet weak var wsTitleLabel: UILabel!
    @IBOutlet weak var emptytextLbl: UILabel!
    @IBOutlet weak var emptyTextTitleLabel: UILabel!
    @IBOutlet weak var emptyTextButton: UILabel!
    @IBOutlet weak var emptyButtonImgView: UIImageView!
    @IBOutlet weak var emptyLogoImageview: UIImageView!
    @IBOutlet weak var txtSearch: UITextField!
    //@IBOutlet weak var viewAddTask: UIView!
    
    // MARK: - Variables
    let refreshControl:UIRefreshControl = UIRefreshControl()
    var listFor: EnumTaskListType = .assignedToMe //"AssignReceived" //AssignReceived,AssignSend
    var arrSection: [GroupedTasksViewModel] = []
    //var arrTasksAssignedToMe: [TasksViewModel] = []
    //var arrTasksAssignedByMe: [TasksViewModel] = []
    var totalAssignedToMe = 0
    var totalAssignedByMe = 0
    var totalTaskAvailable = 0
    var overallTaskPendingCount: Int = 0
    var currentWorkSpace: WorkSpaceDataViewModel?
    //var arrTaskMessageData: [TaskMessageData] = []
    weak var searchTimer: Timer?
    var selectedTabIndex: Int = 0 // 0 = received, 2 = sent
    var arrStatus = [TaskStatusViewModel]()
    var messageDataCache: [Int: TaskMessageData] = [:]
    var cancellables = Set<AnyCancellable>()
    private var statusFilterSubject = PassthroughSubject<Void, Never>()
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setTheShadow()
        //reset filter
        FilterDataCache.remove()
        setupStatusFilterDebounce()
        setNotificationObserver()
        self.txtSearch.addTarget(self, action: #selector(textChangedTracker(_ :)), for: .editingChanged)
        //MARK: - get profile data
        callGetUserProfileDetails()
        allAPIsWithCombine()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enableAutoToolbar = true
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
        self.searchTimer?.invalidate()
        self.navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: - Helper Methods
    func setupTableView() {
        self.tblView.register(UINib(nibName: "NewTaskCell", bundle: nil), forCellReuseIdentifier: "NewTaskCell")
        tblView.showsVerticalScrollIndicator = false
        tblView.showsHorizontalScrollIndicator = false
        if let tabVC = self.tabBarController as? TabBarController {
            tabVC.delegateTab = self
        }
        
        refreshControl.addTarget(self, action: #selector(pullRefresh), for: .valueChanged)
        tblView.refreshControl = refreshControl
        
        
        self.statusCollectionView.register(UINib(nibName: "NewFilterCollCell", bundle: nil), forCellWithReuseIdentifier: "NewFilterCollCell")
        self.statusCollectionView.register(UINib(nibName: "HomeStatusCollCell", bundle: nil), forCellWithReuseIdentifier: "HomeStatusCollCell")
    }
    
    func setTheShadow() {
        vwButton.applyShadow(radius: 3, opacity: 0.1, offset: CGSize(width: 0.0, height: 3.0))
        workSpaceTitleContainerView.layer.cornerRadius = workSpaceTitleContainerView.frame.height/2
        workSpaceTitleContainerView.applyShadow(radius: 3, opacity: 0.1, offset: CGSize(width: 0.0, height: 3.0))
        selectorView.layer.shadowColor = UIColor.black.cgColor
        selectorView.layer.shadowOpacity = 0.1
        selectorView.layer.shadowOffset = CGSize(width: 0, height: 4)
        selectorView.layer.shadowRadius = 8
        self.wsRedDotView.layer.cornerRadius = 4.0
        self.wsRedDotView.clipsToBounds = true
    }
    
    func setNotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(SetProfileData), name: .updateProfile, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(receiveDetailsNotification), name: .appNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(pullRefresh), name: .updateTaksList, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(pullRefresh), name: .receivedArchiveNotification, object: nil)
    }
    
    func callGetUserProfileDetails() {
        apiGetProfileData(id: nil, showloader: false) { [weak self] userData, userModel in
            DispatchQueue.main.async {
                HpGlobal.shared.userInfo = userData
                self?.SetProfileData()
                
                //MARK: - If we are coming from killed state
                if HpGlobal.shared.pushNotificationData.redirect_type != nil && HpGlobal.shared.pushNotificationData.redirect_type != "" {
                    let data = PushNotifyViewModel(model: HpGlobal.shared.pushNotificationData)
                    HpGlobal.shared.pushNotificationData = PushNotifyModel()
                    self?.navigate(data: data)
                }
            }
        }
    }
    
    @objc func SetProfileData() {
        if let data = HpGlobal.shared.userInfo {
            UserDefaults.standard.set(data.userId, forKey: Constants.KUserIDKey)
            self.imgProfile.sd_imageIndicator = SDWebImageActivityIndicator.white
            self.imgProfile.sd_imageTransition = SDWebImageTransition.fade
            let img = #imageLiteral(resourceName: "profile")
            self.imgProfile.sd_setImage(with: data.profilePicURL, placeholderImage: img)
        }
    }
    
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
            // green-share-icon
        } else {
            self.emptytextLbl.text = "Pour recevoir de nouvelles task,\npartagez votre ID BeTasker avec vos équipes.".localized
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
    
    @objc func statusFilterData() {
        var filterData: FilterDataModel? = FilterDataCache.get().data
        if !self.arrStatus.isEmpty {
            let selectedStatusId = self.arrStatus.filter({ $0.isSelected }).map({$0.id})
            filterData?.statusIds = selectedStatusId
        }
        filterData?.isFilterApplied = true
        if let filterData {
            FilterDataCache.save(filterData)
        }
        let filterVM = FilterDataCache.get()
        if filterVM.isEmpty {
            filterData?.isFilterApplied = false
            FilterDataCache.save(filterData ?? FilterDataModel())
        }
        self.pullRefresh()
    }
    
    func handelRedDotView() {
        self.wsRedDotView.isHidden = overallTaskPendingCount == 0
        UIApplication.shared.applicationIconBadgeNumber = overallTaskPendingCount
    }
    
    func openInitialWorkspaceScreen() {
        Global.setVibration()
        let vc = Constants.Main.instantiateViewController(withIdentifier: "InitialWorkspaceScreenVC") as! InitialWorkspaceScreenVC
        vc.workspaceAdded = { [weak self] in
            self?.allAPIsWithCombine()
        }
        let nvc = UINavigationController(rootViewController: vc)
        nvc.modalPresentationStyle = .overFullScreen
        self.present(nvc, animated: true, completion: nil)
    }
    
    func openAddTask(isFromCamera: Bool = false, image: UIImage? = nil) {
        DispatchQueue.main.async {
            if PremiumManager.shared.canCreateTask(workspaceCreatorIsPremium: self.currentWorkSpace?.isPremium ?? false, currentTaskCount: self.totalTaskAvailable) {
                DispatchQueue.main.async {
                    let vc = Constants.Home.instantiateViewController(withIdentifier: "AddTaskVC") as! AddTaskVC
                    vc.currentWorkSpace = self.currentWorkSpace
                    vc.imageFromCameraRoll = image
                    vc.isFromCameraRoll = isFromCamera
                    let nvc = UINavigationController(rootViewController: vc)
                    nvc.isModalInPresentation = true
                    self.present(nvc, animated: true, completion: nil)
                }
            } else {
                PremiumManager.shared.openPremiumScreen()
            }
        }
    }
    
    private func setupStatusFilterDebounce() {
        statusFilterSubject
            .debounce(for: .milliseconds(1000), scheduler: DispatchQueue.main)
            .sink { [weak self] in
                self?.statusFilterData()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Button Action Methods
    @IBAction func btnSearch_Action(_ sender: UIButton) {
        Global.setVibration()
        sender.isSelected.toggle()
        if sender.isSelected {
            self.selectorView.isHidden = false
            self.txtSearch.becomeFirstResponder()
        } else {
            self.selectorView.isHidden = true
            self.txtSearch.resignFirstResponder()
        }
    }
    
    @IBAction func profileTapAction(_ sender: Any) {
        Global.setVibration()
        let vc = Constants.Profile.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        let nvc = UINavigationController(rootViewController: vc)
        nvc.modalPresentationStyle = .overFullScreen
        self.present(nvc, animated: true, completion: nil)
    }
    
    @IBAction func workSpaceButtonClicked(_ sender: Any) {
        Global.setVibration()
        guard let popupViewController = Constants.Home.instantiateViewController(withIdentifier: "WorkSpaceListVC") as? WorkSpaceListVC else { return }
        //        popupViewController.listFor = listFor
        popupViewController.currentWorkSpace  = self.currentWorkSpace
        popupViewController.delegate = self
        present(popupViewController, animated: true, completion: nil)
    }
    
    @IBAction func taskHistoryTapped(_ sender: UIButton) {
        Global.setVibration()
        guard let popupViewController = Constants.Home.instantiateViewController(withIdentifier: "ArchivedTaskListVC") as? ArchivedTaskListVC else { return }
        popupViewController.listFor = listFor
        popupViewController.currentWorkSpace = self.currentWorkSpace
        popupViewController.delegate = self
        present(popupViewController, animated: true, completion: nil)
        
    }
    
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
            openAddTask()
        }
    }
}

// MARK: - Table View dataSource Methods
extension TasksVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        arrSection.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //        switch listFor {
        //        case .assignedToMe:
        //            return arrTasksAssignedToMe.count
        //        case .assignedByMe:
        //            return arrTasksAssignedByMe.count
        //        }
        arrSection[section].arrTasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewTaskCell", for: indexPath) as! NewTaskCell
        let data = arrSection[indexPath.section].arrTasks[indexPath.row]
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
}

// MARK: - UITableView Delegate Methods
extension TasksVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableHeaderCell") as! TableHeaderCell
        cell.lblTitle.text = arrSection[section].sectionTitle
        return cell
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        //let data = listFor == .assignedToMe ? arrTasksAssignedToMe[indexPath.row] : arrTasksAssignedByMe[indexPath.row]
        let data = arrSection[indexPath.section].arrTasks[indexPath.row]
        
        return UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: {
            return self.makePreviewController(for: data)
        }, actionProvider: { _ in
            return self.makeMenuActions(for: data, indexPath: indexPath)
        })
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // Only add swipe if we're on the "Sent" tab
        if selectedTabIndex == 2 {
            return swipeActionsForArchive(indexPath: indexPath)
        }
        
        // On "Received" tab, only allow swipe if user is admin
        let data = arrSection[indexPath.section].arrTasks[indexPath.row]
        let taskAdmin = currentWorkSpace?.isAdmin ?? false || (data.taskAssignerUserId == HpGlobal.shared.userInfo?.userId)
        if selectedTabIndex == 0 && taskAdmin {
            return swipeActionsForArchive(indexPath: indexPath)
        }
        
        // No swipe actions for other cases
        return nil
    }
    
    private func swipeActionsForArchive(indexPath: IndexPath) -> UISwipeActionsConfiguration {
        let readAction = UIContextualAction(
            style: .normal,
            title: nil,
            handler: { [weak self] (_, _, completionHandler) in
                //let data = self?.listFor == .assignedToMe ? self?.arrTasksAssignedToMe[indexPath.row] : self?.arrTasksAssignedByMe[indexPath.row]
                let data = self?.arrSection[indexPath.section].arrTasks[indexPath.row]
                self?.triggerArchiveAction(taskToArchive: data, at: indexPath)
                completionHandler(true)
            }
        )
        let iconImage = UIImage(named: "archive_icon")
        let readLabel = UILabel()
        readLabel.text = "Archiver".localized
        readLabel.font = UIFont(name: "Graphik-Regular", size: 12)
        readLabel.sizeToFit()
        readLabel.textColor = .white
        
        readAction.image = Global.addLabelToImage(image: iconImage!, label: readLabel)
        readAction.backgroundColor = UIColor.color3A66FF
        
        let actions: [UIContextualAction] = [readAction]
        
        let configuration = UISwipeActionsConfiguration(actions: actions)
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
        
    }
    
    private func triggerArchiveAction(taskToArchive:TasksViewModel?, at indexPath: IndexPath) {
        taskCompletion(taskData: taskToArchive) {[weak self] done in
            DispatchQueue.main.async {
                guard let self = self else { return }
                TasksViewModel.addArchiveTextMessage(chatNodeId: "\(taskToArchive?.taskId ?? 0)", isRestore: false)
                
                var section = self.arrSection[indexPath.section]
                section.arrTasks.remove(at: indexPath.row)
                
                if section.arrTasks.isEmpty {
                    self.arrSection.remove(at: indexPath.section)
                } else {
                    self.arrSection[indexPath.section] = section
                }
                
                self.tblView.reloadData()
                ReviewManager.shared.requestReviewIfAppropriate()
                self.callOnlyGetWorkSpaces()
            }
        }
    }
    
    private func makePreviewController(for model: TasksViewModel) -> UIViewController {
        let vc = Constants.Chat.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
        vc.taskData = model
        return vc
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Global.setVibration()
        if listFor == EnumTaskListType.assignedToMe {
            let vc = Constants.Chat.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
            vc.taskData = arrSection[indexPath.section].arrTasks[indexPath.row]
            let nav = UINavigationController(rootViewController: vc)
            nav.isModalInPresentation = true
            self.present(nav, animated: true)
        } else {
            let vc = Constants.Chat.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
            vc.taskData = arrSection[indexPath.section].arrTasks[indexPath.row]
            let nav = UINavigationController(rootViewController: vc)
            nav.isModalInPresentation = true
            self.present(nav, animated: true)
        }
    }
}

// MARK: - CollectionView DataSource methods
extension TasksVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrStatus.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewFilterCollCell", for: indexPath) as! NewFilterCollCell
            let filterData = FilterDataCache.get().data
            cell.checkForFilterSelection(isSelected: filterData.isFilterApplied)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeStatusCollCell", for: indexPath) as! HomeStatusCollCell
            let data = arrStatus[indexPath.row]
            cell.configureCell(with: data)
            return cell
        }
    }
}

// MARK: - CollectionView Delegate methods
extension TasksVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Global.setVibration()
        if indexPath.row == 0 {
            guard let popupViewController = Constants.Home.instantiateViewController(withIdentifier: "NewFilterVC") as? NewFilterVC else { return }
            popupViewController.listFor = listFor
            popupViewController.delegate = self
            popupViewController.workspaceId = currentWorkSpace?.id
            present(popupViewController, animated: true, completion: nil)
        } else {
            arrStatus[indexPath.item].isSelected.toggle()
            if !arrStatus[indexPath.item].isSelected {
                statusCollectionView.deselectItem(at: indexPath, animated: false)
            }
            statusCollectionView.reloadItems(at: [indexPath])
            statusFilterSubject.send()
        }
    }
}

// MARK: - Collection View DelegateFlow Layout Methods
extension TasksVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row == 0 {
            return CGSize(width: 90, height: self.statusCollectionView.frame.height)
        } else {
            let size = (arrStatus[indexPath.row].title).size(withAttributes: [
                NSAttributedString.Key.font: UIFont(name: Constants.KGraphikMedium, size: 13.0) ?? UIFont.systemFont(ofSize: 13, weight: .medium)
            ])
            return CGSize(width: size.width + 32, height: self.statusCollectionView.frame.height)
        }
    }
}

// MARK: - UITextField delagate Methods
extension TasksVC: UITextFieldDelegate {
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

extension TasksVC: WorkSpaceSelectclose {
    func workSpaceSelectionChange(selectedWS:WorkSpaceDataViewModel) {
        self.currentWorkSpace = selectedWS
        self.wsTitleLabel.text = selectedWS.workSpaceName
        UserDefaults.standard.set(selectedWS.id, forKey: Constants.kSelectedWorkSpaceId)
        if self.currentWorkSpace?.isAdmin ?? false {
            if let tabVC = self.tabBarController as? TabBarController {
                tabVC.showAddTaskButton(true)
            }
        } else {
            if let tabVC = self.tabBarController as? TabBarController {
                tabVC.showAddTaskButton(false)
            }
        }
        self.pullRefresh()
    }
}

extension TasksVC: PrTabSelected {
    func selectedTab(idx: Int) {
        print("===TAB===> ", idx)
        if idx == 3 || idx == 4 {
            switch idx {
            case 3:
                openAddTask()
            default:
                checkCameraPermission()
            }
            return
        }
        selectedTabIndex = idx
        updateSelector(for: idx)
    }
    
    func shouldAllowTabSwitch() -> Bool {
        let taskAdmin = currentWorkSpace?.isAdmin ?? false
        return taskAdmin
    }
}

extension TasksVC: PrRefreshData {
    func refreshData() {
        _ = FilterDataCache.get()
        //self.imgFilter.isHighlighted = filterData.isFilterApplied
        pullRefresh()
    }
}

// MARK: -  UIImage Picker Delegate Methods
extension TasksVC {
    
    override func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImage: UIImage?
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImage = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
        }
        picker.dismiss(animated: true)
        openDrawingOn(image: selectedImage ?? UIImage()) { [weak self] image in
            self?.openAddTask(isFromCamera: true, image: image)
        }
    }
    
    func openDrawingOn(image: UIImage, onDoneAction: ((UIImage) -> Void)?) {
        DispatchQueue.main.async {
            let drawingVC = DrawingVC(image: image, onDoneAction: onDoneAction)
            let navController = UINavigationController(rootViewController: drawingVC)
            navController.modalPresentationStyle = .fullScreen
            self.present(navController, animated: true)
        }
    }
}

// MARK: - UIMENU Action for Peek and Preview option
extension TasksVC {
    
    private func makeMenuActions(for model: TasksViewModel, indexPath: IndexPath) -> UIMenu {
        let open = UIAction(title: "Ouvrir".localized, image: UIImage(systemName: "eye")) { _ in
            self.handleOpen(model)
        }
        
        let relaunch = UIAction(title: "Relancer".localized, image: UIImage(systemName: "bell.and.waves.left.and.right")) { _ in
            self.handleRelaunch(model)
        }
        
        let taskAdmin = currentWorkSpace?.isAdmin ?? false || (model.taskAssignerUserId == HpGlobal.shared.userInfo?.userId)
        if selectedTabIndex == 0 && taskAdmin || selectedTabIndex == 2 {
            let archive = UIAction(title: "Archiver".localized, image: UIImage(systemName: "archivebox")) { _ in
                self.handleArchive(model, indexPath: indexPath)
            }
            return UIMenu(title: "", children: [open, relaunch, archive])
        }
        
        return UIMenu(title: "", children: [open, relaunch])
    }
    
    private func handleOpen(_ model: TasksViewModel) {
        let vc = Constants.Chat.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
        vc.taskData = model
        let nav = UINavigationController(rootViewController: vc)
        nav.isModalInPresentation = true
        self.present(nav, animated: true)
    }
    
    private func handleRelaunch(_ model: TasksViewModel) {
        self.reNotifyTaskMembers(taskData: model) { _ in }
    }
    
    private func handleArchive(_ model: TasksViewModel, indexPath: IndexPath) {
        self.triggerArchiveAction(taskToArchive: model, at: indexPath)
    }
}

// MARK: - Api Functions And Calling For Task List
extension TasksVC {
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
    
    /// Function to call the archive chat API
    func taskCompletion(taskData:TasksViewModel?,completion: @escaping(_ done: Bool)->()) {
        guard let taskData = taskData else { return }
        //guard imageNames != "" else { return }
        let params: [String: Any] = [
            "task_id": taskData.taskId,
            "client_secret": Constants.kClientSecret,
        ]
        
        Global.showLoadingSpinner(sender: self.view)
        HpAPI.taskArchiveRestore.DataAPI(params: params, shouldShowError: true, shouldShowSuccess: false, key: nil) { (response: Result<GeneralModel, Error>) in
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
    
    /// Function to call the Renotify Task Members API
    func reNotifyTaskMembers(taskData:TasksViewModel?, completion: @escaping(_ done: Bool)->()) {
        guard let taskData = taskData else { return }
        //guard imageNames != "" else { return }
        let params: [String: Any] = [
            "task_id": taskData.taskId,
            "client_secret": Constants.kClientSecret,
        ]
        
        Global.showLoadingSpinner(sender: self.view)
        HpAPI.taskReminder.DataAPI(params: params, shouldShowError: true, shouldShowSuccess: false, key: nil) { (response: Result<GeneralModel, Error>) in
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
    
    /// Get All Task List API
    func getTasksPublisher(listFor: String, currenWorkSpaceId: Int, searchText: String) -> AnyPublisher<([GroupedTasksViewModel], Int, Int), Error> {
        Future { promise in
            TasksViewModel.getTaskList(listFor: listFor, currenWorkSpaceId: currenWorkSpaceId, searchText: searchText) { data, total, totalTask in
                promise(.success((data, total, totalTask)))
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    /// Get Workspace List API
    func getWorkSpacesPublisher(shouldShowLoader: Bool) -> AnyPublisher<([WorkSpaceDataViewModel], Int), Never> {
        Future { promise in
            WorkSpaceViewModel.GetWorkSpaceList(page: 1, limit: 1000, sender: self, shouldShowLoader: shouldShowLoader) { workspaces, totalTaskPending in
                promise(.success((workspaces, totalTaskPending)))
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
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
    
    private func getHomeStatusListPublisher() -> AnyPublisher<Void, Never> {
        return Future<Void, Never> { [weak self] promise in
            guard let self = self else {
                promise(.success(()))
                return
            }
            
            let param: [String: Any] = [
                "list_for": self.listFor.rawValue,
                "workspcae_id": UserDefaults.standard.integer(forKey: Constants.kSelectedWorkSpaceId)
            ]
            let filterData = FilterDataCache.get()
            
            TaskStatusViewModel.homeTaskStatusList(param: param) { [weak self] list in
                guard let self = self else {
                    promise(.success(()))
                    return
                }
                
                DispatchQueue.main.async {
                    self.arrStatus = list
                    for i in 0..<filterData.statusIds.count {
                        if let idx = self.arrStatus.firstIndex(where: { $0.id == filterData.statusIds[i] }) {
                            self.arrStatus[idx].isSelected = true
                        }
                    }
                    let filterStatus = TaskStatusModel(id: 0, title: "Filter", isSelected: false)
                    self.arrStatus.insert(TaskStatusViewModel(data: filterStatus), at: 0)
                    //Global.dismissLoadingSpinner(self.view)
                    self.statusCollectionView.reloadData()
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func callOnlyGetWorkSpaces() {
        getWorkSpacesPublisher(shouldShowLoader: false)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    Common.showAlertMessage(message: error.localizedDescription.localized,
                                            alertType: .error,
                                            isPreferLightStyle: false)
                }
            } receiveValue: { [weak self] (workspaces, totalTaskPending) in
                guard let self = self else { return }
                self.overallTaskPendingCount = totalTaskPending
                self.handelRedDotView()
                
                var currenWorkSpaceId = UserDefaults.standard.integer(forKey: Constants.kSelectedWorkSpaceId)
                
                if currenWorkSpaceId != 0 {
                    let workspace = workspaces.first { $0.id == currenWorkSpaceId }
                    NotificationCenter.default.post(name: .workspaceSelectedNotification, object: workspace)
                    HpGlobal.shared.selectedWorkspace = workspace
                } else if let first = workspaces.first {
                    currenWorkSpaceId = first.id
                    NotificationCenter.default.post(name: .workspaceSelectedNotification, object: first)
                    HpGlobal.shared.selectedWorkspace = first
                } else {
                    self.openInitialWorkspaceScreen()
                }
            }
            .store(in: &cancellables)
    }
    
    /// Pull To refresh Function for screen
    @objc func pullRefresh() {
        let currenWorkSpaceId = UserDefaults.standard.integer(forKey: Constants.kSelectedWorkSpaceId)
        let searchText = txtSearch.text?.trim() ?? ""
        
        getHomeStatusListPublisher()
            .setFailureType(to: Error.self)
            .flatMap { [weak self] _ -> AnyPublisher<([GroupedTasksViewModel], Int, Int), Error> in
                guard let self = self else {
                    return Fail(error: NSError(domain: "Self is nil", code: -1)).eraseToAnyPublisher()
                }
                return self.getTasksPublisher(listFor: self.listFor.rawValue, currenWorkSpaceId: currenWorkSpaceId, searchText: searchText)
            }
            .handleEvents(receiveOutput: { [weak self] data, total, totalTask in
                guard let self = self else { return }
                self.refreshControl.endRefreshing()
                self.messageDataCache.removeAll()
                self.arrSection.removeAll()
                self.arrSection = data
                self.viewEmpty.isHidden = !data.isEmpty
                self.vwButton.isHidden = !data.isEmpty
                switch self.listFor {
                case .assignedToMe:
                    self.totalAssignedToMe = total
                case .assignedByMe:
                    self.totalAssignedByMe = total
                }
                self.totalTaskAvailable = totalTask
                self.tblView.reloadData()
                self.updateEmptyTexts()
            })
            .flatMap { [weak self] _ -> AnyPublisher<([WorkSpaceDataViewModel], Int), Never> in
                guard let self = self else {
                    return Just(([], Int())).eraseToAnyPublisher()
                }
                return self.getWorkSpacesPublisher(shouldShowLoader: false)
            }
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    Common.showAlertMessage(message: error.localizedDescription.localized, alertType: .error, isPreferLightStyle: false)
                }
            } receiveValue: { [weak self] workspaces, totalTaskPending in
                guard let self = self else { return }
                
                self.overallTaskPendingCount = totalTaskPending
                self.handelRedDotView()
                
                var currenWorkSpaceId = UserDefaults.standard.integer(forKey: Constants.kSelectedWorkSpaceId)
                if currenWorkSpaceId != 0 {
                    let workspace = workspaces.first { $0.id == currenWorkSpaceId }
                    NotificationCenter.default.post(name: .workspaceSelectedNotification, object: workspace)
                    HpGlobal.shared.selectedWorkspace = workspace
                } else if let first = workspaces.first {
                    currenWorkSpaceId = first.id
                    NotificationCenter.default.post(name: .workspaceSelectedNotification, object: first)
                    HpGlobal.shared.selectedWorkspace = first
                } else {
                    self.openInitialWorkspaceScreen()
                }
            }
            .store(in: &cancellables)
    }
    
    
    
    
    func allAPIsWithCombine() {
        Global.showLoadingSpinner(sender: self.view)
        
        var currenWorkSpaceId = UserDefaults.standard.integer(forKey: Constants.kSelectedWorkSpaceId)
        let searchText = txtSearch.text?.trim() ?? ""
        
        getWorkSpacesPublisher(shouldShowLoader: false)
            .flatMap { [weak self] workspaces, totalTaskPending -> AnyPublisher<([GroupedTasksViewModel], Int, Int, [WorkSpaceDataViewModel]), Error> in
                guard let self = self else {
                    return Fail(error: NSError(domain: "", code: -1)).eraseToAnyPublisher()
                }

                self.overallTaskPendingCount = totalTaskPending
                self.handelRedDotView()

                if currenWorkSpaceId != 0 {
                    let workspace = workspaces.first { $0.id == currenWorkSpaceId }
                    NotificationCenter.default.post(name: .workspaceSelectedNotification, object: workspace)
                    HpGlobal.shared.selectedWorkspace = workspace
                } else if let first = workspaces.first {
                    currenWorkSpaceId = first.id
                    NotificationCenter.default.post(name: .workspaceSelectedNotification, object: first)
                    HpGlobal.shared.selectedWorkspace = first
                } else {
                    self.openInitialWorkspaceScreen()
                }

                // Assuming getHomeStatusListPublisher() is error-free
                return self.getHomeStatusListPublisher()
                    .flatMap { _ in
                        self.getTasksPublisher(
                            listFor: self.listFor.rawValue,
                            currenWorkSpaceId: currenWorkSpaceId,
                            searchText: searchText
                        )
                        .map { tasks, count, total in
                            (tasks, count, total, workspaces)
                        }
                    }
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                Global.dismissLoadingSpinner(self.view)
                
                if case .failure(let error) = completion {
                    Common.showAlertMessage(message: error.localizedDescription.localized, alertType: .error, isPreferLightStyle: false)
                }
            } receiveValue: { [weak self] tasks, count, total, workspaces in
                guard let self = self else { return }
                
                self.messageDataCache.removeAll()
                self.arrSection.removeAll()
                self.arrSection = tasks
                self.viewEmpty.isHidden = !tasks.isEmpty
                self.vwButton.isHidden = !tasks.isEmpty

                switch self.listFor {
                case .assignedToMe: self.totalAssignedToMe = count
                case .assignedByMe: self.totalAssignedByMe = count
                }

                self.totalTaskAvailable = total
                self.currentWorkSpace = currenWorkSpaceId == 0
                    ? workspaces.first
                    : workspaces.first(where: { $0.id == currenWorkSpaceId })

                if let selectedWS = self.currentWorkSpace {
                    UserDefaults.standard.set(selectedWS.id, forKey: Constants.kSelectedWorkSpaceId)
                    self.wsTitleLabel.text = selectedWS.workSpaceName
                    if let tabVC = self.tabBarController as? TabBarController {
                        tabVC.showAddTaskButton(selectedWS.isAdmin)
                    }
                }
                
                self.tblView.reloadData()
                if self.tblView.numberOfSections > 0, self.tblView.numberOfRows(inSection: 0) > 0 {
                    let topIndexPath = IndexPath(row: 0, section: 0)
                    self.tblView.scrollToRow(at: topIndexPath, at: .top, animated: false)
                }
                self.updateEmptyTexts()
            }
            .store(in: &cancellables)
    }
}
