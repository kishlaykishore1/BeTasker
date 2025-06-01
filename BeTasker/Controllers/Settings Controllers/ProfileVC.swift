//
//  ProfileVC.swift
//  EasyAC
//
//  Created by MAC3 on 03/05/23.
//

import UIKit
import SDWebImage
import Vision

class ProfileVC: BaseViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var viewProfile: UIView!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var premiumContainerView: UIControl!
    @IBOutlet weak var lblRandomId: UILabel!
    
    // MARK: - Variables
    var param: [String: Any] = [:]
    var imgData: Data?
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async { [self] in
            viewProfile.applyShadow(radius: 2, opacity: 0.1, offset: CGSize(width: 0.0, height: 2.0))
        }
        setBackButton(isImage: true, image: #imageLiteral(resourceName: "back").imageWithColor(color: .white) ?? UIImage())
        NotificationCenter.default.addObserver(self, selector: #selector(SetProfileData), name: .updateProfile, object: nil)
        self.isUsingFrontCamera = true
        SetProfileData()
        verifyInAppPurchase()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.prefersLargeTitles = false
        self.setNavigationBarImage(color: .clear, requireShadowLine: false)
    }
    
    override func backBtnTapAction() {
        Global.setVibration()
        self.navigationController?.dismiss(animated: true)
    }
    
    // MARK: - Button Action Methods
    @IBAction func copyRandomIdButtonTapped(_ sender: Any) {
        Global.setVibration()
        UIPasteboard.general.string = lblRandomId.text
        Common.showAlertMessage(message: "ID BeTasker copié !".localized, alertType: .success, isPreferLightStyle: false)
    }
    
    @IBAction func btnViewQR(_ sender: UIButton) {
        Global.setVibration()
        guard let popupViewController = Constants.Profile.instantiateViewController(withIdentifier: "DisplayScannerVC") as? DisplayScannerVC else { return }
        present(popupViewController, animated: true, completion: nil)
    }
    
    @IBAction func btnShareQR(_ sender: UIButton) {
        Global.setVibration()
        let textToShare = Global.shareToConnect()
        let activityVC = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
        activityVC.setValue("Découvre l'app BeTasker".localized, forKey: "Subject")
        self.present(activityVC, animated: true, completion: nil)
    }
    
    @IBAction func addProfilePic_Action(_ sender: UIControl) {
        Global.setVibration()
        //showFileSelectionSheet()
        checkCameraPermission()
    }
    
    
    @IBAction func viewTapAction(_ sender: UIView) {
        Global.setVibration()
        switch sender.tag {
        case 101:
            let vc = Constants.Profile.instantiateViewController(withIdentifier: "MyProgramsVC") as! MyProgramsVC
            vc.isModalInPresentation = true
            guard let getNav = UIApplication.topViewController()?.navigationController else {
                return
            }
            let rootNavView = UINavigationController(rootViewController: vc)
            getNav.present(rootNavView, animated: true, completion: nil)
        case 102:
            if UserDefaults.standard.bool(forKey: Constants.kMemberContactIntroShown) == false {
                let vc = Constants.Profile.instantiateViewController(withIdentifier: "MyContactsIntro") as! MyContactsIntro
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc = Constants.Profile.instantiateViewController(withIdentifier: "MyContactsListVC") as! MyContactsListVC
                self.navigationController?.pushViewController(vc, animated: true)
            }
        case 103:
            if UserDefaults.standard.bool(forKey: Constants.kWorkSpaceIntroShown) == false {
                let vc = Constants.WorkSpace.instantiateViewController(withIdentifier: "WorkSpaceIntroVC") as! WorkSpaceIntroVC
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc = Constants.WorkSpace.instantiateViewController(withIdentifier: "MyWorkSpaceListVC") as! MyWorkSpaceListVC
                self.navigationController?.pushViewController(vc, animated: true)
            }
        case 104:
            let vc = Constants.Profile.instantiateViewController(withIdentifier: "SettingVC") as! SettingVC
            self.navigationController?.pushViewController(vc, animated: true)
        case 105:
            //            if UserDefaults.standard.bool(forKey: Constants.kPlanAddIntroShown) == false {
            //                let vc = Constants.Profile.instantiateViewController(withIdentifier: "EquipmentPlanVC") as! EquipmentPlanVC
            //                self.navigationController?.pushViewController(vc, animated: true)
            //            } else {
            //                let vc = Constants.Profile.instantiateViewController(withIdentifier: "TemplateListVC") as! TemplateListVC
            //                self.navigationController?.pushViewController(vc, animated: true)
            //            }
            break
        case 106:
            if PremiumManager.shared.isPremium {
                Common.showAlertMessage(message: "Vous êtes déjà Premium 💃".localized, alertType: .success, isPreferLightStyle: false)
            } else {
                let vc = Constants.Profile.instantiateViewController(withIdentifier: "SubscriptionVC") as! SubscriptionVC
                vc.delegate = self
                vc.isModalInPresentation = true
                guard let getNav = UIApplication.topViewController()?.navigationController else {
                    return
                }
                let rootNavView = UINavigationController(rootViewController: vc)
                getNav.present(rootNavView, animated: true, completion: nil)
            }
        case 107:
            guard let data = HpGlobal.shared.userInfo else { return }
            let url = HpGlobal.shared.settingsData?.shareInvitation ?? ""
            let textToShare = "\("Voici mon identifiant BeTasker :".localized) \(data.randomId.plain) \n\("Obtenez l'application BeTasker et ajoutez-moi à votre équipe.".localized)\n\(url)"
            let activity = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
            activity.setValue("Découvre l'app BeTasker".localized, forKey: "Subject")
            self.present(activity, animated: true, completion: nil)
        default:
            break
        }
    }
    
    func verifyInAppPurchase() {
        if let userSubscribedProductId = UserDefaults.standard.value(forKey: Constants.userSubscribedProductId) as? String,userSubscribedProductId.count > 0
        {
            IAP.VerifyPurchase(productId: userSubscribedProductId, isRestored: false) { isExpired, isActive in
                
                //                DispatchQueue.main.async { [self] in
                //                    self.premiumContainerView.isHidden = isActive
                //                }
            }
        }
        
    }
}

