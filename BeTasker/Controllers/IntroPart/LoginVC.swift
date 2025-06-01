//
//  LoginVC.swift
//  EasyAC
//
//  Created by MAC3 on 26/04/23.
//

import UIKit
import CountryPickerView
import FirebaseAuth
import GoogleSignIn
//import FBSDKLoginKit
import FacebookLogin
import AuthenticationServices
import CoreLocation
import CoreBluetooth
import IQKeyboardManagerSwift

class LoginVC: UIViewController {
    //MARK: IBOutlets
    @IBOutlet weak var viewOuterTelp: UIView!
    @IBOutlet weak var viewApple: UIView!
    @IBOutlet weak var viewGoogle: UIView!
    @IBOutlet weak var viewFb: UIView!
    @IBOutlet weak var viewBtnCont: UIView!
    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var tfPhoneNo: UITextField!
    @IBOutlet weak var btnCountryCode: UIButton!
    //@IBOutlet weak var constMultiplierCenter: NSLayoutConstraint!
    @IBOutlet weak var lblTerms: TTTAttributedLabel!
    
    // MARK: Properties
    let countryPickerView = CountryPickerView()
    var countryPhoneCode: String = "+33"
    var countryFlag = "FR"
    var socialType: SocialType?
    var socialId: String?
    var firstName: String?
    var lastName: String?
    var email: String?
    var profileImageURL: URL?
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
        IQKeyboardManager.shared.enableAutoToolbar = true
        
        // Do any additional setup after loading the view.
        //let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        //view.addGestureRecognizer(tap)
        
        DispatchQueue.main.async { [self] in
            viewOuterTelp.layer.cornerRadius = viewOuterTelp.frame.height / 2
            btnContinue.layer.cornerRadius = btnContinue.frame.height / 2
            btnCountryCode.layer.cornerRadius = btnCountryCode.frame.height / 2
            
            let brdrClr = UIColor.colorE8E8E8
            viewOuterTelp.applyBorder(width: 1, color: brdrClr)
            viewApple.applyBorder(width: 1, color: brdrClr)
            viewGoogle.applyBorder(width: 1, color: brdrClr)
            viewFb.applyBorder(width: 1, color: brdrClr)
            viewBtnCont.applyShadow(radius: 3, opacity: 0.1, offset: CGSize(width: 0.0, height: 3.0))
        }
        
        countryPickerView.delegate = self
        countryPickerView.dataSource = self
        
        tfPhoneNo.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        
        Constants.kUserDefaults.setValue(true, forKey: "isNotFirstTime")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillAppear() {
        //Do something here
//        let newConstraint = constMultiplierCenter.constraintWithMultiplier(1.2)
//        view.removeConstraint(constMultiplierCenter)
//        view.addConstraint(newConstraint)
//        view.layoutIfNeeded()
//        constMultiplierCenter = newConstraint
    }
    
    @objc func keyboardWillDisappear() {
        //Do something here
//        let newConstraint = constMultiplierCenter.constraintWithMultiplier(1.3)
//        view.removeConstraint(constMultiplierCenter)
//        view.addConstraint(newConstraint)
//        view.layoutIfNeeded()
//        constMultiplierCenter = newConstraint
    }
    
    
    @IBAction func btnContinueTapAction(_ sender: UIButton) {
        Global.setVibration()
        
        if tfPhoneNo.text?.first == "0" {
            tfPhoneNo.text?.removeFirst()
        }
        
        let numberString = (tfPhoneNo.text?.trim() ?? "").replacingOccurrences(of: " ", with: "")
        
        self.view.endEditing(true)
        if Validation.isBlank(for: numberString) {
            Common.showAlertMessage(message: Messages.emptyPhoneNo, alertType: .error)
            return
        } else if !Validation.isValidMobileNumber(value: numberString) {
            Common.showAlertMessage(message: Messages.validPhoneNo, alertType: .error)
            return
        }
        
        self.view.endEditing(true)
        VerifyPhone(phoneNumber: "\(countryPhoneCode)\(tfPhoneNo.text?.trim() ?? "")".replacingOccurrences(of: " ", with: ""))
    }
    
