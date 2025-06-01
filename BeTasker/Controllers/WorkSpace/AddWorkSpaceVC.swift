//
//  AddWorkSpaceVC.swift
//  teamAlerts
//
//  Created by MAC on 29/01/25.
//

import UIKit
import SDWebImage
import IQKeyboardManagerSwift
import Photos
import AVFoundation


class AddWorkSpaceVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var memberUserCollection: UICollectionView!
    @IBOutlet weak var adminUserCollection: UICollectionView!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var txtFieldName: UITextField!
    @IBOutlet weak var switchDisplayLink: UISwitch!
    @IBOutlet weak var lblLinkHeading: UILabel!
    @IBOutlet weak var lblLinkDescription: UILabel!
    
    // MARK: - Variables
    var arrMemberUsers = [MembersDataViewModel]()
    var arrAdminUsers = [MembersDataViewModel]()
    var selectedAdminUserType = false
    var currentUserId:Int = 0
    var imgData: Data?
    var imagePicker = UIImagePickerController()
    private var returnKeyHandler : IQKeyboardReturnKeyHandler!
    weak var delegate: PrClose?
    var workSpaceId: Int?
    var workSpaceName: String?
    var workSpaceData: WorkSpaceDataViewModel?
    var deletedImageIds = [String]()
    var receivedFileName: String?
    var taskId: Int?
    var tabBarVC: UITabBarController?
    var selectedIndex = 0
    var selectedUserIndex = 0
    
    // MARK: - View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async { [self] in
            btnSave.applyShadow(radius: 3, opacity: 0.1, offset: CGSize(width: 0.0, height: 3.0))
        }
        
        self.lblLinkHeading.text = "Demander un lien externe".localized
        self.lblLinkDescription.text = "Donnez la possibilité de renseigner une URL lors de la création d’une mission.".localized
        
        returnKeyHandler = IQKeyboardReturnKeyHandler(controller: self)
        returnKeyHandler.lastTextFieldReturnKeyType = UIReturnKeyType.done
        if let workSpaceId {
            allAPIs()
        } else {
            //addAddTypeUserMember()
            self.GetMembers(shouldShowLoader: true)
        }
    }
    
    func addAddTypeUserMember() {
        self.autoAddCurrentUserAsFirstAdmin()
        var memberObj = MembersDataModel()
        memberObj.isAddType = true
        self.arrMemberUsers.append(MembersDataViewModel(data: memberObj))
        self.memberUserCollection.reloadData()
        
        var adminObj = MembersDataModel()
        adminObj.isAddType = true
        self.arrAdminUsers.append(MembersDataViewModel(data: adminObj))
        self.adminUserCollection.reloadData()
    }
    
    func autoAddCurrentUserAsFirstAdmin() {
        if let currentProfileData = HpGlobal.shared.userInfo
        {
            var mySelfAdmin = MembersDataModel()
            mySelfAdmin.first_name = currentProfileData.firstName
            mySelfAdmin.last_name = currentProfileData.lastName
            mySelfAdmin.id = currentProfileData.userId
            mySelfAdmin.user_id = currentProfileData.userId
            mySelfAdmin.isSelected = true
            mySelfAdmin.profile_pic = currentProfileData.profilePic
            self.arrAdminUsers.append(MembersDataViewModel(data: mySelfAdmin))
            self.currentUserId = currentProfileData.userId
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.setNavigationBarImage(for: nil, color: UIColor.colorFFFFFF000000, txtcolor: UIColor.color191919, requireShadowLine: true, isTans: true)
        
        //self.setNavigationBarImage(color: .white, requireShadowLine: false)
        let backImage = UIImage(named: "down-arrow")!
        setBackButton(isImage: true,image: backImage)
        self.title = workSpaceId == nil ? "Nouvel Espace de travail".localized : workSpaceName
        self.btnSave.setTitle(workSpaceId == nil ? "Ajouter un Espace de travail".localized : "Enregistrer".localized, for: .normal)
        IQKeyboardManager.shared.enableAutoToolbar = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        IQKeyboardManager.shared.enableAutoToolbar = false
    }
    
    override func backBtnTapAction() {
        Global.setVibration()
        //self.tabBarVC?.selectedIndex = 0
        self.view.endEditing(true)
        self.navigationController?.dismiss(animated: true) {
            
        }
    }
    
    // MARK: - Button Action Methods
    @IBAction func btnAddImageAction(_ sender: UIButton) {
        Global.setVibration()
        self.view.endEditing(true)
        let actionSheetControllerIOS8: UIAlertController = UIAlertController(title: Messages.photoMassage, message: nil, preferredStyle: .actionSheet)
        let saveActionButton: UIAlertAction = UIAlertAction(title: Messages.txtCamera, style: .default)
        { void in
            self.checkCameraPermission()
        }
        actionSheetControllerIOS8.addAction(saveActionButton)
        
        let deleteActionButton: UIAlertAction = UIAlertAction(title: Messages.txtGallery, style: .default)
        { void in
            self.checkPhotoLibraryPermission()
        }
        actionSheetControllerIOS8.addAction(deleteActionButton)
        let cancelActionButton: UIAlertAction = UIAlertAction(title: Messages.txtCancel, style: .cancel) { void in
            print("Cancel")
        }
        actionSheetControllerIOS8.addAction(cancelActionButton)
        self.present(actionSheetControllerIOS8, animated: true, completion: nil)
    }
    
    @IBAction func btnSaveTapAction(_ sender: UIButton) {
        Global.setVibration()
        self.view.endEditing(true)
        if Validation.isBlank(for: txtFieldName.text ?? "") {
            Common.showAlertMessage(message: Messages.emptyWorkSpacename, alertType: .error)
            return
        }
        guard self.arrAdminUsers.count > 1 else {
            Common.showAlertMessage(message: "Veuillez sélectionner au moins un utilisateur administrateur.".localized, alertType: .error, isPreferLightStyle: false)
            return
        }
        //        guard self.arrMemberUsers.count > 1 else {
        //            Common.showAlertMessage(message: "Please select atleast one member user.", alertType: .error, isPreferLightStyle: false)
        //            return
        //        }
        if let workSpaceData {
            let selectedMemberUsers = arrMemberUsers.filter({ $0.isSelected }).map({"\($0.id)"}).joined(separator: ",")
            
            let selectedAdminUsers = arrAdminUsers.filter({ $0.isSelected }).map({"\($0.id)"}).joined(separator: ",")
            
            if let imageData = self.imgData {
                self.uploadWorkSpaceImageAndAddUpdate(wsImageData: imageData, name: txtFieldName.text ?? "", memberIds: selectedMemberUsers, adminIds: selectedAdminUsers)
                
            } else {
                self.WorkSpaceAddUpdate(name: txtFieldName.text ?? "", memberIds: selectedMemberUsers, adminIds: selectedAdminUsers, fileName: nil)
            }
        } else {
            //            guard let imageData = self.imgData else {
            //                Common.showAlertMessage(message: "Please select workspace logo.", alertType: .error, isPreferLightStyle: false)
            //                return
            //            }
            let selectedMemberUsers = arrMemberUsers.filter({ $0.isSelected }).map({"\($0.id)"}).joined(separator: ",")
            
            let selectedAdminUsers = arrAdminUsers.filter({ $0.isSelected }).map({"\($0.id)"}).joined(separator: ",")
            
            
            self.uploadWorkSpaceImageAndAddUpdate(wsImageData: imgData, name: txtFieldName.text ?? "", memberIds: selectedMemberUsers, adminIds: selectedAdminUsers)
        }
        
    }
    
    func uploadWorkSpaceImage(wsImageData:Data,completion: @escaping(_ imageFileName: String?)->()) {
        Global.showLoadingSpinner(sender: self.view)
        
        FileViewModel.UploadImage(mediaType: .Image, data: imgData, idx: self.selectedIndex) { (imageRes, idx) in
            DispatchQueue.main.async {
                Global.dismissLoadingSpinner(self.view)
                if let imageRes = imageRes {
                    completion(imageRes.imageName)
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    func uploadWorkSpaceImageAndAddUpdate(wsImageData:Data?, name:String, memberIds:String, adminIds:String) {
        if let wsImageData {
            self.uploadWorkSpaceImage(wsImageData: wsImageData) { imageFileName in
                if let imageFileName {
                    DispatchQueue.main.async {
                        self.WorkSpaceAddUpdate(name: name, memberIds: memberIds, adminIds: adminIds, fileName: imageFileName)
                    }
                }
            }
        } else {
            self.WorkSpaceAddUpdate(name: name, memberIds: memberIds, adminIds: adminIds, fileName: nil)
        }
    }
    
    func WorkSpaceAddUpdate(name: String, memberIds: String, adminIds: String, fileName: String?) {
        var params: [String: Any] = [
            "title": name,
            "administrators_ids": adminIds,
            "member_ids": memberIds,
            "is_display_link": switchDisplayLink.isOn ? 1 : 0,
            "client_secret": Constants.kClientSecret
        ]
        if fileName != nil {
            params["file_name"] = fileName
        }
        if let workSpaceId {
            params["workspaces_id"] = workSpaceId
        }
        Global.showLoadingSpinner(sender: self.view)
        HpAPI.workSpaceCreateUpdate.DataAPI(params: params, shouldShowError: true, shouldShowSuccess: true, key: nil) { (response: Result<GeneralModel, Error>) in
            DispatchQueue.main.async {
                Global.dismissLoadingSpinner(self.view)
                switch response {
                case .success(_):
                    
                    self.navigationController?.dismiss(animated: true, completion: {
                        self.delegate?.closedDelegateAction()
                    })
                    break
                case .failure(_):
                    print("workSpaceCreateUpdate api failed")
                    break
                }
            }
        }
        
    }
    
    
    
}
extension AddWorkSpaceVC: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case memberUserCollection:
            return arrMemberUsers.count
        default:
            return arrAdminUsers.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case memberUserCollection:
            if arrMemberUsers[indexPath.row].isAddType {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddMoreCollectionCell", for: indexPath) as! AddMoreCollectionCell
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UsersViewCollectionCell", for: indexPath) as! UsersViewCollectionCell
                
                cell.removeActionClosure = { [weak self] in
                    self?.arrMemberUsers.remove(at: indexPath.row)
                    self?.memberUserCollection.reloadData()
                }
                
                cell.lblName.text = arrMemberUsers[indexPath.row].fullNameFormatted
                
                let img = #imageLiteral(resourceName: "no-user")
                cell.imgProfile.sd_imageIndicator = SDWebImageActivityIndicator.white
                cell.imgProfile.sd_imageTransition = SDWebImageTransition.fade
                cell.imgProfile.sd_setImage(with: arrMemberUsers[indexPath.row].profilePicURL, placeholderImage: img)
                
                return cell
            }
        default:
            if arrAdminUsers[indexPath.row].isAddType {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddMoreCollectionCell", for: indexPath) as! AddMoreCollectionCell
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UsersViewCollectionCell", for: indexPath) as! UsersViewCollectionCell
                cell.btnCancel.isHidden = false
                if arrAdminUsers[indexPath.row].memberUserId == self.currentUserId
                {
                    cell.btnCancel.isHidden = true
                }
                cell.removeActionClosure = {[weak self] in
                    self?.arrAdminUsers.remove(at: indexPath.row)
                    self?.adminUserCollection.reloadData()
                }
                
                cell.lblName.text = arrAdminUsers[indexPath.row].fullNameFormatted
                
                let img = #imageLiteral(resourceName: "no-user")
                cell.imgProfile.sd_imageIndicator = SDWebImageActivityIndicator.white
                cell.imgProfile.sd_imageTransition = SDWebImageTransition.fade
                cell.imgProfile.sd_setImage(with: arrAdminUsers[indexPath.row].profilePicURL, placeholderImage: img)
                
                return cell
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch collectionView {
        case memberUserCollection:
            if arrMemberUsers[indexPath.row].isAddType {
                self.selectedAdminUserType = false
                self.view.endEditing(true)
                let vc = Constants.Home.instantiateViewController(withIdentifier: "TeamUsersListVC") as! TeamUsersListVC
                vc.isFromWorkSpaceScreen = true
                vc.arrMembers = self.arrMemberUsers.dropLast()
                vc.arrExcludedMembers = self.arrAdminUsers.dropLast() +  self.arrMemberUsers.dropLast()
                vc.delegate = self
                let nvc = UINavigationController(rootViewController: vc)
                nvc.isModalInPresentation = true
                self.present(nvc, animated: true, completion: nil)
            }
        default:
            if arrAdminUsers[indexPath.row].isAddType {
                self.selectedAdminUserType = true
                self.view.endEditing(true)
                let vc = Constants.Home.instantiateViewController(withIdentifier: "TeamUsersListVC") as! TeamUsersListVC
                vc.isFromWorkSpaceScreen = true
                vc.arrMembers = self.arrAdminUsers.dropLast()
                vc.arrExcludedMembers = self.arrMemberUsers.dropLast() +  self.arrAdminUsers.dropLast()
                vc.delegate = self
                let nvc = UINavigationController(rootViewController: vc)
                nvc.isModalInPresentation = true
                self.present(nvc, animated: true, completion: nil)
            }
        }
    }
    
    
}
// MARK: Camera Function
extension AddWorkSpaceVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func checkCameraPermission() {
        let mediaType = AVMediaType.video
        switch AVCaptureDevice.authorizationStatus(for: mediaType) {
            
        case .authorized:
            self.openCamera()
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: mediaType) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.openCamera()
                    } else {
                        self.showCameraPermissionAlert()
                    }
                }
            }
            
        case .restricted, .denied:
            self.showCameraPermissionAlert()
            
        @unknown default:
            assertionFailure("Unknown authorization status".localized)
            self.showCameraPermissionAlert()
        }
    }
    
    func showCameraPermissionAlert() {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: Constants.kAppDisplayName, message: Messages.txtCameraPermission, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: Messages.txtCancel, style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: Messages.txtSetting, style: .cancel, handler: { (error) in
                let url = URL(string: UIApplication.openSettingsURLString)
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url!, options: [:], completionHandler: { (error) in
                    })
                } else {
                    UIApplication.shared.openURL(url!)
                }
            }))
            
            Constants.kAppDelegate.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization({status in
                if status == .authorized {
                    self.openGallary()
                }
            })
        } else if status == .denied {
            self.showPhotoLibraryPermissionAlert()
        } else if status == .authorized {
            self.openGallary()
        }
    }
    
    func showPhotoLibraryPermissionAlert() {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: Constants.kAppDisplayName, message: Messages.txtLibraryPermission, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: Messages.txtCancel, style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: Messages.txtSetting, style: .default, handler: { (error) in
                let url = URL(string: UIApplication.openSettingsURLString)
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url!, options: [:], completionHandler: { (error) in
                    })
                } else {
                    UIApplication.shared.openURL(url!)
                }
            }))
            
            Constants.kAppDelegate.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    func openCamera() {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)) {
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = true
            imagePicker.mediaTypes = ["public.image"]
            imagePicker.delegate = self
            self .present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func openGallary() {
        DispatchQueue.main.async {
            self.imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            self.imagePicker.allowsEditing = true
            self.imagePicker.delegate = self
            self.present(self.imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImage: UIImage?
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImage = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
        }
        self.imgProfile.image = selectedImage!
        self.imgData = selectedImage!.jpegData(compressionQuality: 0.7)
        picker.dismiss(animated: true, completion: nil)
    }
}
//MARK: UITextFieldDelegate
extension AddWorkSpaceVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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
extension AddWorkSpaceVC: PrTeamMember {
    func setSelectedMembers(arrMembers: [MembersDataViewModel]) {
        if self.selectedAdminUserType
        {
            //            self.arrAdminUsers = arrMembers
            self.arrAdminUsers  = self.arrAdminUsers.dropLast() +  arrMembers
            var obj = MembersDataModel()
            obj.isAddType = true
            self.arrAdminUsers.append(MembersDataViewModel(data: obj))
            self.adminUserCollection.reloadData()
        }
        else
        {
            //self.arrMemberUsers = arrMembers
            self.arrMemberUsers  = self.arrMemberUsers.dropLast() +  arrMembers
            var obj = MembersDataModel()
            obj.isAddType = true
            self.arrMemberUsers.append(MembersDataViewModel(data: obj))
            self.memberUserCollection.reloadData()
        }
    }
}

extension AddWorkSpaceVC {
    func allAPIs() {
        
        let gcd = DispatchGroup()
        let queue = DispatchQueue(label: "com.BeTasker.AddTaskAPIs", qos: .background, attributes: .concurrent)
        let semaphore = DispatchSemaphore(value: 1) // Allow 1 concurrent API calls
        //        queue.async(group: gcd) { // Use group parameter to automatically manage enter and leave
        //            gcd.enter()
        //            MembersViewModel.GetMembersList(groupId: 0, page: 1, limit: 10000, sender: self, shouldShowLoader: false) {[weak self] arrMembers in
        //                self?.arrUsers = arrMembers
        //                var obj = MembersDataModel()
        //                obj.isAddType = true
        //                self?.arrUsers.append(MembersDataViewModel(data: obj))
        //                semaphore.signal()
        //                gcd.leave()
        //            }
        //            semaphore.wait() // Wait for semaphore
        //        }
        
        if let workSpaceId {
            queue.async(group: gcd) { // Use group parameter to automatically manage enter and leave
                gcd.enter()
                WorkSpaceViewModel.getWorkSpaceDetails(id: workSpaceId) {[weak self] workSpaceData in
                    if let workSpaceData {
                        self?.workSpaceData = workSpaceData
                    }
                    semaphore.signal()
                    gcd.leave()
                }
            }
            semaphore.wait() // Wait for semaphore
        }
        
        gcd.notify(queue: .main) {
            if let workSpaceData = self.workSpaceData {
                self.txtFieldName.text = workSpaceData.workSpaceName
                self.switchDisplayLink.isOn = workSpaceData.isDisplayLink
                self.imgProfile.sd_imageIndicator = SDWebImageActivityIndicator.white
                self.imgProfile.sd_imageTransition = SDWebImageTransition.fade
                self.imgProfile.sd_setImage(with: workSpaceData.workSpaceLogoURL, placeholderImage: nil)
                self.receivedFileName = workSpaceData.workSpaceFileName
                self.GetMembers(shouldShowLoader: true)
                
            }
            
        }
    }
    func GetMembers(shouldShowLoader: Bool) {
        MembersViewModel.GetMembersList(groupId: 0, page: 1, limit: 10000, sender: self, shouldShowLoader: shouldShowLoader) {[weak self] arrMembers in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if let workSpaceData = self.workSpaceData {
                    var  arrMembers = arrMembers
                    if let currentProfileData = HpGlobal.shared.userInfo
                    {
                        self.currentUserId = currentProfileData.userId
                    }
                    if workSpaceData.administrators_ids.count > 0 {
                        //                        if workSpaceData.administrators_ids.contains(self.currentUserId)
                        //                        {
                        //                            self.autoAddCurrentUserAsFirstAdmin()
                        //                        }
                        for i in 0..<workSpaceData.administrators_ids.count {
                            if let idx = arrMembers.firstIndex(where: {$0.id == workSpaceData.administrators_ids[i]}) {
                                arrMembers[idx].isSelected = true
                                self.arrAdminUsers.append(arrMembers[idx])
                            }
                        }
                    }
                    if workSpaceData.member_ids.count > 0 {
                        for i in 0..<workSpaceData.member_ids.count {
                            if let idx = arrMembers.firstIndex(where: {$0.id == workSpaceData.member_ids[i]}) {
                                arrMembers[idx].isSelected = true
                                self.arrMemberUsers.append(arrMembers[idx])
                            }
                        }
                    }
                    
                    var obj = MembersDataModel()
                    obj.isAddType = true
                    self.arrAdminUsers.append(MembersDataViewModel(data: obj))
                    self.adminUserCollection.reloadData()
                    
                    var obj1 = MembersDataModel()
                    obj1.isAddType = true
                    self.arrMemberUsers.append(MembersDataViewModel(data: obj1))
                    self.memberUserCollection.reloadData()
                }
                else{
                    var  arrMembers = arrMembers
                    if let currentProfileData = HpGlobal.shared.userInfo
                    {
                        self.currentUserId = currentProfileData.userId
                        if let idx = arrMembers.firstIndex(where: {$0.memberUserId == currentProfileData.userId}) {
                            arrMembers[idx].isSelected = true
                            self.arrAdminUsers.append(arrMembers[idx])
                        }
                    }
                    
                    
                    
                    var obj = MembersDataModel()
                    obj.isAddType = true
                    self.arrAdminUsers.append(MembersDataViewModel(data: obj))
                    self.adminUserCollection.reloadData()
                    
                    var obj1 = MembersDataModel()
                    obj1.isAddType = true
                    self.arrMemberUsers.append(MembersDataViewModel(data: obj1))
                    self.memberUserCollection.reloadData()
                }
                
                
            }
        }
    }
    
}
