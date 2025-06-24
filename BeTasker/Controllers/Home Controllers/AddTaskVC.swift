//
//  AddTaskVC.swift
//  teamAlerts
//
//  Created by B2Cvertical A++ on 25/11/24.
//

import UIKit
import IQKeyboardManagerSwift
import SDWebImage
import Combine

class AddTaskVC: BaseViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var txtDescription: GrowingTextView!
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var switchPhotos: UISwitch!
    @IBOutlet weak var switchCritical: UISwitch!
    @IBOutlet weak var switchMessage: UISwitch!
    @IBOutlet weak var clnPhotoes: UICollectionView!
    @IBOutlet weak var clnUsers: UICollectionView!
    @IBOutlet weak var vwSliderContainerView: SlideToSendContainerView!
    @IBOutlet weak var vwScheduleTask: UIView!
    @IBOutlet weak var txtLinks: UITextField!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var workSpacetitleLabel: UILabel!
    @IBOutlet weak var descriptionHeight: NSLayoutConstraint!
    @IBOutlet weak var linkView: UIView!
    @IBOutlet weak var linkViewBottom: NSLayoutConstraint! //32
    @IBOutlet weak var viewWorkSpaceDetails: UIView!
    @IBOutlet weak var viewSelectAll: UIControl!
    
    // MARK: - Properties
    var taskId: Int?
    var taskData: TasksViewModel?
    var tabBarVC: UITabBarController?
    var arrImages = [ImageModel?]()
    var selectedIndex = 0
    var selectedUserIndex = 0
    var arrUsers = [MembersDataViewModel]()
    var deletedImageIds = [String]()
    var isopenedFromMyProgramVC = false
    var isFromPeogrammimgMenu = false
    var isFromChat = false
    var isFromDuplicateTask = false
    var isFromCameraRoll = false
    var imageFromCameraRoll: UIImage?
    var currentWorkSpace: WorkSpaceDataViewModel?
    var cancellables = Set<AnyCancellable>()
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        arrImages = [nil, nil, nil, nil, nil]
        isEmptyOrNilArray(arrImages) ? (self.clnPhotoes.isHidden = true) : (self.clnPhotoes.isHidden = false)
        if let imageFromCameraRoll, isFromCameraRoll {
            setTheReceivedImage(image: imageFromCameraRoll)
        }
        self.vwSliderContainerView.applyShadow(radius: 3, opacity: 0.1, offset: CGSize(width: 0.0, height: 3.0))
        self.vwScheduleTask.applyShadow(radius: 3, opacity: 0.1, offset: CGSize(width: 0.0, height: 3.0))
        self.clnUsers.register(UINib(nibName: "DestinatairesCollectionCell", bundle: nil), forCellWithReuseIdentifier: "DestinatairesCollectionCell")
        self.clnUsers.register(UINib(nibName: "AddUserCollCell", bundle: nil), forCellWithReuseIdentifier: "AddUserCollCell")
        DispatchQueue.main.async {
            self.btnNext.setShadowWithColor(color: .black, opacity: 0.1, offset: CGSize(width: 0.0, height: 3.0), radius: 3, viewCornerRadius: self.btnNext.frame.height / 2)
            self.vwScheduleTask.layer.cornerRadius = self.vwScheduleTask.frame.height / 2
            self.viewSelectAll.layer.cornerRadius = self.viewSelectAll.frame.height / 2
        }
        
        self.btnNext.isHidden = !self.isFromChat
        self.vwSliderContainerView.isHidden = self.isFromChat
        if isFromPeogrammimgMenu {
            self.vwSliderContainerView.isHidden = true
            self.vwScheduleTask.isHidden = true
            self.viewWorkSpaceDetails.isUserInteractionEnabled = false
            self.btnNext.isHidden = false
            self.btnNext.setTitle("Enregistrer".localized, for: .normal)
        }
        self.vwSliderContainerView.delegate = self
        if let selectedWS = self.currentWorkSpace {
            self.workSpacetitleLabel.text = selectedWS.workSpaceName
            if selectedWS.isDisplayLink {
                self.linkView.isHidden = false
                self.linkViewBottom.constant = 32
            } else {
                self.linkView.isHidden = true
                self.linkViewBottom.constant = 0
            }
        }
        if let taskId {
            allAPIs()
        } else {
            self.getWorkspaceMembers(shouldShowLoader: true)
        }
        
        self.txtTitle.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.setNavigationBarImage(for: nil, color: UIColor.colorFFFFFF000000, txtcolor: UIColor.color191919, requireShadowLine: true, isTans: true)
        let backImage = UIImage(named: "down-arrow")!
        setBackButton(isImage: true,image: backImage)
        self.title = taskId == nil ? "Nouvelle Task".localized : isFromDuplicateTask ? "Nouvelle Task".localized : "Modifier la tâche".localized
        IQKeyboardManager.shared.enableAutoToolbar = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !self.isFromPeogrammimgMenu {
            self.vwSliderContainerView.startAnimating()
        } else if !self.isFromChat {
            self.vwSliderContainerView.startAnimating()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
        if !self.isFromPeogrammimgMenu {
            self.vwSliderContainerView.stopAnimating()
        } else if !self.isFromChat {
            self.vwSliderContainerView.stopAnimating()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        IQKeyboardManager.shared.enableAutoToolbar = false
    }
    
    override func backBtnTapAction() {
        Global.setVibration()
        self.tabBarVC?.selectedIndex = 0
        self.navigationController?.dismiss(animated: true)
    }
    
    // MARK: - Helper Methods
    
    func setBackgroundOfSlider() {
        let isUrgent = self.switchCritical.isOn
        self.vwSliderContainerView.containerBackGroundColor = isUrgent ? UIColor.colorFF0000 : UIColor.colorFFD01E
        let imageName = isUrgent ? "double-arrow-red" : "double-arrow-yellow"
        self.vwSliderContainerView.arrowImage = UIImage(named: imageName)
    }
    
    func undoSlider() {
        self.vwSliderContainerView.resetSliderView()
    }
    
    func isEmptyOrNilArray<T>(_ array: [T?]) -> Bool {
        return array.isEmpty || array.allSatisfy { $0 == nil }
    }
    
    func openDrawingOn(image: UIImage, onDoneAction: ((UIImage) -> Void)?) {
        DispatchQueue.main.async {
            let drawingVC = DrawingVC(image: image, onDoneAction: onDoneAction)
            let navController = UINavigationController(rootViewController: drawingVC)
            navController.modalPresentationStyle = .fullScreen
            self.present(navController, animated: true)
        }
    }
    
    func redirectToChatScreen(taskdata: TasksViewModel) {
        let vc = Constants.Chat.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
        vc.taskData = taskdata
        vc.isFirstDataLoad = true
        self.dismiss(animated: true, completion: {
            let nav = UINavigationController(rootViewController: vc)
            nav.isModalInPresentation = true
            UIApplication.topViewController()?.present(nav, animated: true)
        })
    }
    
    func redirectToSuceessScreen() {
        let vc = Constants.Home.instantiateViewController(withIdentifier: "AddTaskSuccessVC") as! AddTaskSuccessVC
        vc.tabBarVC = self.tabBarVC
        self.dismiss(animated: true, completion: {
            if let nav = UIApplication.topViewController()?.navigationController {
                vc.modalPresentationStyle = .fullScreen
                nav.present(vc, animated: true)
            }
        })
    }
    
    // MARK: - Button Action Methods
    @IBAction func openWorkSpaceListVC(_ sender: UIButton) {
        Global.setVibration()
        self.view.endEditing(true)
        guard let popupViewController = Constants.Home.instantiateViewController(withIdentifier: "WorkSpaceListVC") as? WorkSpaceListVC else { return }
        popupViewController.isOpenedForMyPrograms = self.isopenedFromMyProgramVC
        popupViewController.currentWorkSpace  = self.currentWorkSpace
        popupViewController.delegate = self
        present(popupViewController, animated: true, completion: nil)
    }
    
    @IBAction func btnNextTapped(_ sender: UIButton) {
        self.triggerSendAction()
    }
    
    @IBAction func btnCamera_Action(_ sender: UIControl) {
        Global.setVibration()
        self.checkCameraPermission()
    }
    
    @IBAction func btnGallery_Action(_ sender: UIControl) {
        Global.setVibration()
        self.checkPhotoLibraryPermission()
    }
    
    
    @IBAction func criticalAlertValueChanged(_ sender: UISwitch) {
        if PremiumManager.shared.canCreateUrgentTask() {
            setBackgroundOfSlider()
        } else {
            sender.isOn = false
            PremiumManager.shared.openPremiumScreen()
        }
    }
    
    @IBAction func btnAddAllMembers_Action(_ sender: UIControl) {
        Global.setVibration()
        self.arrUsers = self.arrUsers.map { user in
            var updated = user
            updated.isSelected = true
            return updated
        }
        //let allSelected = arrUsers.allSatisfy { $0.isSelected }
        viewSelectAll.isHidden = true
        self.clnUsers.reloadData()
    }
    
    
    @IBAction func scheduleTask(_ sender: Any) {
        Global.setVibration()
        let vc = Constants.Home.instantiateViewController(withIdentifier: "NewScheduleTaskVC") as! NewScheduleTaskVC
        vc.tabBarVC = self.tabBarVC
        vc.currentWorkSpace = self.currentWorkSpace
        guard let taskTitle = txtTitle.text?.trim(), taskTitle != "" else {
            Common.showAlertMessage(message: "Please add task title.".localized, alertType: .error, isPreferLightStyle: false)
            return
        }
        
        let selectedUsers = arrUsers.filter({ $0.isSelected }).map({"\($0.id)"}).joined(separator: ",")
        guard selectedUsers != "" else {
            Common.showAlertMessage(message: "Please select at least one user.".localized, alertType: .error, isPreferLightStyle: false)
            return
        }
        let imageNames = arrImages.compactMap({$0?.data?.imageName}).joined(separator: ",")
        let deletedIds = deletedImageIds.joined(separator: ",")
        vc.taskTitle = taskTitle
        vc.taskDescription = txtDescription.text.trim()
        vc.isPhotoRequired = switchPhotos.isOn
        vc.isMessageRequired = switchMessage.isOn
        vc.isCriticalNotification = switchCritical.isOn
        vc.selectedImageNames = imageNames
        vc.deletedImageIds = deletedIds
        vc.selectedUserIds = selectedUsers
        vc.taskId = taskId
        vc.taskData = taskData
        vc.dispalyLink = txtLinks.text?.trim()
        vc.scheduleType = taskData?.scheduleType
        vc.isRecurring = taskData?.isRecurring
        vc.startDate = taskData?.startDate
        vc.durationDays = taskData?.durationDays
        vc.isFromChat = self.isFromChat
        vc.isFromDuplicateTask = self.isFromDuplicateTask
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func triggerSendAction() {
        // Perform the "send" action
        print("Action triggered: Sending...")
        
        guard let taskTitle = txtTitle.text?.trim(), taskTitle != "" else {
            Common.showAlertMessage(message: "Please add task title.", alertType: .error, isPreferLightStyle: false)
            undoSlider()
            return
        }
        
        //        if switchPhotos.isOn && isEmptyOrNilArray(arrImages) {
        //            Common.showAlertMessage(message: "Veuillez ajouter au moins une photo.".localized, alertType: .error, isPreferLightStyle: false)
        //            undoSlider()
        //            return
        //        }
        
        let selectedUsers = arrUsers.filter({ $0.isSelected }).map({"\($0.id)"}).joined(separator: ",")
        guard selectedUsers != "" else {
            Common.showAlertMessage(message: "Please select at least one user.", alertType: .error, isPreferLightStyle: false)
            undoSlider()
            return
        }
        let imageNames = arrImages.compactMap({$0?.data?.imageName}).joined(separator: ",")
        let deletedIds = deletedImageIds.joined(separator: ",")
        Global.showLoadingSpinner(sender: self.view)
        let timeZone = TimeZone.current
        debugPrint("Current time zone: \(timeZone.identifier)")
        var params: [String: Any] = [
            "title": taskTitle,
            "description": txtDescription.text.trim(),
            "is_photo": switchPhotos.isOn ? 1 : 0,
            "is_message": switchMessage.isOn ? 1 : 0,
            "client_secret": Constants.kClientSecret,
            "is_notification": switchCritical.isOn ? 1 : 0,
            "member_ids": selectedUsers,
            "delete_image_ids": deletedIds,
            "display_link": txtLinks.text?.trim() ?? "",
            "user_timezone": timeZone.identifier
        ]
        
        if isFromPeogrammimgMenu {
            params["is_schedule"] = taskData?.isScheduled ?? false ? 1 : 0
            params["is_recurring"] = taskData?.isRecurring ?? false ? 1 : 0
        } else if isFromChat {
            params["is_schedule"] = taskData?.isScheduled ?? false ? 1 : 0
            params["is_recurring"] = taskData?.isRecurring ?? false ? 1 : 0
        } else {
            params["is_schedule"] = 0
            params["is_recurring"] = 0
        }
        
        if imageNames != "" {
            params["file_name"] = imageNames
        }
        
        if let taskId {
            if !isFromDuplicateTask {
                params["task_id"] = taskId
            }
        }
        if let selectedWS = self.currentWorkSpace {
            params["workspcae_id"] = selectedWS.id
        } else if isFromPeogrammimgMenu {
            params["workspcae_id"] = self.taskData?.workSpaceId
        } else {
            let currenWorkSpaceId = UserDefaults.standard.integer(forKey: Constants.kSelectedWorkSpaceId)
            if currenWorkSpaceId > 0
            {
                params["workspcae_id"] = currenWorkSpaceId
            }
        }
        HpAPI.taskCreateUpdate.DataAPI(params: params, shouldShowError: true, shouldShowSuccess: false, key: "data") { (response: Result<TasksModel, Error>) in
            DispatchQueue.main.async {
                Global.dismissLoadingSpinner(self.view)
                self.undoSlider()
                switch response {
                case .success(let res):
                    let data = TasksViewModel(data: res)
                    NotificationCenter.default.post(name: .updateTaksList, object: nil)
                    NotificationCenter.default.post(name: .taskUpdatedNotification, object: nil, userInfo: ["updatedTask": data])
                    
                    if self.isFromChat {
                        let newdata = ["taskTitle": data.title, "description": data.description, "displayLink": data.displayLink, "chatType": EnumChatType.taskDescription.rawValue, "isEdited": true, "message": "", "arrFiles": data.arrFileDict]
                        
                        Global().updateTaskDescriptionMessage(for: data.taskId, with: newdata, view: self.view ?? UIView()) { [weak self] result in
                            if result {
                                if self?.isFromChat ?? false {
                                    NotificationCenter.default.post(name: .updateTaskChat, object: nil)
                                }
                            }
                            self?.dismiss(animated: true)
                        }
                    } else if self.isFromPeogrammimgMenu {
                        self.redirectToSuceessScreen()
                    } else {
                        self.redirectToChatScreen(taskdata: data)
                    }
                    break
                case .failure(_):
                    self.undoSlider()
                    break
                }
            }
        }
    }
    
}

extension AddTaskVC: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case clnPhotoes:
            return arrImages.count
        default:
            return arrUsers.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case clnPhotoes:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionCell", for: indexPath) as! PhotoCollectionCell
            
            cell.imgPhoto.image = arrImages[indexPath.row]?.img
            cell.imgCamera.isHidden = true
            cell.vwRemovePhoto.isHidden = arrImages[indexPath.row] == nil
            
            if arrImages[indexPath.row]?.img != nil {
                if arrImages[indexPath.row]?.data == nil {
                    cell.imgPhoto.alpha = 0.2
                    cell.vwLoader.startAnimating()
                    cell.vwRemovePhoto.isHidden = true
                } else {
                    cell.imgPhoto.alpha = 1.0
                    cell.vwLoader.stopAnimating()
                    cell.vwRemovePhoto.isHidden = false
                }
            } else {
                cell.imgPhoto.alpha = 1.0
                cell.vwLoader.stopAnimating()
                cell.vwRemovePhoto.isHidden = true
            }
            
            cell.removePhotoClosure = {[weak self] in
                self?.RemovePhoto(idx: indexPath.row)
            }
            return cell
        default:
            if arrUsers[indexPath.row].isAddType {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddUserCollCell", for: indexPath) as! AddUserCollCell
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DestinatairesCollectionCell", for: indexPath) as! DestinatairesCollectionCell
                cell.configureCell(with: arrUsers[indexPath.row])
                return cell
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case clnPhotoes:
            selectedIndex = indexPath.row
            self.showFileSelectionSheet()
        default:
            if arrUsers[indexPath.row].isAddType {
                let vc = Constants.Home.instantiateViewController(withIdentifier: "TeamUsersListVC") as! TeamUsersListVC

                vc.arrMembers = self.arrUsers.dropLast()
                vc.arrExcludedMembers = self.arrUsers.dropLast()
                vc.delegate = self
                if isFromPeogrammimgMenu || isFromChat {
                    vc.workspaceId = self.taskData?.workSpaceId
                } else {
                    vc.workspaceId = self.currentWorkSpace?.id
                }
                vc.selecetedWorkspace = self.currentWorkSpace
                let nvc = UINavigationController(rootViewController: vc)
                nvc.isModalInPresentation = true
                self.present(nvc, animated: true, completion: nil)
                return
            }
            
            arrUsers[indexPath.item].isSelected.toggle()
            
            if !arrUsers[indexPath.item].isSelected {
                clnUsers.deselectItem(at: indexPath, animated: false)
            }
            
            let allSelected = arrUsers
                .filter { !$0.isAddType } // Exclude 'add type' users
                .allSatisfy { $0.isSelected }
            viewSelectAll.isHidden = allSelected
            clnUsers.reloadData()
        }
    }
    
    func RemovePhoto(idx: Int) {
        guard idx >= 0 && idx < arrImages.count else { return }
        if let id = arrImages[idx]?.data?.id {
            deletedImageIds.append("\(id)")
        }
        arrImages[idx] = nil
        // Shift images to the left to fill the gap
        for i in idx..<(arrImages.count - 1) {
            arrImages[i] = arrImages[i + 1]
        }
        arrImages[arrImages.count - 1] = nil
        clnPhotoes.reloadData()
        isEmptyOrNilArray(arrImages) ? (self.clnPhotoes.isHidden = true) : (self.clnPhotoes.isHidden = false)
    }
}