extension ProfileVC {
    @objc func SetProfileData() {
        if let data = HpGlobal.shared.userInfo {
            lblName.text = data.fullNameFormatted
            lblRandomId.text = data.randomId.withHash
            //lblRegistrationDate.text = "\("Inscription le".localized) \(data.createdOn)"
            let img = #imageLiteral(resourceName: "profile")
            imgProfile.sd_imageIndicator = SDWebImageActivityIndicator.white
            imgProfile.sd_imageTransition = SDWebImageTransition.fade
            imgProfile.sd_setImage(with: data.profilePicURL, placeholderImage: img)
            param = [
                "lc": Constants.lc,
                "dob": data.dob,
                "email": data.email,
                "first_name": data.firstName,
                "last_name": data.lastName,
                "post_for": "editSetting"
            ]
        }
    }
}

// MARK: - Face Detection Methods
extension ProfileVC {
    
    private func faceDetectedSuccessfully(image: UIImage) {
        imgProfile.image = image
        imgData = image.jpegData(compressionQuality: 0.7)
        editProfileData()
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

extension ProfileVC: PrClose {
    func closedDelegateAction() {
        verifyInAppPurchase()
    }
}

// MARK: - Image picker Delegate Methods
extension ProfileVC {
    override func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let image = info[.originalImage] as? UIImage else { return }
        detectFace(in: image)
    }
    
    func editProfileData() {
        DispatchQueue.main.async {
            Global.showLoadingSpinner(sender: self.view)
        }
        
        HpAPI.EDITSETTING.requestUploadProgress(params: param, files: ["profile_pic": imgData], mimeType: .image, shouldShowError: true, shouldShowSuccess: true, key: "data") { (response: Result<ProfileModel, Error>) in
            DispatchQueue.main.async {
                Global.dismissLoadingSpinner()
                switch response {
                case .success(let res):
                    if let userInfo = res.user_info {
                        let userData = ProfileDataViewModel(data: userInfo)
                        HpGlobal.shared.userInfo = userData
                        NotificationCenter.default.post(name: .updateProfile, object: nil)
                    }
                    break
                case .failure(_):
                    break
                }
            }
        }
    }
}
