//
//  ChatVC.swift
//  teamAlerts
//
//  Created by B2Cvertical A++ on 21/01/25.
//

import UIKit
import IQKeyboardManagerSwift
import Firebase
import SDWebImage
import UniformTypeIdentifiers
import QuickLook
import StoreKit

struct Section {
    var title: String
    var arrChatMessage: [ChatViewModel]
}

struct ReplyData {
    var isReplied: Bool
    var selectedChatMessage: ChatViewModel?
    
    init(isReplied: Bool = false, selectedChatMessage: ChatViewModel? = nil) {
        self.isReplied = isReplied
        self.selectedChatMessage = selectedChatMessage
    }
    
    var isEmpty: Bool {
        return isReplied == false && selectedChatMessage == nil
    }
    
    mutating func clear() {
        self = ReplyData()
    }
}

class ChatVC: BaseViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var spacerHeight: NSLayoutConstraint!
    @IBOutlet var viewTopTitle: UIView!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var tfMessage: GrowingTextView!
    @IBOutlet weak var viewTF: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var clnStatus: UICollectionView!
    @IBOutlet weak var taskTitleLabel: UILabel!
    @IBOutlet weak var taskMemberCountLabel: UILabel!
    @IBOutlet weak var viewTopStatus: UIView!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var imgStatusIndicator: UIImageView!
    @IBOutlet weak var archiveBlockView: UIView!
    @IBOutlet weak var btnRestoreArchive: UIButton!
    @IBOutlet weak var lblArchiveDate: UILabel!
    @IBOutlet weak var btnClearMsgText: UIButton!
    @IBOutlet weak var taggingTableView: UITableView!
    @IBOutlet weak var mainTableViewBottom: NSLayoutConstraint!
    @IBOutlet weak var statusCollViewBottom: NSLayoutConstraint!
    @IBOutlet weak var tagTableHeight: NSLayoutConstraint!
   // Reply Overlay UI
    @IBOutlet weak var viewReplyOverlay: UIView!
    @IBOutlet weak var imgReplyUser: UIImageView!
    @IBOutlet weak var lblReplyUser: UILabel!
    @IBOutlet weak var currentReplyType: UIView!
    @IBOutlet weak var btnHideReplyView: UIButton!
    
    // MARK: - Variables
    var sections = [Section]()
    var tabelHeight: CGFloat = 0
    var previousContentHeight: CGFloat = 0
    var contentSizeObserver: NSKeyValueObservation?
    var taskData: TasksViewModel?
    var chatNodeId: String = ""
    var arrStatus: [TaskStatusViewModel] = []
    var chatMessageToModify:ChatViewModel?
    var isfromArchive: Bool = false
    var isTaskAdmin: Bool = false
    var currentStatusToUpdate: TaskStatusViewModel?
    weak var delegate: PrRefreshData?
    var taskId: Int = 0
    var isFromNotification: Bool = false
    var pdfURL: URL?
    var arrTaskMembers: [TempProfileViewModel] = []
    var mentionQuery = String()
    var isMentioning = Bool()
    var allMentionedUsers: [Mention] = []
    var filteredMentionedUsers: [Mention] = []
    private var pendingStatusReloads: [Int: [IndexPath]] = [:]
    private var replyStorage = ReplyData()
    var hasStartedObserving = false
    var loadedMessageKeys: Set<String> = []

    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if isFromNotification && taskId != 0 {
            self.getTaskDetails(taskID: self.taskId)
            Constants.kAppDelegate.removeNotificationsWithTaskId("\(self.taskId)")
        } else {
            setupTheScreenFlow()
            Constants.kAppDelegate.removeNotificationsWithTaskId("\(taskData?.taskId ?? 0)")
        }
        tohandelTagTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.setNavigationBarImage(for: nil, color: UIColor.colorFFFFFF000000, txtcolor: UIColor.color191919, requireShadowLine: true, isTans: true)
        let backImage = UIImage(named: "down-arrow")!
        setBackButton(isImage: true,image: backImage)
        navigationItem.titleView = viewTopTitle
        navigationItem.titleView?.frame = viewTopTitle.frame
        setRightButton(isImage: true, image: #imageLiteral(resourceName: "more"), inset: .zero)
        IQKeyboardManager.shared.enableAutoToolbar = false
        tfMessage.placeholder = "Ajouter un message…".localized
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DispatchQueue.main.async {
            self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 70, right: 0)
            self.tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
        self.markChatAsRead()
        NotificationCenter.default.post(name: .updateTaksList, object: nil)
        IQKeyboardManager.shared.enableAutoToolbar = true
    }
    
    deinit {
        // Invalidate the observer when done
        contentSizeObserver?.invalidate()
    }
    
    override func backBtnTapAction() {
        Global.setVibration()
        self.dismiss(animated: true)
    }
    
    override func rightBtnTapAction(sender: UIButton) {
        Global.setVibration()
        self.showMoreOptions(sender: self.view)
    }
    
    // MARK: - Helper Methods
    func setupTheScreenFlow() {
        setUpTableViewCells()
        setupTheTopTicketStatusView(data: taskData?.taskStatus)
        if isfromArchive || taskData?.isArchivedTask ?? false {
            self.archiveBlockView.isHidden = false
            self.lblArchiveDate.text = "Tache archivée le ".localized + "\(taskData?.formmatedCreatedDate ?? "")." + "\nVous ne pouvez plus commenter.".localized
        } else {
            self.archiveBlockView.isHidden = true
        }
        guard let taskId = taskData?.taskId, taskId > 0 else {
            self.dismiss(animated: true)
            return
        }
        
        chatNodeId = "\(taskId)"
        
        DispatchQueue.main.async {
            self.viewTF.setShadowWithColor(color: .black, opacity: 0.10, offset: CGSize(width: 0, height: 0), radius: 4, viewCornerRadius: 12)
            self.archiveBlockView.setShadowWithColor(color: .black, opacity: 0.10, offset: CGSize(width: 0, height: 0), radius: 4, viewCornerRadius: 0)
            self.btnRestoreArchive.layer.cornerRadius = self.btnRestoreArchive.frame.height / 2
            if self.checkForIsAdmin {
                self.btnRestoreArchive.isHidden = false
            } else {
                self.btnRestoreArchive.isHidden = true
            }
            print("----self.tableView.frame.height---->", self.tableView.frame.height)
            // self.spacerHeight.constant = self.tableView.frame.height - 60
            self.tabelHeight = self.tableView.frame.height - 60
            self.view.layoutIfNeeded()  // Apply the constraint change
        }
        
        setupMembersForTagging()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshChatData), name: .updateTaskChat, object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(handleTaskUpdate(_:)), name: .taskUpdatedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didSwipeToReply(_:)), name: .didSwipeToReply, object: nil)
        
        TaskStatusViewModel.taskStatusList { [weak self] list in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.arrStatus = list
                self.clnStatus.reloadData()
                var pathsToReload: [IndexPath] = []
                for status in list {
                    if let indexPaths = self.pendingStatusReloads[status.id] {
                        pathsToReload.append(contentsOf: indexPaths)
                    }
                }
                self.pendingStatusReloads.removeAll()
                DispatchQueue.main.async {
                    self.tableView.reloadRows(at: pathsToReload, with: .none)
                }
            }
        }
        
        // Observe the content size of the table view
        //        contentSizeObserver = tableView.observe(\.contentSize, options: .new) { [weak self] (tbl, change) in
        //            if tbl == self?.tableView {
        //                self?.adjustMyViewSize()
        //            }
        //        }
        
        self.setupStartView()
        self.handelLatestMessage()
        
        if let taskData {
            self.taskTitleLabel.text = taskData.randomId.0
            if taskData.arrUsers.count > 1 {
                self.taskMemberCountLabel.text = "\(taskData.arrUsers.count) " + "membres".localized
            } else {
                self.taskMemberCountLabel.text = "\(taskData.arrUsers.count) " + "membre".localized
            }
        }
        
    }
    
    func setupStartView() {
        getAllChatMessagesFirebase { [weak self] arrData in
            DispatchQueue.main.async {
                Global.dismissLoadingSpinner(self?.view)
                if arrData.count > 0 {
                    // Step 1: Separate out "taskdescription" type messages
                    let taskDescriptionMessages = arrData.filter { $0.chatType == .taskDescription }
                    let otherMessages = arrData.filter { $0.chatType != .taskDescription }
                    
                    // Step 2: Group other messages by chatDateOnly
                    let groupedDictionary = Dictionary(grouping: otherMessages) { $0.chatDateOnly }
                    
                    let sortedKeys = groupedDictionary.keys.sorted { key1, key2 in
                        guard let date1 = Global.GetFormattedDate(date: key1, outputFormate: "dd MMM yyyy HH:mm:ss", isInputUTC: true, isOutputUTC: false).date,
                              let date2 = Global.GetFormattedDate(date: key2, outputFormate: "dd MMM yyyy HH:mm:ss", isInputUTC: true, isOutputUTC: false).date else {
                            return false
                        }
                        return date1 < date2
                    }
                    
                    // Step 3: Construct the sections array
                    var sections: [Section] = []
                    
                    // First section for taskdescription messages, no title
                    if !taskDescriptionMessages.isEmpty {
                        let sortedDescriptions = taskDescriptionMessages.sorted(by: { $0.chatDateTime < $1.chatDateTime })
                        sections.append(Section(title: "", arrChatMessage: sortedDescriptions))
                    }
                    
                    // Add grouped sections by date //dd MMM yyyy • HH:mm
                    for key in sortedKeys {
                        if let messages = groupedDictionary[key] {
                            let sortedMessages = messages.sorted(by: { $0.chatDateTime < $1.chatDateTime })
                            let title = sortedMessages.first?.chatDateTime.toFormattedDate(dateFormateString: "dd MMM yyyy' · 'HH:mm") ?? ""
                            sections.append(Section(title: title, arrChatMessage: sortedMessages))
                        }
                    }
                    self?.sections = sections
                    self?.markChatAsRead()
                    self?.scrollToBottom()
                    self?.tableView.reloadData()
                } else {
                    self?.sendMessageFireBase(message: "", type: .taskDescription, isFirstMessage: true)
                }
            }
        }
    }
    
    func setUpTableViewCells() {
        self.tableView.register(UINib(nibName: "ChatFileCell", bundle: nil), forCellReuseIdentifier: "ChatFileCell")
        self.tableView.register(UINib(nibName: "ChatFileSenderCell", bundle: nil), forCellReuseIdentifier: "ChatFileSenderCell")
        self.tableView.register(UINib(nibName: "ChatStatusCell", bundle: nil), forCellReuseIdentifier: "ChatStatusCell")
        self.tableView.register(UINib(nibName: "ChatStatusSenderCell", bundle: nil), forCellReuseIdentifier: "ChatStatusSenderCell")
        self.tableView.register(UINib(nibName: "ChatMessageCell", bundle: nil), forCellReuseIdentifier: "ChatMessageCell")
        self.tableView.register(UINib(nibName: "ChatMessageSenderCell", bundle: nil), forCellReuseIdentifier: "ChatMessageSenderCell")
        self.tableView.register(UINib(nibName: "EmojiMessageCell", bundle: nil), forCellReuseIdentifier: "EmojiMessageCell")
        self.tableView.register(UINib(nibName: "EmojiMessageSenderCell", bundle: nil), forCellReuseIdentifier: "EmojiMessageSenderCell")
        self.tableView.register(UINib(nibName: "ChatTaskCell", bundle: nil), forCellReuseIdentifier: "ChatTaskCell")
        self.tableView.register(UINib(nibName: "ChatDocCell", bundle: nil), forCellReuseIdentifier: "ChatDocCell")
        self.tableView.register(UINib(nibName: "ChatDocSenderCell", bundle: nil), forCellReuseIdentifier: "ChatDocSenderCell")
        self.tableView.register(UINib(nibName: "ChatTableHeaderCell", bundle: nil), forCellReuseIdentifier: "ChatTableHeaderCell")
        self.clnStatus.register(UINib(nibName: "StatusCollectionCell", bundle: nil), forCellWithReuseIdentifier: "StatusCollectionCell")
        self.taggingTableView.register(UINib(nibName: "TagMembersTableCell", bundle: nil), forCellReuseIdentifier: "TagMembersTableCell")
    }
    
    @objc func refreshChatData() {
        self.setupStartView()
    }
    
    @objc private func handleTaskUpdate(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let updatedTask = userInfo["updatedTask"] as? TasksViewModel,
              updatedTask.taskId == self.taskData?.taskId else { return }
        self.taskData = updatedTask
    }
    
    @objc private func didSwipeToReply(_ notification: Notification) {
        self.replyStorage.clear()
        guard let cell = notification.object as? UITableViewCell,
              let indexPath = tableView.indexPath(for: cell) else { return }
        Global.setVibration()
        let data = sections[indexPath.section].arrChatMessage[indexPath.row]
        self.setReplyToViewData(data)
        self.replyStorage = ReplyData(isReplied: true, selectedChatMessage: data)
        print("Reached Here")
    }

    
    var checkForIsAdmin: Bool {
        if let data = taskData {
            let profileData = HpGlobal.shared.userInfo
            return data.taskAssignerUserId == profileData?.userId || data.isAdmin
            //login user
        } else {
            return false
        }
    }
    
    func setupMembersForTagging() {
        self.arrTaskMembers = taskData?.arrUsers ?? []
        self.allMentionedUsers = self.arrTaskMembers.map { Mention(id: "\($0.memberId)", displayName: $0.fullNameFormatted, randomId: $0.randomId, profileImage: $0.profilePicURL) }
        self.filteredMentionedUsers = self.allMentionedUsers
    }
    
    func setupTheTopTicketStatusView(data: TaskStatusViewModel?) {
        DispatchQueue.main.async {
            self.lblStatus.text = data?.title
            self.lblStatus.textColor = UIColor.label
            self.imgStatusIndicator.tintColor = data?.colorValue
            self.viewTopStatus.backgroundColor = data?.colorValue.withAlphaComponent(0.1)
        }
    }
    
    func adjustMyViewSize() {
        // Get the content size of the table view
        let currentContentHeight = tableView.contentSize.height
        
        if currentContentHeight != previousContentHeight {
            previousContentHeight = currentContentHeight
            // Update the UIView size
            if sections.count > 0 {
                let diff = self.tabelHeight - currentContentHeight
                if diff >= 0 {
                    self.spacerHeight.constant = diff
                } else {
                    self.spacerHeight.constant = 0
                }
            }
            // Apply changes if using constraints
            view.layoutIfNeeded()
        }
    }
    
    func scrollToBottom() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            if self.sections.count > 0 {
                if (self.sections.last?.arrChatMessage.count ?? 0) > 0 {
                    let indexPath = IndexPath(row: ((self.sections.last?.arrChatMessage.count ?? 0) - 1), section: (self.sections.count - 1))
                    self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                }
            }
        }
    }
    
    func restoreArchivedChat() {
        taskRestoreArchive(taskData: taskData) { [weak self] done in
            DispatchQueue.main.async {
                guard let self = self else { return }
                TasksViewModel.addArchiveTextMessage(chatNodeId: "\(self.taskData?.taskId ?? 0)", isRestore: true)
                self.archiveBlockView.isHidden = true
                NotificationCenter.default.post(name: .updateTaksList, object: nil)
                self.delegate?.refreshData()
            }
        }
    }
    
    func extractUserOnBlankSender(currentIndexSender: Int) -> TempProfileViewModel? {
        let senderData = taskData?.arrUsers.filter({$0.memberId == currentIndexSender}).first
        if senderData != nil {
            return senderData
        } else {
            let selfSenderId = taskData?.taskCreator?.id
            if selfSenderId == currentIndexSender {
                let profileModel = TempProfileModel(id: selfSenderId, member_id: taskData?.taskCreator?.memberUserId, name: taskData?.taskCreator?.fullName, photo: taskData?.taskCreator?.profilePicString)
                return TempProfileViewModel(data: profileModel)
            } else {
                return nil
            }
        }
    }
    
    func getLastSeenByForMessage(at indexPath: IndexPath) -> [TempProfileViewModel] {
        let allMessages: [ChatViewModel] = sections.flatMap { $0.arrChatMessage }
        let globalIndex = globalMessageIndex(for: indexPath)
        let taskMemberIds = taskData?.arrUsers.map { String($0.memberId) } ?? []
        
        guard let userData = HpGlobal.shared.userInfo else { return [] }
        let currentUserId = "\(userData.userId)"
        guard globalIndex < allMessages.count else { return [] }
        
        let currentReaders = Set(allMessages[globalIndex].readBy)
        
        // For last message: show everyone who read it (except current user)
        if globalIndex == allMessages.count - 1 {
            let seenUsers = currentReaders
                .intersection(taskMemberIds)
                .subtracting([currentUserId])
            return taskData?.arrUsers.filter { seenUsers.contains("\($0.memberId)") } ?? []
        }
        
        // For others: check who read this but not the next
        let nextReaders = Set(allMessages[globalIndex + 1].readBy)
        let seenOnlyThis = currentReaders.subtracting(nextReaders)
        let seenUsers = seenOnlyThis
            .intersection(taskMemberIds)
            .subtracting([currentUserId])
        return taskData?.arrUsers.filter { seenUsers.contains("\($0.memberId)") } ?? []
    }
    
    
    func globalMessageIndex(for indexPath: IndexPath) -> Int {
        var index = 0
        for section in 0..<indexPath.section {
            index += sections[section].arrChatMessage.count
        }
        index += indexPath.row
        return index
    }
    
    func openMultiImageZoomScreen(data: [FileViewModel], currentIndex: Int) {
        let zoomGalleryVC = ImageZoomGalleryVC()
        zoomGalleryVC.mediaURLs = data.compactMap {$0.imageURL}
        zoomGalleryVC.currentIndex = currentIndex
        zoomGalleryVC.onEditedImageReceive = { [weak self] image in
            self?.sendDirectImageMessage(image: image)
        }
        let nvc = UINavigationController(rootViewController: zoomGalleryVC)
        //nvc.isModalInPresentation = true
        self.present(nvc, animated: true, completion: nil)
    }
    
    func openDrawingOn(image: UIImage, onDoneAction: ((UIImage) -> Void)?) {
        DispatchQueue.main.async {
            let drawingVC = DrawingVC(image: image, onDoneAction: onDoneAction)
            let navController = UINavigationController(rootViewController: drawingVC)
            navController.modalPresentationStyle = .fullScreen
            self.present(navController, animated: true)
        }
    }
    
    func tohandelTagTableView(show: Bool = false) {
        UIView.animate(withDuration: 0.25) {
            if show {
                self.taggingTableView.isHidden = false
                self.tagTableHeight.constant = 200
                self.mainTableViewBottom.constant = -self.tagTableHeight.constant
                self.statusCollViewBottom.constant = -self.tagTableHeight.constant - 16
            } else {
                self.taggingTableView.isHidden = true
                self.tagTableHeight.constant = 0
                self.mainTableViewBottom.constant = 0
                self.statusCollViewBottom.constant = 16
            }
            self.view.layoutIfNeeded()
        }
    }
    
    func handelLatestMessage() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.getLatestMessage { [weak self] data in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    Global.dismissLoadingSpinner(self.view)
                    if let data = data {
                        if !self.sections.isEmpty {
                            let sectionIndex = (self.sections.count) - 1
                            // Match by timestamp or temporary ID logic
                            if let messageIndex = self.sections[safe: sectionIndex]?.arrChatMessage.firstIndex(where: { vm in
                                return abs(vm.timestamp - (data.timestamp)) < 1000 && vm.chatId == ""
                            }) {
                                self.sections[sectionIndex].arrChatMessage[messageIndex] = data
                            } else {
                                self.addChatNode(chatData: data)
                            }
                        } else {
                            self.addChatNode(chatData: data)
                        }
                        self.scrollToBottom()
                        self.tableView.reloadData()
                        //NotificationCenter.default.post(name: .updateTaksList, object: nil)
                    }
                }
            }
        }
    }
    
    func checkForStatusChange(for screenStatusData: [TaskStatusViewModel], from taskStatusId: Int?) {
        let statusData = screenStatusData.first { $0.id == taskStatusId }
        setupTheTopTicketStatusView(data: statusData)
    }
    
    // MARK: - Button Action Methods
    
    @IBAction func btnCameraAction(_ sender: UIButton) {
        Global.setVibration()
        self.view.endEditing(true)
        self.showFileSelectionSheet()
    }
    
    @IBAction func btnAttachFile_Action(_ sender: UIButton) {
        Global.setVibration()
        self.view.endEditing(true)
        let supportedTypes: [UTType] = [.pdf]
        let importMenu = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes, asCopy: false)
        importMenu.delegate = self
        importMenu.allowsMultipleSelection = false
        importMenu.modalPresentationStyle = .formSheet
        self.present(importMenu, animated: true, completion: nil)
    }
    
    
    @IBAction func btnSend_Action(_ sender: UIButton) {
        Global.setVibration()
        self.view.endEditing(true)
        guard tfMessage.text != "" else {
            Common.showAlertMessage(message: "Veuillez saisir un message".localized, alertType: .error)
            return
        }
        MentionHelper.refreshMentions(in: tfMessage, knownMentions: allMentionedUsers)
        let result = MentionHelper.prepareMessageForSending(from: tfMessage.attributedText, using: allMentionedUsers)
        let messageText = result.message
        let mentionIDs = result.mentions.map { $0.id }
        
        if let chatMessageToModify = self.chatMessageToModify {
            self.updateMessageFireBase(message: messageText, mentionIds: mentionIDs, chatMessage: chatMessageToModify)
        } else {
            self.sendMessageFireBase(message: messageText, mentionIds: mentionIDs, type: .message)
            self.taskChatNotify(message: messageText, mentionIDs: mentionIDs)
        }
        tfMessage.text = ""
        btnSend.tintColor = UIColor.colorE8E8E8
        btnSend.isUserInteractionEnabled = false
        btnClearMsgText.isHidden = true
        if !replyStorage.isEmpty {
            hideReplyOverlay()
            replyStorage.clear()
        }
        self.scrollToBottom()
    }
    
    @IBAction func btnRestoreArchive_Action(_ sender: UIButton) {
        Global.setVibration()
        self.restoreArchivedChat()
    }
    
    @IBAction func btnStatusHistory_Action(_ sender: Any) {
        Global.setVibration()
        guard let popupViewController = Constants.Chat.instantiateViewController(withIdentifier: "HistoryStatusVC") as? HistoryStatusVC else { return }
        popupViewController.isCriticalTask = taskData?.isUrgent ?? false
        popupViewController.arrTaskStatus = self.arrStatus
        popupViewController.taskData = self.taskData
        present(popupViewController, animated: true, completion: nil)
    }
    
    @IBAction func btnClearText_Action(_ sender: UIButton) {
        Global.setVibration()
        self.tfMessage.text = ""
        self.btnClearMsgText.isHidden = true
        self.tohandelTagTableView()
        if chatMessageToModify != nil {
            chatMessageToModify = nil
            self.textViewDidChange(self.tfMessage)
            self.tfMessage.resignFirstResponder()
        }
    }
    
    @IBAction func btnRemoveReplyView_Action(_ sender: UIButton) {
        Global.setVibration()
        self.hideReplyOverlay()
        self.replyStorage.clear()
    }
    
    
    //MARK: - Add to chats 🔥
    func sendMessageFireBase(message: String, mentionIds: [String] = [], pdfName: String? = nil, pdfSize: Double? = nil, files: [[String: Any]] = [], status: TaskStatusViewModel? = nil, type: EnumChatType, isFirstMessage: Bool = false) {
        guard let taskData else { return }
        guard let userData = HpGlobal.shared.userInfo else { return }
        let ref = Constants.firebseReference
        let timestamp = Date().toMillis()
        let autoId = ref.childByAutoId().key ?? "-"
        
        var chatNodeData: [String: Any] = ["chatId": autoId, "message":message, "senderId": userData.userId, "timestamp": timestamp, "isEdited": false, "readBy": ["\(userData.userId)"], "chatType": type.rawValue]
        
        switch type {
        case .taskDescription:
            chatNodeData["senderId"] = taskData.taskCreator?.id
            chatNodeData["arrFiles"] = taskData.arrFileDict
            chatNodeData["taskTitle"] = taskData.title
            chatNodeData["description"] = taskData.description
            chatNodeData["displayLink"] = taskData.displayLink
        case .image:
            chatNodeData["message"] = ""
            chatNodeData["imageURL"] = message
        case .status:
            chatNodeData["arrFiles"] = files
            if let statusId = status?.id {
                chatNodeData["taskStatusId"] = statusId
            }
            if let statustitle = status?.title {
                chatNodeData["taskTitle"] = statustitle
                
            }
            if let colorCode = status?.colorCode {
                chatNodeData["color_code"] = colorCode
                
            }
        case .pdf:
            chatNodeData["message"] = ""
            chatNodeData["imageURL"] = message
            chatNodeData["pdfName"] = pdfName
            chatNodeData["pdfSize"] = pdfSize
        case .message:
            chatNodeData["mentionIds"] = mentionIds
            if !self.replyStorage.isEmpty {
                chatNodeData["replyOf"] = getDataForReply(data: self.replyStorage.selectedChatMessage)
            }
            if !isFirstMessage {
                self.addLocalDataToChatList(chatData: chatNodeData)
            }
        default:
            break
        }
        debugPrint(chatNodeData)
        ref.child(Constants.taskChatNode).child(chatNodeId).child(autoId).updateChildValues(chatNodeData) { err, reference in
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .updateTaksList, object: nil)
            }
        }
    }
    
    func getDataForReply(data: ChatViewModel?) -> [String: Any] {
        guard let chatMessage = data else { return [:] }
        guard let userData = HpGlobal.shared.userInfo else { return [:] }
        
        var chatNodeData: [String: Any] = ["chatId": chatMessage.chatId, "message":chatMessage.message, "senderId": chatMessage.senderId, "timestamp": chatMessage.timestamp, "readBy": ["\(userData.userId)"], "chatType": chatMessage.chatType.rawValue]
        
        switch chatMessage.chatType {
        case .image:
            chatNodeData["message"] = ""
            chatNodeData["imageURL"] = chatMessage.rawImageURL
        case .status:
            chatNodeData["arrFiles"] = chatMessage.arrFileDict
            chatNodeData["taskStatusId"] = chatMessage.taskStatusId
            chatNodeData["taskTitle"] = chatMessage.title
            chatNodeData["color_code"] = chatMessage.colorCode
        case .pdf:
            chatNodeData["message"] = ""
            chatNodeData["imageURL"] = chatMessage.rawImageURL
            chatNodeData["pdfName"] = chatMessage.pdfName
            chatNodeData["pdfSize"] = chatMessage.rawPdfSize
        case .message:
            chatNodeData["mentionIds"] = chatMessage.mentionedUserIds
        default:
            break
        }
        
        return chatNodeData
    }
    
    func updateMessageFireBase(message: String, mentionIds: [String] = [], chatMessage: ChatViewModel, type: EnumChatType = .message) {
        guard let userData = HpGlobal.shared.userInfo else { return }
        let ref = Constants.firebseReference
        
        let chatNodeData: [String: Any] = ["chatId": chatMessage.chatId, "message":message, "senderId": chatMessage.senderId, "timestamp": chatMessage.timestamp, "isEdited": true, "readBy": ["\(userData.userId)"], "mentionIds": mentionIds, "chatType": type.rawValue]
        
        
        ref.child(Constants.taskChatNode).child(chatNodeId).child(chatMessage.chatId).updateChildValues(chatNodeData) { err, reference in
            DispatchQueue.main.async {
                
                var modifiedchatMessage = chatMessage
                modifiedchatMessage.message = message
                self.modifyChatNode(chatData: modifiedchatMessage)
                self.chatMessageToModify = nil
            }
        }
    }
    
    private func markChatAsRead() {
        let ref = Constants.firebseReference
        guard let userData = HpGlobal.shared.userInfo else { return }
        let currentUserId = "\(userData.userId)"
        var currentTaskId = 0
        if isFromNotification && taskId != 0 {
            currentTaskId = taskId
        } else {
            currentTaskId = taskData?.taskId ?? 0
        }
        let allMessages = sections.flatMap { $0.arrChatMessage }
        
        for var message in allMessages {
            let messageId = message.chatId
            // If current user is not in readBy
            if !message.readBy.contains("\(currentUserId)") {
                message.readBy.append("\(currentUserId)")
                
                let readByPath = ref.child(Constants.taskChatNode).child("\(currentTaskId)/\(messageId)/readBy")
                readByPath.setValue(message.readBy) { error, _ in
                    if let error = error {
                        debugPrint("❌ Failed to update readBy for message \(messageId): \(error.localizedDescription)")
                    } else {
                        debugPrint("✅ readBy updated for message \(messageId)")
                    }
                }
            }
        }
    }
    
    
    func deleteMessageFireBase(message: String, chatMessage: ChatViewModel, type: EnumChatType = .message) {
        let ref = Constants.firebseReference
        ref.child(Constants.taskChatNode).child(chatNodeId).child(chatMessage.chatId).removeValue { err, reference in
            DispatchQueue.main.async {
                self.deleteChatNode(chatData: chatMessage, type: type)
            }
        }
    }
    
    func getStatusIdToProceedAfterDeletion() -> Int {
        let arrMessage = self.sections.flatMap { $0.arrChatMessage }
        let allStatusMessages = arrMessage.filter { $0.chatType == .status }
        if allStatusMessages.count != 0 {
            let msgData = allStatusMessages.last
            return msgData?.taskStatusId ?? 1
        } else {
            return 1
        }
    }
    
    //MARK: - Get All Chat messages 🔥
    func getAllChatMessagesFirebase(completion: @escaping(_ data: [ChatViewModel])->()) {
        let ref = Constants.firebseReference
        
        if sections.count == 0 {
            Global.showLoadingSpinner(sender: self.view)
        }
        ref.child(Constants.taskChatNode).child(chatNodeId).observeSingleEvent(of: .value) { snapshot in
            DispatchQueue.main.async {
                Global.dismissLoadingSpinner(self.view)
                if snapshot.exists() {
                    if let resData = snapshot.value as? [String: Any] {
                        do {
                            let dict = resData.map({$0.value})
                            let data = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
                            let arr = try JSONDecoder().decode([ChatModel].self, from: data)
                            print("Showing Count",arr.count)
                            let result = arr.map({ChatViewModel(data: $0)})
                            completion(result.filter{$0.isArchivActionAvailable == false})
                        } catch (let err) {
                            print(err.localizedDescription)
                            completion([])
                        }
                    } else {
                        completion([])
                    }
                } else {
                    completion([])
                }
            }
        }
    }
    
    //MARK: - Get latest message from receiver's end 🔥
    func getLatestMessage(completion: @escaping(_ data: ChatViewModel?)->()) {
        
        let ref = Constants.firebseReference
        
        ref.child(Constants.taskChatNode).child(chatNodeId).queryLimited(toLast: 1) .observe(.childAdded) { [weak self] snapshot in
            if snapshot.exists() {
                guard let self = self,
                      let resData = snapshot.value as? [String: Any] else {
                    completion(nil)
                    return
                }
                if !self.hasStartedObserving {
                    // First childAdded call might be from history — skip it
                    self.hasStartedObserving = true
                    return
                }
                do {
                    let data = try JSONSerialization.data(withJSONObject: resData, options: .prettyPrinted)
                    let chatData = try JSONDecoder().decode(ChatModel.self, from: data)
                    let result = ChatViewModel(data: chatData)
                    if result.chatType == .status && chatData.taskStatusId != 0 {
                        self.checkForStatusChange(for: self.arrStatus, from: chatData.taskStatusId)
                    }
                    completion(result.isArchivActionAvailable == false ? result : nil)
                } catch (let err) {
                    print(err.localizedDescription)
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        }
    }
    
    func addChatNode(chatData: ChatViewModel) {
        let title = "Aujourd'hui".localized
        if let idx = self.sections.firstIndex(where: {$0.title == title}) {
            self.sections[idx].arrChatMessage.append(chatData)
        } else {
            let node = Section(title: title, arrChatMessage: [chatData])
            self.sections.append(node)
        }
    }
    
    func modifyChatNode(chatData: ChatViewModel) {
        for (index, element) in self.sections.enumerated() {
            if let idx = element.arrChatMessage.firstIndex(where: {$0.chatId == chatData.chatId}) {
                self.sections[index].arrChatMessage[idx] = chatData
            }
        }
        self.scrollToBottom()
        self.tableView.reloadData()
    }
    
    func deleteChatNode(chatData: ChatViewModel, type: EnumChatType = .message) {
        self.deleteChatNodefromList(chatData: chatData)
        self.scrollToBottom()
        self.tableView.reloadData()
        if type == .status {
            self.taskStatusUpdate()
        }
    }
    
    func deleteChatNodefromList(chatData: ChatViewModel) {
        for (index, element) in self.sections.enumerated() {
            if let idx = element.arrChatMessage.firstIndex(where: {$0.chatId == chatData.chatId}) {
                self.sections[index].arrChatMessage.remove(at: idx)
                if self.sections[index].arrChatMessage.count == 0 {
                    self.sections.remove(at: index)
                }
            }
        }
    }
    
    func addLocalDataToChatList(chatData: [String: Any]) {
        var chatTempData: [String: Any] = chatData
        chatTempData.removeValue(forKey: "chatId")
        chatTempData["tempId"] = UUID().uuidString
        chatTempData["timestamp"] = Date().toMillis()
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: chatTempData, options: [])
            let chatNode = try JSONDecoder().decode(ChatModel.self, from: jsonData)
            let result = ChatViewModel(data: chatNode)
            self.addChatNode(chatData: result)
        } catch {
            print("Error decoding: \(error)")
        }
    }
    
    private func sendDirectImageMessage(image: UIImage) {
        let imgData = image.jpegData(compressionQuality: 0.5)
        FileViewModel.UploadImage(mediaType: .Image, data: imgData, idx: 0) { [weak self] (imageRes, idx) in
            DispatchQueue.main.async {
                Global.dismissLoadingSpinner(self?.view)
                if let url = imageRes?.imgFullPath {
                    self?.sendMessageFireBase(message: url, type: .image)
                    self?.taskChatNotify(message: "envoyé une image".localized)
                }
            }
        }
    }
    
    private func getStatusTitle(chatNode: ChatViewModel, indexPath: IndexPath) -> String {
        // If status list is empty, queue reload and return fallback
        guard !arrStatus.isEmpty else {
            queueStatusReload(for: chatNode.taskStatusId, at: indexPath)
            return chatNode.title
        }

        if let statusTitle = arrStatus.first(where: { $0.id == chatNode.taskStatusId })?.title {
            return statusTitle
        } else {
            // Status ID not found yet, queue reload
            queueStatusReload(for: chatNode.taskStatusId, at: indexPath)
            return chatNode.title
        }
    }
    
    private func queueStatusReload(for statusId: Int, at indexPath: IndexPath) {
        if pendingStatusReloads[statusId]?.contains(indexPath) != true {
            pendingStatusReloads[statusId, default: []].append(indexPath)
        }
    }
    
    func filterList(query: String) {
        filteredMentionedUsers = allMentionedUsers.filter { $0.displayName.lowercased().contains(query.lowercased()) }
        if filteredMentionedUsers.isEmpty {
            tohandelTagTableView(show: false)
        } else {
            tohandelTagTableView(show: true)
        }
        taggingTableView.reloadData()
    }
}

