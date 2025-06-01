//
//  SignUp5VC.swift
//  EasyAC
//
//  Created by MAC3 on 27/04/23.
//

import UIKit

class SignUp5VC: UIViewController {

    //MARK: IBOutlets
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var lblTermsConditions: TTTAttributedLabel!
    @IBOutlet weak var swtchTC: UISwitch!
    @IBOutlet weak var swtchPP: UISwitch!
    @IBOutlet weak var lblPrivacyPolicy: TTTAttributedLabel!
    @IBOutlet weak var viewBtn: UIView!
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        btnNext.layer.cornerRadius = btnNext.frame.height/2
        // Do any additional setup after loading the view.
        DispatchQueue.main.async { [self] in
            viewBtn.applyShadow(radius: 3, opacity: 0.1, offset: CGSize(width: 0.0, height: 3.0))
        }
        setBackButton(isImage: true)
        
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    override func backBtnTapAction() {
        Global.setVibration()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnNextTapAction(_ sender: UIButton) {
        Global.setVibration()
        
        guard swtchTC.isOn && swtchPP.isOn else {
            Common.showAlertMessage(message: Messages.agreeTCnPP, alertType: .error)
            return
        }
        
        SignUp()
        
        
    }

    func setup() {
        let clrCode = UIColor(named: "Color1E1E1E") ?? .black
        
        let strTCText = "Conditions Générales d'Utilisation".localized
        let strPPText = "Politique de confidentialité".localized
        
        let stringTC = "J’ai lu et j’accepte les".localized + " \(strTCText)"
        let stringPP = "J’ai lu et j’accepte les".localized + " \(strPPText)"
        
        let nsString = stringTC as NSString
        let nsString2 = stringPP as NSString
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1
        
        let fullAttributedString = NSAttributedString(string:stringTC, attributes: [
                                                        NSAttributedString.Key.paragraphStyle: paragraphStyle,
                                                        NSAttributedString.Key.foregroundColor: clrCode.cgColor,
                                                        NSAttributedString.Key.font: UIFont(name: "Graphik-Semibold", size: lblTermsConditions.font.pointSize) ?? UIFont.systemFont(ofSize: lblTermsConditions.font.pointSize, weight: .semibold)])
        lblTermsConditions.attributedText = fullAttributedString
        let fullAttributedString2 = NSAttributedString(string:stringPP, attributes: [
                                                        NSAttributedString.Key.paragraphStyle: paragraphStyle,
                                                        NSAttributedString.Key.foregroundColor: clrCode.cgColor,
                                                        NSAttributedString.Key.font: UIFont(name: "Graphik-Semibold", size: lblPrivacyPolicy.font.pointSize) ?? UIFont.systemFont(ofSize: lblPrivacyPolicy.font.pointSize, weight: .semibold)])
        lblPrivacyPolicy.attributedText = fullAttributedString2
        
        let rangeTC = nsString.range(of: strTCText)
        let rangePP = nsString2.range(of: strPPText)
        
        let ppLinkAttributes: [String: Any] = [
            NSAttributedString.Key.foregroundColor.rawValue: clrCode,
            NSAttributedString.Key.underlineStyle.rawValue: true,
            NSAttributedString.Key.font.rawValue: UIFont.init(name: "Graphik-Semibold", size: lblTermsConditions.font.pointSize) ?? UIFont.systemFont(ofSize: 13)]
        let ppActiveLinkAttributes: [String: Any] = [
            NSAttributedString.Key.foregroundColor.rawValue: clrCode,
            NSAttributedString.Key.underlineStyle.rawValue: true,
            NSAttributedString.Key.font.rawValue: UIFont(name: "Graphik-Semibold", size: lblTermsConditions.font.pointSize) ?? UIFont.systemFont(ofSize: 13)]
        
        lblTermsConditions.activeLinkAttributes = ppActiveLinkAttributes
        lblTermsConditions.linkAttributes = ppLinkAttributes
        lblPrivacyPolicy.activeLinkAttributes = ppActiveLinkAttributes
        lblPrivacyPolicy.linkAttributes = ppLinkAttributes
        
        let urlTC = URL(string: "action://TC")!
        let urlPP = URL(string: "action://PP")!
        lblTermsConditions.addLink(to: urlTC, with: rangeTC)
        lblTermsConditions.delegate = self
        
        lblPrivacyPolicy.addLink(to: urlPP, with: rangePP)
        lblPrivacyPolicy.delegate = self
    }
    
}

//MARK: TTTAttributedLabelDelegate
extension SignUp5VC: TTTAttributedLabelDelegate {
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        Global.setVibration()
        
        let vc = Constants.Main.instantiateViewController(withIdentifier: "WebViewVC") as! WebViewVC
        if url.absoluteString == "action://TC" {
            vc.titleString = "Conditions Générales d'Utilisation".localized
            vc.url = HpGlobal.shared.settingsData?.termsCondition ?? ""
        } else if url.absoluteString == "action://PP" {
            vc.titleString = "Politique de confidentialité".localized
            vc.url = HpGlobal.shared.settingsData?.confidentiality ?? ""
        }
        guard let getNav = UIApplication.topViewController()?.navigationController else {
            return
        }
        let rootNavView = UINavigationController(rootViewController: vc)
        getNav.present(rootNavView, animated: true, completion: nil)
    }
}

extension SignUp5VC {
    func SignUp() {
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
            "profile_pic": "",
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
