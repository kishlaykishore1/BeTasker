//
//  SignUp6VC.swift
//  BeTasker
//
//  Created by kishlay kishore on 21/05/25.
//

import UIKit
import AVFoundation
import Vision

class SignUp6VC: BaseViewController {

    // MARK: - Outlets
    @IBOutlet weak var imgBackView: UIView!
    @IBOutlet weak var imgUserFace: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var viewAddImage: UIControl!
    @IBOutlet weak var bottomBtnStack: UIStackView!
    @IBOutlet weak var btnReady: UIButton!
    @IBOutlet weak var btnModifyImage: UIButton!
    
    // MARK: - Variables
    private var selfieImageData: Data?
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        lblUserName.isHidden = true
        bottomBtnStack.isHidden = true
        setupBtnShadow()
        self.isUsingFrontCamera = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        setBackButton(isImage: true)
    }
    
    override func backBtnTapAction() {
        Global.setVibration()
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Helper Methods
    
    private func setupBtnShadow() {
        DispatchQueue.main.async { [self] in
            imgBackView.layer.cornerRadius = imgBackView.frame.height / 2
            imgUserFace.layer.cornerRadius = imgUserFace.frame.height / 2
            
            imgBackView.applyShadow(radius: 3, opacity: 0.1, offset: CGSize(width: 0.0, height: 3.0))
            viewAddImage.applyShadow(radius: 3, opacity: 0.1, offset: CGSize(width: 0.0, height: 3.0))
            btnReady.applyShadow(radius: 3, opacity: 0.1, offset: CGSize(width: 0.0, height: 3.0))
        }
    }
    
    private func faceDetectedSuccessfully(image: UIImage) {
        viewAddImage.isHidden = true
        bottomBtnStack.isHidden = false
        imgUserFace.image = image
        selfieImageData = image.jpegData(compressionQuality: 0.7)
        guard let data = HpGlobal.shared.registrationData else { return }
        lblUserName.isHidden = false
        lblUserName.text = "\(data.firstName) \(data.lastName.prefix(1))."
    }
    
    private func faceNotDetected() {
        viewAddImage.isHidden = false
        lblUserName.isHidden = true
        bottomBtnStack.isHidden = true
        imgUserFace.image = UIImage(named: "no-user")
        selfieImageData = nil
    }
    
// MARK: - Button Action Methods
    
    @IBAction func btnAddImage_Action(_ sender: UIControl) {
        Global.setVibration()
        checkCameraPermission()
    }
    
    @IBAction func btnReady_Action(_ sender: UIButton) {
        Global.setVibration()
        sendProfilePicForUpload()
    }
    
    @IBAction func btnModifyImage_Action(_ sender: UIButton) {
        Global.setVibration()
        checkCameraPermission()
    }
    
}

// MARK: - Face Detection Methods
extension SignUp6VC {
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
                    self.faceNotDetected()
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


// MARK: - Camera Function
extension SignUp6VC {
    
    override func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let image = info[.originalImage] as? UIImage else { return }
        detectFace(in: image)
    }
}

// MARK: - Api Function To register and Upload image
extension SignUp6VC {
    
    private func sendProfilePicForUpload() {
        Global.showLoadingSpinner()
        SignupFileViewModel.uploadSignupImage(data: selfieImageData) { [weak self] (imageRes) in
            DispatchQueue.main.async {
                Global.dismissLoadingSpinner()
                if let name = imageRes?.imageName {
                    self?.signUp(profilePicName: name)
                }
            }
        }
    }
    
    func signUp(profilePicName: String) {
        guard let data = HpGlobal.shared.registrationData else { return }
        var params: [String: Any] = [
            "lc": Constants.lc,
            "dob": data.dateOfBirth,
            "country_code": data.countryPhoneCode,
            //"dudid": data.uid,
            "email": data.email,
            "mobile": data.mobileNumber,
            "device_token": Constants.kFCMToken, //Constants.kDeviceToken
            "role_id": Constants.roleId,
            "national_number": data.nationalNumber,
            "country_flag": data.countryCode,
            "registration_step": 5,
            "device_id": Constants.UDID,
            "client_id": Constants.kClientId,
            //"grant_type": "password",
            "client_secret": Constants.kClientSecret,
            "last_name": data.lastName,
            "first_name": data.firstName,
            "device_type": Constants.kDeviceType,
            "image_name": profilePicName,
            "social_type": data.socialType.rawValue
        ]
        
        switch data.socialType {
        case .Facebook:
            params["facebook_user_id"] = data.uid
        case .Apple:
            params["apple_user_id"] = data.uid
        case .Google:
            params["google_user_id"] = data.uid
        case .DeviceId:
            params["dudid"] = data.uid
        }
        Global.showLoadingSpinner()
        HpAPI.REGISTER.DataAPI(params: params, shouldShowError: true, shouldShowSuccess: false, key: nil) { (response: Result<LoginRegisterModel, Error>) in
            DispatchQueue.main.async {
                Global.dismissLoadingSpinner()
                switch response {
                case .success(let res):
                    let tokenViewModel = LoginRegisterViewModel(data: res)
                    if tokenViewModel.tokenData.accessToken != "" {
                        Constants.saveAPITokens(accessToken: tokenViewModel.tokenData.accessToken, refreshToken: tokenViewModel.tokenData.refreshToken)
                    }
                    if tokenViewModel.profileData.userId > 0 {
                        HpGlobal.shared.userInfo = tokenViewModel.profileData
                    }
                    let vc = Constants.Main.instantiateViewController(withIdentifier: "SignUpSuccessVC") as! SignUpSuccessVC
                    self.navigationController?.pushViewController(vc, animated: true)
                    break
                case .failure(_):
                    break
                }
            }
        }
    }
    
    
        
}