// MARK: - Camera Function
extension ChatVC {
    
    override func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImage: UIImage?
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImage = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
        }
        picker.dismiss(animated: true)
        openDrawingOn(image: selectedImage ?? UIImage()) { [weak self] image in
            self?.sendDirectImageMessage(image: image)
        }
    }
}

// MARK: - Table View Datasource Methods
extension ChatVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == taggingTableView {
            return 1
        } else {
            return self.sections.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == taggingTableView {
            return filteredMentionedUsers.count
        } else {
            return self.sections[section].arrChatMessage.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == taggingTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TagMembersTableCell", for: indexPath) as! TagMembersTableCell
            cell.configureMember(member: filteredMentionedUsers[indexPath.row])
            return cell
        } else {
            let data = sections[indexPath.section].arrChatMessage[indexPath.row]
            let corners: UIRectCorner = data.isMine ? [.topLeft, .topRight, .bottomLeft] : [.topLeft, .topRight, .bottomRight]
            switch data.chatType {
            case .taskDescription:
                let identifier = "ChatTaskCell"
                let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! ChatTaskCell
                cell.configureCellData(for: data)
                cell.delegate = self
                cell.linkDelegate = self
                cell.seeMoreTapped = { [weak self] in
                    guard let self = self else { return }
                    self.sections[indexPath.section].arrChatMessage[indexPath.row].isExpanded.toggle()
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
                let senderData = extractUserOnBlankSender(currentIndexSender: data.senderId)
                cell.setTheUserData(userData: senderData, messageTime: data.chatDate.dateString)
                return cell
            case .message:
                if data.message.isOnlyEmojis {
                    let identifier = data.isMine ? "EmojiMessageCell" : "EmojiMessageSenderCell"
                    let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! EmojiMessageCell
                    cell.configureCellView(with: data)
                    cell.userCollectionView.semanticContentAttribute = .forceRightToLeft
                    if !data.isMine {
                        let senderData = extractUserOnBlankSender(currentIndexSender: data.senderId)
                        cell.setTheUserData(userData: senderData, messageTime: data.chatTimeOnly)
                    }
                    let seenUsers = getLastSeenByForMessage(at: indexPath)
                    cell.arrMembers = seenUsers
                    return cell
                } else {
                    let identifier = data.isMine ? "ChatMessageCell" : "ChatMessageSenderCell"
                    let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! ChatMessageCell
                    cell.configureCellView(with: data, allmentionedUsers: allMentionedUsers)
                    cell.linkDelegate = self
                    cell.userCollectionView.semanticContentAttribute = .forceRightToLeft
                    DispatchQueue.main.async {
                        cell.vwMessageContent.roundCorners(corners, radius: 13.3)
                    }
                    if !data.isMine {
                        let senderData = extractUserOnBlankSender(currentIndexSender: data.senderId)
                        cell.setTheUserData(userData: senderData, messageTime: data.chatTimeOnly)
                    }
                    if data.hasReply {
                        let senderData = extractUserOnBlankSender(currentIndexSender: data.replyOfMessage?.senderId ?? 0)
                        cell.setTheRepliedToUserData(userData: senderData)
                    }
                    let seenUsers = getLastSeenByForMessage(at: indexPath)
                    cell.arrMembers = seenUsers
                    return cell
                }
            case .image:
                let identifier = data.isMine ? "ChatFileCell" : "ChatFileSenderCell"
                let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! ChatFileCell
                cell.imgFile.image = nil
                cell.imgFile.contentMode = .center
                cell.imgFile.sd_cancelCurrentImageLoad()
                cell.userCollectionView.semanticContentAttribute = .forceRightToLeft
                if let imageDataLocal = data.imageData {
                    cell.imgFile.image = UIImage(data: imageDataLocal)
                    cell.imgFile.contentMode = .scaleAspectFill
                } else {
                    let img = UIImage(named: "img_PlaceHolder")
                    cell.imgFile.sd_imageIndicator = SDWebImageActivityIndicator.gray
                    cell.imgFile.sd_imageTransition = SDWebImageTransition.fade
                    if let url = data.imageURL {
                        cell.imgFile.sd_setImage(with: url, placeholderImage: img) { [weak imgView = cell.imgFile] image, error, _, _ in
                            guard let imgView = imgView else { return }
                            if error != nil || image == nil {
                                imgView.contentMode = .center
                                imgView.image = img
                            } else {
                                imgView.contentMode = .scaleAspectFill
                            }
                        }
                    } else {
                        cell.imgFile.image = img
                        cell.imgFile.contentMode = .center
                    }
                }
                let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleImageLongPress(_:)))
                cell.addGestureRecognizer(longPress)
                if !data.isMine {
                    let senderData = extractUserOnBlankSender(currentIndexSender: data.senderId)
                    cell.setTheUserData(userData: senderData, messageTime: data.chatTimeOnly)
                }
                let seenUsers = getLastSeenByForMessage(at: indexPath)
                cell.arrMembers = seenUsers
                return cell
            case .video:
                let identifier = data.isMine ? "ChatFileCell" : "ChatFileSenderCell"
                let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! ChatFileCell
                cell.userCollectionView.semanticContentAttribute = .forceRightToLeft
                if !data.isMine {
                    let senderData = extractUserOnBlankSender(currentIndexSender: data.senderId)
                    cell.setTheUserData(userData: senderData, messageTime: data.chatTimeOnly)
                }
                let seenUsers = getLastSeenByForMessage(at: indexPath)
                cell.arrMembers = seenUsers
                return cell
            case .pdf:
                let identifier = data.isMine ? "ChatDocCell" : "ChatDocSenderCell"
                let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! ChatDocCell
                DispatchQueue.main.async {
                    cell.viewPdfContent.roundCorners(corners, radius: 13.3)
                }
                cell.userCollectionView.semanticContentAttribute = .forceRightToLeft
                cell.lblFileName.text = data.pdfName
                cell.lblFileSize.text = data.pdfSize
                cell.downloadPDFClosure = { [weak self] in
                    if let pdfURL = data.imageURL {
                        self?.downloadAndPresentPDF(from: pdfURL)
                    }
                }
                let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handlePdfLongPress(_:)))
                cell.addGestureRecognizer(longPress)
                if !data.isMine {
                    let senderData = extractUserOnBlankSender(currentIndexSender: data.senderId)
                    cell.setTheUserData(userData: senderData, messageTime: data.chatTimeOnly)
                }
                let seenUsers = getLastSeenByForMessage(at: indexPath)
                cell.arrMembers = seenUsers
                return cell
            case .status:
                let identifier = data.isMine ? "ChatStatusCell" : "ChatStatusSenderCell"
                let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! ChatStatusCell
                cell.lblStatus.text = self.getStatusTitle(chatNode: data, indexPath: indexPath)
                cell.vwStatus.backgroundColor = data.colorValue
                //cell.lblStatus.text = "❤️ termine creator"
                cell.arrImages = data.arrImages
                cell.delegate = self
                cell.clnView.semanticContentAttribute = data.isMine ? .forceRightToLeft : .forceLeftToRight
                cell.userCollectionView.semanticContentAttribute = .forceRightToLeft
                cell.clnView.isHidden = data.arrImages.count == 0
                if !data.isMine {
                    let senderData = extractUserOnBlankSender(currentIndexSender: data.senderId)
                    cell.setTheUserData(userData: senderData, messageTime: data.chatTimeOnly)
                }
                let seenUsers = getLastSeenByForMessage(at: indexPath)
                cell.arrMembers = seenUsers
                return cell
            }
        }
    }
}