extension AddTaskVC: SlideToSendDelegate {
    func slideToSendDelegateDidFinish(_ sender: SlideToSendContainerView)
    {
        self.triggerSendAction()
    }
    
}
extension AddTaskVC: PrTeamMember {
    func setSelectedMembers(arrMembers: [MembersDataViewModel]) {
        self.arrUsers = self.arrUsers.dropLast()
        self.arrUsers += arrMembers
        var obj = MembersDataModel()
        obj.isAddType = true
        self.arrUsers.append(MembersDataViewModel(data: obj))
        self.clnUsers.reloadData()
    }
}

// MARK: - Camera Function
extension AddTaskVC {
    
    func setTheReceivedImage(image: UIImage) {
        let imgData = image.jpegData(compressionQuality: 0.5)
        var obj = ImageModel()
        obj.img = image
        if let index = self.arrImages.firstIndex(where: { $0 == nil }) {
            self.arrImages[index] = obj
            self.clnPhotoes.reloadData()
            self.isEmptyOrNilArray(self.arrImages) ? (self.clnPhotoes.isHidden = true) : (self.clnPhotoes.isHidden = false)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if (index + 1) < 5 {
                    let nextIdx = IndexPath(row: (index + 1), section: 0)
                    self.clnPhotoes.scrollToItem(at: nextIdx, at: .centeredHorizontally, animated: true)
                }
            }
            self.uploadSelectedImage(image: image, imgData: imgData ?? Data(), index: index)
        }
    }
    
    override func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImage: UIImage?
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImage = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
        }
        picker.dismiss(animated: true)
        openDrawingOn(image: selectedImage ?? UIImage()) { [weak self] image in
            let imgData = image.jpegData(compressionQuality: 0.5)
            var obj = ImageModel()
            obj.img = image
            if let index = self?.arrImages.firstIndex(where: { $0 == nil }) {
                self?.arrImages[index] = obj
                self?.clnPhotoes.reloadData()
                self?.isEmptyOrNilArray(self?.arrImages as? [ImageModel?] ?? []) ?? false ? (self?.clnPhotoes.isHidden = true) : (self?.clnPhotoes.isHidden = false)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if (index + 1) < 5 {
                        let nextIdx = IndexPath(row: (index + 1), section: 0)
                        self?.clnPhotoes.scrollToItem(at: nextIdx, at: .centeredHorizontally, animated: true)
                    }
                }
                self?.uploadSelectedImage(image: image, imgData: imgData ?? Data(), index: index)
            }
        }
    }
}