    @IBAction func btnSocialLoginTapAction(_ sender: UIButton) {
        Global.setVibration()
        switch sender.tag {
        case 101: //apple
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
            break
        case 102: //google
            GIDSignIn.sharedInstance.signIn(withPresenting: self) { user, error in
                guard error == nil else { return }
                
                guard let userData = user?.user.profile, let userId = user?.user.userID else { return }
                self.email = userData.email
                self.firstName = userData.givenName ?? ""
                self.lastName = userData.familyName ?? ""
                self.socialId = userId
                self.socialType = .Google
                
                let imageUrl = userData.imageURL(withDimension: 500)?.absoluteString
                self.profileImageURL = imageUrl?.makeUrl()
                
                self.Login(uid: userId, dialCode: "", phoneNumber: "", socialType: .Google) { (data, error) in
                    DispatchQueue.main.async {
                        self.HandleResponseData(data: data, error: error)
                    }
                }
                GIDSignIn.sharedInstance.signOut()
            }
            break
        case 103: //facebook
            facebookLogin()
            break
        default:
            break
        }
    }
    
    @IBAction func btnCountryTapAction(_ sender: UIButton) {
        countryPickerView.showCountriesList(from: self)
    }
    
    @IBAction func tfEditingChanged(_ sender: UITextField) {
        tfPhoneNo.text = tfPhoneNo.text?.applyPatternOnNumbers(pattern: "# ## ## ## ##", replacmentCharacter: "#")
    }
}

//MARK: CountryPickerViewDelegate
extension LoginVC: CountryPickerViewDelegate, CountryPickerViewDataSource {
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
        self.countryPhoneCode = country.phoneCode
        self.countryFlag = country.code
        self.btnCountryCode.setTitle((Global.emojiFlag(regionCode: country.code) ?? "")+" \(country.phoneCode)", for: .normal)
    }
    func closeButtonNavigationItem(in countryPickerView: CountryPickerView) -> UIBarButtonItem? {
        return UIBarButtonItem(title: "Fermer".localized, style: .done, target: nil, action: nil)
    }
}

//MARK: UITextFieldDelegate
extension LoginVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == tfPhoneNo
        {
            print(range)
            if string == "" {
                return true
            }
            if (range.lowerBound == 0 && string == "0") {
                return false
            }
            if string.count > 1 {
                if string.hasPrefix("+") {
                    tfPhoneNo.text = "\(string.dropFirst(3))".trim()
                }
                if string.hasPrefix("0") {
                    tfPhoneNo.text = "\(string.dropFirst(1))".trim()
                }
                tfPhoneNo.text = tfPhoneNo.text?.applyPatternOnNumbers(pattern: "# ## ## ## ##", replacmentCharacter: "#")
                return false
                
            }
            return  textField.text!.count < 13
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}