// MARK: - TableView Delegate methods
extension ChatVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == self.tableView {
            if section == 0, let firstSectionMessages = sections.first?.arrChatMessage, !firstSectionMessages.isEmpty {
                return nil // No header view for first section with first cell
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatTableHeaderCell") as! ChatTableHeaderCell
            cell.lblDate.text = sections[section].title
            return cell
        }
        return UIView()
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == self.tableView {
            if section == 0, let firstSectionMessages = sections.first?.arrChatMessage, !firstSectionMessages.isEmpty {
                return 0.1
            }
            return 50
        }
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == taggingTableView {
            return UITableView.automaticDimension
        } else {
            return sections.count > 0 ? UITableView.automaticDimension : 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == taggingTableView {
            Global.setVibration()
            if let text = tfMessage.text {
                let queryToDelete = "@\(mentionQuery)"
                let cursorLocation = tfMessage.selectedRange.location
                let searchRange = NSRange(location: 0, length: cursorLocation)
                if let nsRange = (text as NSString).range(of: queryToDelete, options: .backwards, range: searchRange).toOptional(),
                   let range = Range(nsRange, in: text) {
                    // Delete the text in the found range
                    let mutableAttrText = NSMutableAttributedString(attributedString: tfMessage.attributedText)
                    mutableAttrText.replaceCharacters(in: nsRange, with: "")
                    tfMessage.attributedText = mutableAttrText
                    tfMessage.selectedRange = NSRange(location: nsRange.location, length: 0)
                }
            }
            
            MentionHelper.insertMention(filteredMentionedUsers[indexPath.row], into: tfMessage, allMentions: allMentionedUsers)
            self.tohandelTagTableView(show: false)
            self.mentionQuery = ""
            self.isMentioning = false
        } else {
            let data = sections[indexPath.section].arrChatMessage[indexPath.row]
            switch data.chatType {
            case .taskDescription:
                self.showTaskDescriptionCopy(chatMessage: data)
            case .message:
                self.showChatMessageOptions(chatMessage: data,isFromMessage: true, idx: indexPath.row, sender: self.view)
            case .image:
                let zoomGalleryVC = ImageZoomGalleryVC()
                if let imageurl = data.imageURL {
                    zoomGalleryVC.mediaURLs = [imageurl]
                    zoomGalleryVC.currentIndex = 0
                    zoomGalleryVC.onEditedImageReceive = { [weak self] image in
                        self?.sendDirectImageMessage(image: image)
                    }
                    let nvc = UINavigationController(rootViewController: zoomGalleryVC)
                    self.present(nvc, animated: true, completion: nil)
                }
                break
                
            case .video:break
                
            case .pdf:break
                
            case .status:
                self.showChatMessageOptions(chatMessage: data, idx: indexPath.row, type: .status, sender: self.view)
            }
        }
        
    }
}

