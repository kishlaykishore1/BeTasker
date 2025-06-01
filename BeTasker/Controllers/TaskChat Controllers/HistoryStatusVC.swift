//
//  HistoryStatusVC.swift
//  BeTasker
//
//  Created by kishlay kishore on 20/03/25.
//

import UIKit
import BottomPopup

class HistoryStatusVC: BottomPopupViewController {

    // MARK: - Outlets
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Variables
    private var containerHeight: CGFloat = Constants.kScreenHeight
    override var popupHeight: CGFloat {
        return containerHeight // Use the updated container height
    }
    override var popupTopCornerRadius: CGFloat {
        return 38
    }
    var arrStatus: [ChatStatusHistoryViewModel] = []
    var taskData: TasksViewModel?
    var isCriticalTask: Bool = false
    var arrTaskStatus: [TaskStatusViewModel] = []
   
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        backView.layer.cornerRadius = 24
        backView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        setUpTableViewCells()
        getChatStausNodes()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: - Helper Methods
    func setUpTableViewCells() {
        self.tableView.register(UINib(nibName: "StatusHistoryTableCell", bundle: nil), forCellReuseIdentifier: "StatusHistoryTableCell")
        self.tableView.register(UINib(nibName: "StatusArchiveCell", bundle: nil), forCellReuseIdentifier: "StatusArchiveCell")
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
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
    
//    func openImageZoomScreen(data: FileViewModel) {
//        let imageZoomViewController = Constants.Home.instantiateViewController(withIdentifier: "ImageZoomViewController") as! ImageZoomViewController
//        imageZoomViewController.imageURL = data.imageURL
//        let nvc = UINavigationController(rootViewController: imageZoomViewController)
//        nvc.isModalInPresentation = true
//        self.present(nvc, animated: true, completion: nil)
//    }
    
    func openMultiImageZoomScreen(data: [FileViewModel], currentIndex: Int) {
        let zoomGalleryVC = ImageZoomGalleryVC()
        zoomGalleryVC.mediaURLs = data.compactMap {$0.imageURL}
        zoomGalleryVC.currentIndex = currentIndex
        let nvc = UINavigationController(rootViewController: zoomGalleryVC)
        nvc.isModalInPresentation = true
        self.present(nvc, animated: true, completion: nil)
    }
}

// MARK: - Table View DataSource Methods
extension HistoryStatusVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrStatus.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = arrStatus[indexPath.row]
        if data.isArchive {
            let cell = tableView.dequeueReusableCell(withIdentifier: "StatusArchiveCell", for: indexPath) as! StatusArchiveCell

            cell.lblStatusDate.text = data.statusDateTime.dateString
            if data.archiveId == 0 { // restore
                cell.lblArchive.text = "Restauré par ".localized + data.statusMessage
            } else { // archive
                cell.lblArchive.text = "Archivé par ".localized + data.statusMessage
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "StatusHistoryTableCell", for: indexPath) as! StatusHistoryTableCell
            
            cell.lblStatusDate.text = data.statusDateTime.dateString
            cell.lblStatus.text = data.statusMessage
            cell.viewStatus.backgroundColor = data.colorValue
            cell.arrImages = data.arrImages
            cell.collectionView.isHidden = data.arrImages.count == 0
            cell.delegate = self
            let senderData = extractUserOnBlankSender(currentIndexSender: data.senderId)
            cell.setTheUserData(userData: senderData)
            return cell
        }
    }
}

// MARK: - TableView Deleagtes Methods
extension HistoryStatusVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
}

// MARK: - Fetch Status Data
extension HistoryStatusVC {
    
    func getChatStausNodes() {
        TasksViewModel.getAllChatMessagesFirebase(chatNodeId: "\(taskData?.taskId ?? 0)", isArchiveDataRequired: true) { [weak self] data in
            guard let self = self else { return }
             let filteredData = data.filter { $0.isStatusUpdate == true || $0.isArchivActionAvailable == true }
            var data = filteredData.compactMap { chatData in
                 ChatStatusModel(id: chatData.taskStatusId, statusTitle: chatData.title, timestamp: chatData.timestamp, arrFiles: chatData.arrFiles, senderId: chatData.senderId, color_code: chatData.colorCode, archiveId: chatData.taskArchiveId, isArchive: chatData.isArchivActionAvailable)}
            var newStatusData = ChatStatusModel()
            if self.isCriticalTask {
                let urgentStatusData = self.arrTaskStatus.first(where: { $0.id == 3 })
                newStatusData = ChatStatusModel(id: 1, statusTitle: "🚨 Urgent".localized, timestamp: self.taskData?.timestamp, arrFiles: [], senderId: self.taskData?.taskCreator?.id, color_code: urgentStatusData?.colorCode ?? "CF0000")
            } else {
                let newStatusTaskData = self.arrTaskStatus.first(where: { $0.id == 1 })
                newStatusData = ChatStatusModel(id: 1, statusTitle: "✨ Nouveau".localized, timestamp: self.taskData?.timestamp, arrFiles: [], senderId: self.taskData?.taskCreator?.id, color_code: newStatusTaskData?.colorCode ?? "FF8D1B")
            }
            
            data.append(newStatusData)
             self.arrStatus = data.map{ChatStatusHistoryViewModel(data: $0)}.sorted(by: {$0.chatDateTime > $1.chatDateTime})
             self.tableView.reloadData()
        }
    }
}

extension HistoryStatusVC: CollectionTableViewCellDelegate {
    func didSelectItem(imageData: FileViewModel, arrImageData: [FileViewModel], currentIndex: Int) {
        self.openMultiImageZoomScreen(data: arrImageData, currentIndex: currentIndex)
    }
}