extension AddTaskVC: WorkSpaceSelectclose {
    func workSpaceSelectionChange(selectedWS:WorkSpaceDataViewModel) {
        self.currentWorkSpace = selectedWS
        self.workSpacetitleLabel.text = selectedWS.workSpaceName
        self.getWorkspaceMembers(shouldShowLoader: true)
    }
}

// MARK: - Text Field Delegate Methods
extension AddTaskVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

            // Only apply limit to txtTitle
            if textField == txtTitle {
                let currentText = textField.text ?? ""
                guard let stringRange = Range(range, in: currentText) else { return false }

                let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

                if updatedText.count > 100 {
                    Common.showAlertMessage(message: "Limite atteinte, maximum 100 caractères autorisés dans le titre.".localized, alertType: .error, isPreferLightStyle: false)
                    return false
                }
            }

            return true
        }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        
        return true
    }
}

// MARK: - Api Calling For Add task Screen
extension AddTaskVC {
    
    func uploadSelectedImage(image: UIImage, imgData: Data, index: Int) {
        FileViewModel.UploadImage(mediaType: .Image, data: imgData, idx: index) { [weak self] (imageRes, idx) in
            DispatchQueue.main.async {
                Global.dismissLoadingSpinner(self?.view)
                if let imageRes = imageRes {
                    var obj = ImageModel()
                    obj.img = image
                    obj.data = imageRes
                    self?.arrImages[idx] = obj
                    self?.clnPhotoes.reloadData()
                } else {
                    self?.arrImages[idx] = nil
                    self?.clnPhotoes.reloadData()
                }
            }
        }
    }
    