// MARK: - Collection View Delegate and Datasource Methods
extension ChatVC: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrStatus.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StatusCollectionCell", for: indexPath) as! StatusCollectionCell
        let data = arrStatus[indexPath.row]
        cell.lblStatusText.text = data.title
        cell.lblStatusText.textColor = UIColor.label
        cell.backView.backgroundColor = data.colorValue.withAlphaComponent(0.5)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let data = arrStatus[indexPath.row]
        addStatusAction(data: data)
    }
    
    func addStatusAction(data: TaskStatusViewModel) {
        Global.setVibration()
        let popupViewController = Constants.Chat.instantiateViewController(withIdentifier: "AddStatusVC") as! AddStatusVC
        popupViewController.taskId = taskData?.taskId
        popupViewController.isPhotoEnabled = taskData?.isPhotoRequired ?? false
        popupViewController.statusData = data
        popupViewController.delegateStatus = self
        self.currentStatusToUpdate = data
        present(popupViewController, animated: true, completion: nil)
    }
}

// MARK: - Collection View DelegateFlow Layout Methods
extension ChatVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = (arrStatus[indexPath.row].title).size(withAttributes: [
            NSAttributedString.Key.font: UIFont(name: Constants.KGraphikMedium, size: 13.0) ?? UIFont.systemFont(ofSize: 13, weight: .medium)
        ])
        return CGSize(width: size.width + 32, height: self.clnStatus.frame.height)
    }
}