extension LoginVC {
    //MARK: - Verify Phone Number with firebase
    func VerifyPhone(phoneNumber: String) {
        Auth.auth().languageCode = Constants.lc
        DispatchQueue.main.async {
            Global.showLoadingSpinner(nil, sender: self.view)
        }
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) {[unowned self] (verificationID, error) in
            DispatchQueue.main.async { [self] in
                Global.dismissLoadingSpinner(self.view)
                
                if error != nil {
                    print("phone auth error = \(error!)")
                    Common.showAlertMessage(message: "Veuillez entrer un numéro de téléphone valide avant de continuer.".localized, alertType: .error)
//                    Common.showAlertMessage(message: error!.localizedDescription, alertType: .error)
                    
                    return
                }
                UserDefaults.standard.set(verificationID, forKey: Constants.kAUTHVERIFICATIONID)
                
                let vc = Constants.Main.instantiateViewController(withIdentifier: "VerifyNumberVC") as! VerifyNumberVC
                vc.countryPhoneCode = countryPhoneCode
                vc.phoneNumberWithCode = phoneNumber
                vc.phno = tfPhoneNo.text?.trim() ?? ""
                vc.countryFlag = self.countryFlag
                let nvc = UINavigationController(rootViewController: vc)
                if #available(iOS 13.0, *) {
                    nvc.isModalInPresentation = true
                } else {
                    // Fallback on earlier versions
                }
                self.present(nvc, animated: true, completion: nil)
                
            }
        }
    }
    
    //MARK: - Handle social login data
    func HandleResponseData(data: LoginRegisterViewModel?, error: ErrorTypesAPP?) {
        if let tokenData = data {
            if tokenData.isRegistered == false {
                //goto registration according to steps
                
                if tokenData.tokenData.accessToken != "" {
                    Constants.saveAPITokens(accessToken: tokenData.tokenData.accessToken, refreshToken: tokenData.tokenData.refreshToken)
                }
                HpGlobal.shared.registrationData = ProfileDataViewModel(data: ProfileDataModel())
                HpGlobal.shared.registrationData?.uid = self.socialId ?? ""
                HpGlobal.shared.registrationData?.socialTypeGetter = self.socialType?.rawValue ?? SocialType.DeviceId.rawValue
                HpGlobal.shared.registrationData?.firstName = self.firstName ?? ""
                HpGlobal.shared.registrationData?.lastName = self.lastName ?? ""
                HpGlobal.shared.registrationData?.email = self.email ?? ""
//                HpGlobal.shared.registrationData?.countryPhoneCode = self.countryPhoneCode
//                HpGlobal.shared.registrationData?.mobileNumber = self.phno
//                HpGlobal.shared.registrationData?.nationalNumber = self.countryPhoneCode
                self.ShowPermissionVC(shouldGotoHomeScreen: false)
                
            } else {
                if tokenData.tokenData.accessToken != "" {
                    Constants.saveAPITokens(accessToken: tokenData.tokenData.accessToken, refreshToken: tokenData.tokenData.refreshToken)
                }
                
                self.ShowPermissionVC(shouldGotoHomeScreen: true)
            }
        }
    }
    
    func ShowPermissionVC(shouldGotoHomeScreen: Bool) {
            let current = UNUserNotificationCenter.current()
            current.getNotificationSettings(completionHandler: { (settings) in
                DispatchQueue.main.async {
                    if settings.authorizationStatus == .notDetermined || settings.authorizationStatus == .denied {
                        DispatchQueue.main.async {
                            let vc = Constants.Main.instantiateViewController(withIdentifier: "NotiPermissionVC") as! NotiPermissionVC
                            vc.shouldGotoHomeScreen = shouldGotoHomeScreen
                            let nav = UINavigationController(rootViewController: vc)
                            self.present(nav, animated: true, completion: nil)
                            //self.navigationController?.pushViewController(vc, animated: true)
                        }
                    } else {
                        let center = UNUserNotificationCenter.current()
                        center.getNotificationSettings { [self] settings in
                            DispatchQueue.main.async {
                                if settings.criticalAlertSetting == .enabled {
                                    if shouldGotoHomeScreen {
                                        Constants.kAppDelegate.isUserLogin(true)
                                    } else {
                                        let vc = Constants.Main.instantiateViewController(withIdentifier: "WelcomeVC") as! WelcomeVC
                                        guard let getNav = UIApplication.topViewController()?.navigationController else {
                                            return
                                        }
                                        let rootNavView = UINavigationController(rootViewController: vc)
                                        rootNavView.modalPresentationStyle = .overFullScreen
                                        getNav.present(rootNavView, animated: true, completion: nil)
                                    }
                                } else {
                                    let vc = Constants.Main.instantiateViewController(withIdentifier: "CriticalNotificationPermissionVC") as! CriticalNotificationPermissionVC
                                    vc.shouldGotoHomeScreen = shouldGotoHomeScreen
                                    let nav = UINavigationController(rootViewController: vc)
                                    self.present(nav, animated: true, completion: nil)
                                }
                            }
                        }
                       
                    }
                }
            })
    }
}

//MARK: - facebook login
extension LoginVC {
    
    func facebookLogin() {
        
        if let accressToken = AccessToken.current {
            print("Facebook User Access Token: \(accressToken)")
            self.getFBUserData()
        }
        
        if AccessToken.current == nil {
            LoginManager().logIn(permissions: ["public_profile", "email"], from: self) { (result, error) -> Void in
                if (error == nil) {
                    let fbloginresult : LoginManagerLoginResult = result!
                    // if user cancel the login
                    if (result?.isCancelled) ?? false {
                        print("Facebook User Cancelled")
                        return
                    }
                    
                    if(fbloginresult.grantedPermissions.contains("email")) {
                        self.getFBUserData()
                        print(AccessToken.current!.tokenString as Any)
                    }
                }
            }
        }
    }
    
    func getFBUserData() {
        Global.showLoadingSpinner()
        if((AccessToken.current) != nil) {
            GraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, response, error) -> Void in
                Global.dismissLoadingSpinner()
                if (error == nil) {
                    print(response as Any)
                    
                    if let result = response as? [String : Any] {
                        print(result)
                        self.socialType = .Facebook
                        self.email = result["email"] as? String ?? ""
                        self.firstName = result["first_name"] as? String ?? ""
                        let id = result["id"] as? String ?? ""
                        self.socialId = id
                        self.lastName = result["last_name"] as? String ?? ""
                        
                        //The url is nested 3 layers deep into the result so it's pretty messy
                        if let imageURL = ((result["picture"] as? [String: Any])?["data"] as? [String: Any])?["url"] as? String {
                            self.profileImageURL = imageURL.makeUrl()
                            //Download image from imageURL
                        }
                        
                        self.Login(uid: id, dialCode: "", phoneNumber: "", socialType: .Facebook) { (data, error) in
                            DispatchQueue.main.async {
                                self.HandleResponseData(data: data, error: error)
                            }
                        }
                        //Constants.kAppDelegate.isUserLogin(true)
                        LoginManager().logOut()
                    }
                }
            })
        }
    }
}

