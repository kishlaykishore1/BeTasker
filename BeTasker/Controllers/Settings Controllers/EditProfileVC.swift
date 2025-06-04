//
//  EditProfileVC.swift
//  EasyAC
//
//  Created by MAC3 on 03/05/23.
//

import UIKit
import IQKeyboardManagerSwift
import Photos
import AVFoundation
import SDWebImage
import Vision

class EditProfileVC: BaseViewController {
    
    //MARK: IBOutlets
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var tfFName: UITextField!
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfDob: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var imgProfile: UIImageView!
    
    // Lets create your picker - Can be IBOutlet too
    lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        if #available(iOS 13.4, *) {
            picker.preferredDatePickerStyle = .wheels
        }
        picker.datePickerMode = .date
        let calendar = Calendar(identifier: .gregorian)
        let date = calendar.date(byAdding: .year, value: -13, to: Date())
        picker.maximumDate = date
        picker.locale = Locale(identifier: Constants.lc)
        return picker
    }()
    
    var dob = ""
    var imgData: Data?
    //MARK: Properties
    private var returnKeyHandler : IQKeyboardReturnKeyHandler!
    //var imagePicker = UIImagePickerController()
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        DispatchQueue.main.async { [self] in
            btnSave.applyShadow(radius: 3, opacity: 0.1, offset: CGSize(width: 0.0, height: 3.0))
        }
        setBackButton(isImage: true)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        if let dob = HpGlobal.shared.userInfo?.dob.dobDate {
            datePicker.date = dob
        }
        
        tfDob.inputView = datePicker
        tfDob.tintColor = .clear
        tfFName.delegate = self
        tfName.delegate = self
        tfEmail.delegate = self
        tfDob.delegate = self
        
        returnKeyHandler = IQKeyboardReturnKeyHandler(controller: self)
        returnKeyHandler.lastTextFieldReturnKeyType = UIReturnKeyType.done
        
        if let data = HpGlobal.shared.userInfo {
            tfFName.text = data.firstName
            tfName.text = data.lastName
            tfDob.text = data.dob.dobString
            dob = data.dobSendable.dobString ?? ""
            tfEmail.text = data.email
            imgProfile.sd_imageIndicator = SDWebImageActivityIndicator.white
            imgProfile.sd_imageTransition = SDWebImageTransition.fade
            imgProfile.sd_setImage(with: data.profilePicURL, placeholderImage: nil)
        }
        self.isUsingFrontCamera = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setNavigationBarImage(color: UIColor.colorFFFFFF000000, txtcolor: UIColor.color262626, requireShadowLine: true)
        self.navigationItem.title = "Modifier mon profil".localized
        
        IQKeyboardManager.shared.enableAutoToolbar = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        IQKeyboardManager.shared.enableAutoToolbar = false
    }
    
    override func backBtnTapAction() {
        Global.setVibration()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnSaveTapAction(_ sender: UIButton) {
        Global.setVibration()
        
        if Validation.isBlank(for: tfFName.text ?? "") {
            Common.showAlertMessage(message: Messages.emptyFirstName, alertType: .error)
            return
        } else if Validation.isBlank(for: tfName.text ?? "") {
            Common.showAlertMessage(message: Messages.emptyLastName, alertType: .error)
            return
        } else if Validation.isBlank(for: tfEmail.text ?? "") {
            Common.showAlertMessage(message: Messages.emptyEmail, alertType: .error)
            return
        } else if !Validation.isValidEmail(for: tfEmail.text ?? "") {
            Common.showAlertMessage(message: Messages.validEmail, alertType: .error)
            return
        }
        EditProfileData()
        //self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnAddImageAction(_ sender: UIButton) {
        Global.setVibration()
        //checkCameraPermission()
        showFileSelectionSheet()
    }
}

//MARK: UITextFieldDelegate
extension EditProfileVC: UITextFieldDelegate {
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
        if textField == tfDob {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = DateFormatter.Style.medium
            dateFormatter.timeStyle = DateFormatter.Style.none
            dateFormatter.dateFormat = "dd MMMM yyyy"
            dateFormatter.locale = Locale(identifier: Constants.lc)
            textField.text = dateFormatter.string(from: datePicker.date)
            dateFormatter.dateFormat = "yyyy-MM-dd"
            self.dob = dateFormatter.string(from: datePicker.date)
            self.view.endEditing(true)
        }
        return true
    }
}

// MARK: - Camera Function
extension EditProfileVC {
    override func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let image = info[.originalImage] as? UIImage else { return }
        detectFace(in: image)
    }
}

// MARK: - Face Detection Methods
extension EditProfileVC {
    
    private func faceDetectedSuccessfully(image: UIImage) {
        imgProfile.image = image
        imgData = image.jpegData(compressionQuality: 0.7)
    }
    
    private func detectFace(in image: UIImage) {
        guard let cgImage = image.cgImage else {
            Common.showAlertMessage(message: "Could not get image data.".localized, alertType: .error)
            return
        }
        
        let request = VNDetectFaceRectanglesRequest { (request, error) in
            DispatchQueue.main.async {
                if let results = request.results as? [VNFaceObservation], !results.isEmpty {
                    self.faceDetectedSuccessfully(image: image)
                } else {
                    Common.showAlertMessage(message: "No face detected. Please retake your selfie.".localized, alertType: .error)
                }
            }
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: .up, options: [:])
        DispatchQueue.global().async {
            try? handler.perform([request])
        }
    }
}

extension EditProfileVC {
    func EditProfileData() {
        let params: [String: Any] = [
            "lc": Constants.lc,
            "dob": dob,
            "email": tfEmail.text ?? "",
            "first_name": tfFName.text ?? "",
            "last_name": tfName.text ?? "",
            "post_for": "editSetting"
        ]
        
        DispatchQueue.main.async {
            Global.showLoadingSpinner(sender: self.view)
        }
        
        HpAPI.EDITSETTING.requestUploadProgress(params: params, files: ["profile_pic": imgData], mimeType: .image, shouldShowError: true, shouldShowSuccess: true, key: "data") { (response: Result<ProfileModel, Error>) in
            DispatchQueue.main.async {
                Global.dismissLoadingSpinner()
                switch response {
                case .success(let res):
                    if let userInfo = res.user_info {
                        let userData = ProfileDataViewModel(data: userInfo)
                        HpGlobal.shared.userInfo = userData
                        NotificationCenter.default.post(name: .updateProfile, object: nil)
                        self.dismiss(animated: true, completion: nil)
                    }
                    break
                case .failure(_):
                    break
                }
            }
        }
    }
}