// MARK: - Other screen Delegate methods
extension ChatVC: PrTaskStatus, CollectionTableViewCellDelegate, LinkTapDelegate {
    
    func setTaskStatus(files: [[String: Any]], status: TaskStatusViewModel) {
        NotificationCenter.default.post(name: .updateTaksList, object: nil)
        if status.id == 4 { //DONE
            ReviewManager.shared.requestReviewIfAppropriate()
        }
        self.setupTheTopTicketStatusView(data: self.currentStatusToUpdate)
        self.sendMessageFireBase(message: "", files: files, status: status, type: .status)
    }
    
    func didSelectItem(imageData: FileViewModel, arrImageData: [FileViewModel], currentIndex: Int) {
        //self.openImageZoomScreen(data: imageData)
        self.openMultiImageZoomScreen(data: arrImageData, currentIndex: currentIndex)
    }
    
    func didTapLink(url: String) {
        self.showLinkOptions(url: url)
    }
    
}

// MARK: - UItextView Delegate Methods
extension ChatVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let txt = textView.text.trim()
        btnSend.tintColor = txt == "" ? UIColor.colorE8E8E8 : UIColor.color796262
        btnSend.isUserInteractionEnabled = txt != ""
        btnClearMsgText.isHidden = txt == ""
        tfMessage.setNeedsDisplay()
        
        // Mention handling
        if let mention = MentionHelper.getCurrentMentionQuery(textView) {
            let query = mention.query.trimmingCharacters(in: .whitespacesAndNewlines)
            if query.isEmpty {
                filteredMentionedUsers = allMentionedUsers
            } else {
                filteredMentionedUsers = allMentionedUsers.filter {
                    $0.displayName.lowercased().contains(query.lowercased())
                }
            }
            
            tohandelTagTableView(show: !filteredMentionedUsers.isEmpty)
            taggingTableView.reloadData()
            
        } else {
            tohandelTagTableView(show: false)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {

        guard let currentText = tfMessage.text,
                 let stringRange = Range(range, in: currentText) else {
               return false
           }
        
        let newText = currentText.replacingCharacters(in: stringRange, with: text)
        let cursorPosition = newText.distance(from: newText.startIndex, to: stringRange.lowerBound) + text.count
        var lastCharacter: String = " "
        if cursorPosition > 1 {
            let index = newText.index(newText.startIndex, offsetBy: cursorPosition - 1)
            lastCharacter = String(newText[index])
        }
        
        // Detect start of a mention
        if !isMentioning, text == "@", (cursorPosition == 0 || lastCharacter == " " || lastCharacter == "\n") {
            isMentioning = true
            mentionQuery = "" // Start fresh
            tohandelTagTableView(show: true)
            return true
        }
        
        if isMentioning {
            if text == " " {
                isMentioning = false
                mentionQuery = ""
                tohandelTagTableView()
            } else if text.isEmpty { // backspace
                if !mentionQuery.isEmpty {
                    mentionQuery.removeLast()
                    filterList(query: mentionQuery)
                } else {
                    isMentioning = false
                    tohandelTagTableView()
                }
            } else {
                mentionQuery += text
                filterList(query: mentionQuery)
            }
        }
    
        if range.location == 0 && currentText.isEmpty {
            let newString = (tfMessage.text as NSString).replacingCharacters(in: range, with: text) as NSString
            return newString.rangeOfCharacter(from: NSCharacterSet.whitespacesAndNewlines).location != 0
        } else {
            return true
        }
    }
}