//MARK: - Apple login
extension LoginVC: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            socialType = .Apple
            socialId = appleIDCredential.user
            firstName = "\(appleIDCredential.fullName?.givenName ?? "")".trim()
            lastName = "\(appleIDCredential.fullName?.familyName ?? "")".trim()
            email = appleIDCredential.email
    
            Login(uid: appleIDCredential.user, dialCode: "", phoneNumber: "", socialType: .Apple) { (data, error) in
                DispatchQueue.main.async {
                    self.HandleResponseData(data: data, error: error)
                }
            }

        default:
            break
        }
    }
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
    }
}


extension LoginVC: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

//MARK:- TermsOfUse Label Set
extension LoginVC {
    func setup() {
        lblTerms.numberOfLines = 0
        //En continuant vous reconnaissez avoir lu notre Politique de confidentialité et vous acceptez nos Conditions générales d'utilisation.
        let txt1 = "En continuant vous reconnaissez avoir lu notre".localized
        let txt2 = "et vous acceptez nos".localized
        
        let strTC = "Conditions Générales d’Utilisation.".localized
        let strPP = "Politique de confidentialité".localized
        
        let string = "\(txt1) \(strPP) \(txt2) \(strTC)"
        
        let nsString = string as NSString
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1
    
        let fullAttributedString = NSAttributedString(string:string, attributes: [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.foregroundColor: UIColor.color00000071,
            NSAttributedString.Key.font: UIFont.init(name: "Graphik-Regular", size: 12) ?? UIFont()
        ])
        
        lblTerms.textAlignment = .center
        lblTerms.attributedText = fullAttributedString
        
        let rangeTC = nsString.range(of: strTC)
        let rangePP = nsString.range(of: strPP)
        
        let ppLinkAttributes: [String: Any] = [
            NSAttributedString.Key.foregroundColor.rawValue: UIColor.color00000087,
            NSAttributedString.Key.underlineStyle.rawValue: false,
            NSAttributedString.Key.font.rawValue: UIFont.init(name: "Graphik-Medium", size: 12) ?? UIFont()
        ]
        
        lblTerms.activeLinkAttributes = ppLinkAttributes
        lblTerms.linkAttributes = ppLinkAttributes
        
        let urlTC = URL(string: "action://TC")!
        let urlPP = URL(string: "action://PP")!
        lblTerms.addLink(to: urlTC, with: rangeTC)
        lblTerms.addLink(to: urlPP, with: rangePP)
        
        lblTerms.textColor = UIColor.color00000057 // #colorLiteral(red: 0.4823529412, green: 0.4823529412, blue: 0.4823529412, alpha: 1)
        lblTerms.delegate = self
    }
}

//MARK:- TTTAttributedLabelDelegate
extension LoginVC: TTTAttributedLabelDelegate {
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        if url.absoluteString == "action://TC" {
            let webViewController: WebViewVC = Constants.Main.instantiateViewController(withIdentifier: "WebViewVC") as! WebViewVC
            webViewController.titleString = "Conditions Génerales".localized
            
            if let url = HpGlobal.shared.settingsData?.termsCondition {
                webViewController.url = url
                guard let getNav = UIApplication.topViewController()?.navigationController else {
                    return
                }
                let rootNavView = UINavigationController(rootViewController: webViewController)
                getNav.present( rootNavView, animated: true, completion: nil)
            }
        } else {
            let webViewController: WebViewVC = Constants.Main.instantiateViewController(withIdentifier: "WebViewVC") as! WebViewVC
            webViewController.titleString = "Politique de confidentialité".localized
            if let url = HpGlobal.shared.settingsData?.confidentiality {
                webViewController.url = url
                
                guard let getNav = UIApplication.topViewController()?.navigationController else {
                    return
                }
                let rootNavView = UINavigationController(rootViewController: webViewController)
                getNav.present( rootNavView, animated: true, completion: nil)
            }
        }
    }
}

extension NSLayoutConstraint {
    func constraintWithMultiplier(_ multiplier: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self.firstItem!, attribute: self.firstAttribute, relatedBy: self.relation, toItem: self.secondItem, attribute: self.secondAttribute, multiplier: multiplier, constant: self.constant)
    }
}