    func SetImageForEdit(idx: Int, imageUrl: URL?) {
        
        SDWebImageManager.shared.loadImage(
            with: imageUrl,
            options: .continueInBackground, // or .highPriority
            progress: nil,
            completed: { [weak self] (image, data, error, cacheType, finished, url) in
                guard let sself = self else {
                    return
                }
                
                if error != nil {
                    // Do something with the error
                    return
                }
                
                guard let img = image else {
                    // No image handle this error
                    return
                }
                // Do something with image
                if idx < sself.arrImages.count {
                    var obj = ImageModel()
                    obj.img = img
                    if sself.taskData?.arrImages.count ?? 0 > idx {
                        obj.data = sself.taskData?.arrImages[idx]
                    }
                    sself.arrImages[idx] = obj
                    DispatchQueue.main.async {
                        sself.clnPhotoes.reloadData()
                    }
                }
            }
        )
    }
    
    func getTaskDetailsPublisher(id: Int, type: String) -> AnyPublisher<TasksViewModel?, Never> {
        return Future { promise in
            TasksViewModel.getTaskDetails(id: id, type: type) { taskData in
                promise(.success(taskData))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func getWorkspaceMembersPublisher(shouldShowLoader: Bool = false) -> AnyPublisher<[MembersDataViewModel], Never> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.success([]))
                return
            }
            
            var workSpaceId: Int?
            if self.isFromPeogrammimgMenu || self.isFromChat {
                workSpaceId = self.taskData?.workSpaceId
            } else {
                workSpaceId = self.currentWorkSpace?.id
            }
            
            MembersViewModel.GetWorkSpaceMembersList(
                workSpaceId: workSpaceId ?? 0,
                page: 1,
                limit: 10000,
                sender: self,
                shouldShowLoader: shouldShowLoader
            ) { members in
                promise(.success(members))
            }
        }
        .eraseToAnyPublisher()
    }
    
    
    func allAPIs() {
        guard let taskId = taskId else { return }
        
        getTaskDetailsPublisher(id: taskId, type: "task")
            .flatMap { [weak self] taskData -> AnyPublisher<([MembersDataViewModel], TasksViewModel), Never> in
                guard let self = self, let taskData = taskData else {
                    return Just(([], TasksViewModel())).eraseToAnyPublisher()
                }
                
                self.taskData = taskData
                
                return self.getWorkspaceMembersPublisher()
                    .map { members in (members, taskData) }
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] workspaceMembers, taskData in
                guard let self = self else { return }
                
                // Convert task members to a Set for fast lookup
                let taskUserIds = Set(taskData.arrUsers.map { $0.id })
                
                // Merge: mark isSelected = true if member exists in taskData
                self.arrUsers = workspaceMembers.map { member in
                    var modifiedMember = member
                    if taskUserIds.contains(member.id) {
                        modifiedMember.isSelected = true
                    }
                    return modifiedMember
                }
                
                // Add the "+ Add" user cell at the end
                var obj = MembersDataModel()
                obj.isAddType = true
                self.arrUsers.append(MembersDataViewModel(data: obj))
                
                self.workSpacetitleLabel.text = taskData.workSpaceTitle
                self.txtTitle.text = taskData.title
                self.txtDescription.text = taskData.description
                self.txtLinks.text = taskData.displayLink
                self.switchPhotos.isOn = taskData.isPhotoRequired
                self.switchMessage.isOn = taskData.isMessageRequired
                self.switchCritical.isOn = taskData.isUrgent
                self.setBackgroundOfSlider()
                
                for (i, imageData) in taskData.arrImages.enumerated() {
                    if i < self.arrImages.count {
                        var obj = ImageModel()
                        obj.img = UIImage(named: "insert-picture-icon")
                        self.arrImages[i] = obj
                        self.clnPhotoes.reloadData()
                    }
                    self.SetImageForEdit(idx: i, imageUrl: imageData.fileURL)
                }
                
                self.clnPhotoes.isHidden = self.isEmptyOrNilArray(self.arrImages)
                self.clnUsers.reloadData()
            }
        
            .store(in: &cancellables)
    }
    
    func getWorkspaceMembers(shouldShowLoader: Bool) {
        var workSpaceId: Int?
        if isFromPeogrammimgMenu || isFromChat {
            workSpaceId = self.taskData?.workSpaceId
        } else {
            workSpaceId = self.currentWorkSpace?.id
        }
        MembersViewModel.GetWorkSpaceMembersList(workSpaceId: workSpaceId ?? 0, page: 1, limit: 10000, sender: self, shouldShowLoader: shouldShowLoader) { [weak self] arrMembers in
            DispatchQueue.main.async {
                self?.arrUsers = arrMembers
                var obj = MembersDataModel()
                obj.isAddType = true
                self?.arrUsers.append(MembersDataViewModel(data: obj))
                self?.clnUsers.reloadData()
            }
        }
    }
}

class UsersViewCollectionCell: UICollectionViewCell {
    
    // MARK:  Outlets
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var viewBack: UIView!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    
    var removeActionClosure: (()->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.btnCancel.setShadowWithColor(color: .black, opacity: 0.22, offset: CGSize(width: 1, height: 1), radius: 1, viewCornerRadius: self.btnCancel.frame.height / 2)
        DispatchQueue.main.async {
            self.viewBack.layer.cornerRadius = self.viewBack.frame.height / 2
        }
    }
    
    func configureCell(with dataModel: MembersDataViewModel) {
        lblName.text = dataModel.fullNameFormatted
        
        let img = #imageLiteral(resourceName: "no-user")
        imgProfile.sd_imageIndicator = SDWebImageActivityIndicator.white
        imgProfile.sd_imageTransition = SDWebImageTransition.fade
        imgProfile.sd_setImage(with: dataModel.profilePicURL, placeholderImage: img)
    }
    
    
    @IBAction func removeItem(_ sender: Any) {
        Global.setVibration()
        removeActionClosure?()
    }
    
}

class AddMoreCollectionCell: UICollectionViewCell {
    
}