// MARK: - UIALERT Methods
extension ChatVC {
    func showLinkOptions(url: String) {
        Global.setVibration()
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let openAction = UIAlertAction(title: "Ouvrir le lien".localized, style: .default, handler: { _ in
            if let link = URL(string: url) {
                UIApplication.shared.open(link)
            }
        })
        alert.addAction(openAction)
        
        let copyAction = UIAlertAction(title: "Copier le link".localized, style: .default, handler: { _ in
            
            UIPasteboard.general.string = url
            Common.showAlertMessage(message: "Lien copié !".localized, alertType: .success, isPreferLightStyle: false)
        })
        alert.addAction(copyAction)
        
        alert.addAction(UIAlertAction.init(title: Messages.txtCancel, style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func showTaskDescriptionCopy(chatMessage: ChatViewModel) {
        Global.setVibration()
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let copyAction = UIAlertAction(title: "Copier le message".localized, style: .default, handler: { _ in
            
            UIPasteboard.general.string = chatMessage.title + "\n" + chatMessage.description
            Common.showAlertMessage(message: "Message copié !".localized, alertType: .success, isPreferLightStyle: false)
        })
        alert.addAction(copyAction)
        
        alert.addAction(UIAlertAction.init(title: Messages.txtCancel, style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showChatMessageOptions(chatMessage: ChatViewModel, isFromMessage: Bool = false, idx: Int, type: EnumChatType = .message, sender: UIView) {
        Global.setVibration()
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if isFromMessage {
            let copyAction = UIAlertAction(title: "Copier le message".localized, style: .default, handler: { _ in
                
                UIPasteboard.general.string = chatMessage.message
                Common.showAlertMessage(message: "Message copié !".localized, alertType: .success, isPreferLightStyle: false)
            })
            alert.addAction(copyAction)
            
            let modifyAction = UIAlertAction(title: "Modifier le message".localized, style: .default, handler: { _ in
                let oldMentions: [Mention] = self.allMentionedUsers.filter {chatMessage.mentionedUserIds.contains("\($0.id)")}
                debugPrint(oldMentions)
                MentionHelper.applyAttributedTextSafely(to: self.tfMessage, message: chatMessage.message, mentions: oldMentions)
                
                self.chatMessageToModify = chatMessage
                self.textViewDidChange(self.tfMessage)
                DispatchQueue.main.async {
                    self.btnClearMsgText.isHidden = false
                    self.tfMessage.becomeFirstResponder()
                }
            })
            alert.addAction(modifyAction)
        }
        
        let deleteAction = UIAlertAction(title: "Supprimer pour tous".localized, style: .destructive, handler: { _ in
            self.deleteMessageFireBase(message: "", chatMessage: chatMessage, type: type)
        })
        alert.addAction(deleteAction)
        
        alert.addAction(UIAlertAction.init(title: Messages.txtCancel, style: .cancel, handler: nil))
        alert.popoverPresentationController?.sourceView = sender
        alert.popoverPresentationController?.sourceRect = sender.bounds
        alert.popoverPresentationController?.permittedArrowDirections = .up
        self.present(alert, animated: true, completion: nil)
    }
    
    func showMoreOptions(sender: UIView) {
        Global.setVibration()
        let alert = UIAlertController(title: taskData?.randomId.0 ?? "", message: nil, preferredStyle: .actionSheet)
        
        let recipientsAction = UIAlertAction(title: "Destinataires".localized, style: .default, handler: { _ in
            self.showMemberList(isTaskAdmin: self.checkForIsAdmin)
        })
        alert.addAction(recipientsAction)
        
        let title = taskData?.taskNotificationEnabled ?? false ? "Désactiver les notifications".localized : "Réactiver les notifications".localized
        let notifyAction = UIAlertAction(title: title, style: .default, handler: { _ in
            let status  = self.taskData?.taskNotificationEnabled ?? false ? 0 : 1
            self.enableTaskNotification(currentStatus: status)
        })
        alert.addAction(notifyAction)
        
        if checkForIsAdmin {
            let modifyOriginAction = UIAlertAction(title: "Modifier l’origine".localized, style: .default, handler: { _ in
                self.editTask(program: self.taskData)
            })
            alert.addAction(modifyOriginAction)
            
            if !self.isfromArchive {
                let activateAction = UIAlertAction(title: "Archiver".localized, style: .default, handler: { _ in
                    self.triggerArchiveAction()
                })
                alert.addAction(activateAction)
            }
            
            let deleteAction = UIAlertAction(title: "Supprimer".localized, style: .destructive, handler: { _ in
                self.triggerDeleteAction()
            })
            alert.addAction(deleteAction)
        }
        
        alert.addAction(UIAlertAction.init(title: Messages.txtCancel, style: .cancel, handler: nil))
        alert.popoverPresentationController?.sourceView = sender
        alert.popoverPresentationController?.sourceRect = sender.bounds
        alert.popoverPresentationController?.permittedArrowDirections = .up
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func handlePdfLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            guard let cell = gestureRecognizer.view as? UITableViewCell,
                  let indexPath = tableView.indexPath(for: cell) else { return }
            
            let item = sections[indexPath.section].arrChatMessage[indexPath.row]
            self.showChatMessageOptions(chatMessage: item, idx: indexPath.row, sender: self.view)
        }
    }
    
    @objc func handleImageLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            guard let cell = gestureRecognizer.view as? UITableViewCell,
                  let indexPath = tableView.indexPath(for: cell) else { return }
            let item = sections[indexPath.section].arrChatMessage[indexPath.row]
            self.showChatMessageOptions(chatMessage: item, idx: indexPath.row, sender: self.view)
            
        }
    }
}

// MARK: - Three Dot Functions
extension ChatVC {
    private func showMemberList(isTaskAdmin: Bool) {
        let vc = Constants.Chat.instantiateViewController(withIdentifier: "TaskMembersListVC") as! TaskMembersListVC
        vc.taskId = self.taskData?.taskId
        vc.taskTitle = self.taskData?.randomId.0
        vc.isTaskAdmin = isTaskAdmin
        let nvc = UINavigationController(rootViewController: vc)
        nvc.isModalInPresentation = true
        self.present(nvc, animated: true, completion: nil)
    }
    
    private func editTask(program: TasksViewModel?) {
        let vc = Constants.Home.instantiateViewController(withIdentifier: "AddTaskVC") as! AddTaskVC
        vc.taskId = program?.taskId
        vc.isFromChat = true
        let nvc = UINavigationController(rootViewController: vc)
        nvc.isModalInPresentation = true
        self.present(nvc, animated: true, completion: nil)
    }
    
    private func triggerArchiveAction() {
        taskCompletion(taskData: taskData) {[weak self] done in
            DispatchQueue.main.async {
                guard let self = self else { return }
                TasksViewModel.addArchiveTextMessage(chatNodeId: "\(self.taskData?.taskId ?? 0)", isRestore: false)
                self.isfromArchive = true
                self.archiveBlockView.isHidden = false
                self.lblArchiveDate.text = "Tache archivée le ".localized + "\(self.taskData?.formmatedCreatedDate ?? "")." + "\nVous ne pouvez plus commenter.".localized
                NotificationCenter.default.post(name: .updateTaksList, object: nil)
            }
        }
    }
    
    private func triggerDeleteAction() {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: Messages.txtDeleteTask, message: Messages.txtDeleteConfirmationTask, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title:  "Supprimer".localized, style: .destructive, handler: { _ in
                self.taskRestoreArchive(taskData: self.taskData, isDelete: true) {[weak self] done in
                    DispatchQueue.main.async { [self] in
                        guard let self = self else { return }
                        self.deleteChildNode()
                        NotificationCenter.default.post(name: .updateTaksList, object: nil)
                        self.dismiss(animated: true)
                    }
                }
            }))
            alert.addAction(UIAlertAction.init(title: Messages.txtCancel, style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
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
    
    func taskRestoreArchive(taskData: TasksViewModel?, isDelete: Bool = false, completion: @escaping(_ done: Bool)->()) {
        guard let taskData = taskData else { return }
        let params: [String: Any] = [
            "task_id": taskData.taskId,
            "client_secret": Constants.kClientSecret,
        ]
        
        Global.showLoadingSpinner(sender: self.view)
        var hdpiApiname = HpAPI.taskArchiveRestore
        if isDelete {
            hdpiApiname = HpAPI.taskArchiveDelete
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
    
    func taskStatusUpdate() {
        guard let id = taskData?.taskId else { return }
        
        let params: [String: Any] = [
            "task_id": id,
            "task_status_id": getStatusIdToProceedAfterDeletion(),
            "client_secret": Constants.kClientSecret
        ]
        
        Global.showLoadingSpinner(sender: self.view)
        TaskStatusViewModel.updateTaskStatus(params: params) { [weak self] arrFiles in
            DispatchQueue.main.async {
                Global.dismissLoadingSpinner(self?.view)
                let data = self?.arrStatus.first(where: { $0.id == self?.getStatusIdToProceedAfterDeletion() })
                self?.setupTheTopTicketStatusView(data: data)
            }
        }
    }
    
    func deleteChildNode() {
        let ref = Constants.firebseReference
        ref.child(Constants.taskChatNode).child(chatNodeId).removeValue { error, _ in
            if let error = error {
                print("Error removing child node: \(error.localizedDescription)")
            } else {
                print("Child node successfully removed")
            }
        }
    }
    
    func taskChatNotify(message: String, mentionIDs: [String] = []) {
        guard let taskData = self.taskData else { return }
        let params: [String: Any] = [
            "task_id": taskData.taskId,
            "message": message,
            "mention_user_id": mentionIDs.joined(separator: ",")
        ]
        
        //Global.showLoadingSpinner(sender: self.view)
        
        HpAPI.chatNotify.DataAPI(params: params, shouldShowError: true, shouldShowSuccess: false, key: nil) { (response: Result<GeneralModel, Error>) in
            DispatchQueue.main.async {
                //Global.dismissLoadingSpinner(self.view)
                switch response {
                case .success(_):
                    debugPrint("Success")
                    break
                case .failure(_):
                    debugPrint("failure")
                    break
                }
            }
        }
    }
    
    func enableTaskNotification(currentStatus: Int) {
        guard let taskData = self.taskData else { return }
        let params: [String: Any] = [
            "task_id": taskData.taskId,
            "is_notification_enable": currentStatus,
        ]
        
        Global.showLoadingSpinner(sender: self.view)
        
        HpAPI.updateTaskNotification.DataAPI(params: params, shouldShowError: true, shouldShowSuccess: true, key: nil) { (response: Result<GeneralModel, Error>) in
            DispatchQueue.main.async {
                Global.dismissLoadingSpinner(self.view)
                switch response {
                case .success(_):
                    debugPrint("Success")
                    self.taskData?.taskNotificationEnabled = (currentStatus != 0) ? true : false
                    break
                case .failure(_):
                    debugPrint("failure")
                    break
                }
            }
        }
    }
    
    private func getTaskDetails(taskID: Int) {
        Global.showLoadingSpinner(sender: self.view)
        TasksViewModel.getTaskDetails(id: taskID, type: "task") { [weak self] taskData in
            DispatchQueue.main.async {
                Global.dismissLoadingSpinner(self?.view)
                if let taskData {
                    self?.taskData = taskData
                    self?.setupTheScreenFlow()
                } else {
                    self?.dismiss(animated: true, completion: {
                        Common.showAlertMessage(message: "Erreur lors de la récupération des détails de la tâche.".localized, alertType: .error)
                    })
                }
            }
            
        }
    }
}

// MARK: - Document Picker Methods
extension ChatVC: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedURL = urls.first else { return }
        
        guard selectedURL.startAccessingSecurityScopedResource() else {
            Common.showAlertMessage(message: "Accès refusé au fichier.".localized, alertType: .error)
            return
        }
        defer {
            selectedURL.stopAccessingSecurityScopedResource()
        }
        
        do {
            let resourceValues = try selectedURL.resourceValues(forKeys: [.fileSizeKey])
            let fileName = selectedURL.lastPathComponent
            let fileSize = resourceValues.fileSize ?? 0
            let fileSizeInMB = Double(fileSize) / (1024 * 1024)
            let roundedSize = Double(round(100 * fileSizeInMB) / 100)
            
            if fileSizeInMB > 20 {
                Common.showAlertMessage(message: "Le fichier sélectionné dépasse 20 Mo.".localized, alertType: .error)
                return
            }
            debugPrint("Imported PDF file \(fileName) at: \(selectedURL) and its size is \(roundedSize) MB")
            handleImportedPDF(selectedURL, docSize: roundedSize, docName: fileName)
        } catch {
            print("Failed to get file size: \(error)")
        }
    }
    
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("view was cancelled")
        controller.dismiss(animated: true, completion: nil)
    }
    
    private func handleImportedPDF(_ url: URL, docSize: Double, docName: String) {
        do {
            let pdfData = try Data(contentsOf: url)
            // ✅ You now have the PDF file as Data
            debugPrint("PDF size in bytes: \(pdfData.count)")
            
            FileViewModel.UploadImage(mediaType: .PDF, data: pdfData, fileName: docName, idx: 0) { (pdfRes, idx) in
                DispatchQueue.main.async {
                    Global.dismissLoadingSpinner(self.view)
                    if let url = pdfRes?.imgFullPath {
                        self.sendMessageFireBase(message: url, pdfName: pdfRes?.imageName, pdfSize: docSize, type: .pdf)
                        self.taskChatNotify(message: "envoyé un fichier".localized)
                    }
                }
            }
        } catch {
            print("Error reading PDF as Data: \(error)")
        }
    }
    
    func downloadAndPresentPDF(from url: URL) {
        let fileName = url.lastPathComponent
        
        // Create BeTasker directory in Documents
        let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let folderURL = documentsDir.appendingPathComponent("BeTasker")
        let finalFileURL = folderURL.appendingPathComponent(fileName)
        
        if !FileManager.default.fileExists(atPath: folderURL.path) {
            try? FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
        }
        
        // If file already exists, open directly
        if FileManager.default.fileExists(atPath: finalFileURL.path) {
            previewPDF(at: finalFileURL)
            return
        }
        
        DispatchQueue.main.async {
            Global.showLoadingSpinner(sender: self.view)
        }
        
        let task = URLSession.shared.downloadTask(with: url) { tempURL, response, error in
            DispatchQueue.main.async {
                Global.dismissLoadingSpinner(self.view)
            }
            
            guard let tempURL = tempURL, error == nil else {
                DispatchQueue.main.async {
                    Common.showAlertMessage(message: "Échec du téléchargement du PDF.".localized, alertType: .error)
                }
                return
            }
            
            do {
                try FileManager.default.moveItem(at: tempURL, to: finalFileURL)
                DispatchQueue.main.async {
                    self.previewPDF(at: finalFileURL)
                }
            } catch {
                DispatchQueue.main.async {
                    Common.showAlertMessage(message: "Impossible de préparer le fichier PDF.".localized, alertType: .error)
                }
            }
        }
        task.resume()
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension ChatVC: QLPreviewControllerDataSource {
    func previewPDF(at url: URL) {
        self.pdfURL = url
        let previewController = QLPreviewController()
        previewController.dataSource = self
        present(previewController, animated: true, completion: nil)
    }
    
    // MARK: QLPreviewControllerDataSource
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return pdfURL! as NSURL
    }
}

// MARK: - Reply View Setup Methods
extension ChatVC {
    
    func showReplyOverlay() {
        if viewReplyOverlay.superview != nil {
            viewReplyOverlay.removeFromSuperview()
        }
        
        viewReplyOverlay.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(viewReplyOverlay, belowSubview: viewTF)
        viewReplyOverlay.applyTopCornersAndShadow()
        
        // Set constraints relative to tfMessage
        NSLayoutConstraint.activate([
            viewReplyOverlay.leadingAnchor.constraint(equalTo: viewTF.leadingAnchor),
            viewReplyOverlay.trailingAnchor.constraint(equalTo: viewTF.trailingAnchor),
            viewReplyOverlay.bottomAnchor.constraint(equalTo: tfMessage.topAnchor,constant: -18),
        ])
    }
    
    func hideReplyOverlay() {
        self.viewReplyOverlay.removeFromSuperview()
    }

    func setReplyToViewData(_ data: ChatViewModel) {
        let senderData = extractUserOnBlankSender(currentIndexSender: data.senderId)
        lblReplyUser.text = senderData?.name
        let img = #imageLiteral(resourceName: "no-user")
        imgReplyUser.sd_imageIndicator = SDWebImageActivityIndicator.gray
        imgReplyUser.sd_imageTransition = SDWebImageTransition.fade
        imgReplyUser.sd_setImage(with: senderData?.profilePicURL, placeholderImage: img)
        configureReplyView(with: data, allmentionedUsers: allMentionedUsers)
    }
    
    private func configureReplyView(with dataModel: ChatViewModel, allmentionedUsers: [Mention]) {
        currentReplyType.subviews.forEach { $0.removeFromSuperview() }
        
        var replyView: UIView
        
        switch dataModel.chatType {
        case .message:
            if dataModel.message.isOnlyEmojis {
                replyView = ReplyEmojiView(dataModel: dataModel)
            } else {
                replyView = ReplyTextView(dataModel: dataModel, allmentionedUsers: allmentionedUsers)
            }
        case .image:
            replyView = ReplyImageView(dataModel: dataModel)
        case .pdf:
            replyView = ReplyFileView(dataModel: dataModel)
        case .status:
            replyView = ReplyStatusView(dataModel: dataModel)
        case .taskDescription:
            replyView = UIView()
        case .video:
            replyView = UIView()
        @unknown default:
            replyView = UIView()
        }
        
        showReplyOverlay()
        replyView.translatesAutoresizingMaskIntoConstraints = false
        currentReplyType.addSubview(replyView)
        
        NSLayoutConstraint.activate([
            replyView.topAnchor.constraint(equalTo: currentReplyType.topAnchor, constant: 1),
            replyView.bottomAnchor.constraint(equalTo: currentReplyType.bottomAnchor, constant: -1),
            replyView.leadingAnchor.constraint(equalTo: currentReplyType.leadingAnchor, constant: 1),
            replyView.trailingAnchor.constraint(equalTo: currentReplyType.trailingAnchor, constant: -1)
        ])
    }
}

extension NSRange {
    func toOptional() -> NSRange? {
        return location != NSNotFound ? self : nil
    }
}
