//
//  VerifyNumberVC.swift
//  EasyAC
//
//  Created by MAC3 on 26/04/23.
//

import UIKit
import FirebaseAuth
import CoreLocation
import CoreBluetooth

class BackspaceTextField: UITextField {
    weak var backspaceTextFieldDelegate: BackspaceTextFieldDelegate?
    
    override func deleteBackward() {
        if text?.isEmpty ?? false {
            backspaceTextFieldDelegate?.textFieldDidEnterBackspace(self)
        }
        
        super.deleteBackward()
    }
}

protocol BackspaceTextFieldDelegate: AnyObject {
    func textFieldDidEnterBackspace(_ textField: BackspaceTextField)
}

class VerifyNumberVC: UIViewController {

    //MARK: IBOutlets
    @IBOutlet weak var lblPhoneNumber: UILabel!
    @IBOutlet var viewTf: [UIView]!
    @IBOutlet weak var tf1: BackspaceTextField!
    @IBOutlet weak var tf6: BackspaceTextField!
    @IBOutlet weak var tf5: BackspaceTextField!
    @IBOutlet weak var tf4: BackspaceTextField!
    @IBOutlet weak var tf3: BackspaceTextField!
    @IBOutlet weak var tf2: BackspaceTextField!
    @IBOutlet weak var btnResendCode: UIButton!
    
    //MARK: Properties
    var textFields: [BackspaceTextField] {
        return [tf1,tf2,tf3,tf4,tf5,tf6]
    }
    var count = 30  // 60sec if you want
    var resendTimer = Timer()
    var phno = ""
    var countryPhoneCode = ""
    var countryPrefix = ""
    var phoneNumberWithCode = ""
    var countryFlag = "FR"
    
    var isFromSocialSignup = false
    var isForEdit = false
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        btnResendCode.isEnabled = false
        tf1.delegate = self
        tf2.delegate = self
        tf3.delegate = self
        tf4.delegate = self
        tf5.delegate = self
        tf6.delegate = self
        textFields.forEach { $0.backspaceTextFieldDelegate = self }
        resendTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(update), userInfo: nil, repeats: true)
        
        DispatchQueue.main.async { [self] in
            let brdrClr = UIColor.colorE8E8E8
            viewTf.forEach { (vw) in
                vw.applyBorder(width: 1, color: brdrClr)
            }
            
        }
        
        setBackButton(isImage: true)
        
//        var attributed = NSMutableAttributedString()
//        attributed = lblPhoneNumber.attributedText?.mutableCopy() as! NSMutableAttributedString
//        
//        if let range = attributed.string.range(of: "#") {
//            let nsRange = NSRange(range, in: attributed.string)
//            attributed.replaceCharacters(in: nsRange, with: phoneNumberWithCode)
//        }
//        
//        lblPhoneNumber.attributedText = attributed
        let attb = Global.setAttributedText(arrText: [
            ("Merci de bien vouloir vérifier votre numéro en entrant le code SMS envoyé au ".localized, FontName.Graphik.regular, 13, UIFont.Weight.regular, UIColor.color777777),
            ("\(phoneNumberWithCode).", FontName.Graphik.regular, 13, UIFont.Weight.regular, UIColor.colorFFD01E),
        ])
        lblPhoneNumber.attributedText = attb
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tf1.becomeFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        resendTimer.invalidate()
        
        self.tf1.resignFirstResponder()
        self.tf2.resignFirstResponder()
        self.tf3.resignFirstResponder()
        self.tf4.resignFirstResponder()
        self.tf5.resignFirstResponder()
        self.tf6.resignFirstResponder()
    }
    
    override func backBtnTapAction() {
        Global.setVibration()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnTapActions(_ sender: UIButton) {
        Global.setVibration()
        VerifyPhone(phoneNumber: "\(countryPhoneCode)\(phno)".replacingOccurrences(of: " ", with: ""))
        count = 30
        resendTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(update), userInfo: nil, repeats: true)
    }
    
    func verifyOtp() {
        self.view.endEditing(true)

        AuthenticateOTP { uid in
            guard uid != "" else { return }
            DispatchQueue.main.async {
                if self.isForEdit {
                   // self.UpdateMobile(uid: uid)
                } else if self.isFromSocialSignup {
                   // self.VerifyMobileNumber(uid: uid)
                } else {
                    self.moveToNext(uid: uid)
                }
            }
        }
    }
    
    @objc func update() {
        if(count > 1) {
            count = count - 1
            //print(count)
            btnResendCode.setTitle("\("Renvoyer le code dans".localized) \(count)s", for: .normal)
            btnResendCode.isEnabled = false
        }
        else {
            resendTimer.invalidate()
            btnResendCode.setTitle("Renvoyer le code".localized, for: .normal)
            btnResendCode.isEnabled = true
        }
    }
    
}

//MARK: UITextFieldDelegate
extension VerifyNumberVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if ((textField.text?.count)! < 1) && (string.count > 0) {
            
            if textField == tf1 {
                tf2.becomeFirstResponder()
            }
            if textField == tf2 {
                tf3.becomeFirstResponder()
            }
            if textField == tf3 {
                tf4.becomeFirstResponder()
            }
            if textField == tf4 {
                tf5.becomeFirstResponder()
            }
            if textField == tf5 {
                tf6.becomeFirstResponder()
            }
            if textField == tf6 {
                tf6.resignFirstResponder()
                DispatchQueue.main.async {
                    self.verifyOtp()
                }
            }
            
            textField.text = string
            return false
            
        } else if ((textField.text?.count)! >= 1) && (string.count == 0) {
            
            if textField == tf2 {
                tf1.becomeFirstResponder()
            }
            if textField == tf3 {
                tf2.becomeFirstResponder()
            }
            if textField == tf4 {
                tf3.becomeFirstResponder()
            }
            if textField == tf5 {
                tf4.becomeFirstResponder()
            }
            if textField == tf6 {
                tf5.becomeFirstResponder()
            }
            if textField == tf1 {
                tf1.resignFirstResponder()
            }
            
            textField.text = ""
            return false
            
        } else if ((textField.text?.count)! >= 1) {
            
            textField.text = string
            return false
        }
        
        return true
    }
}

// MARK: Backspace Tracing Delegate
extension VerifyNumberVC: BackspaceTextFieldDelegate {
    func textFieldDidEnterBackspace(_ textField: BackspaceTextField) {
        guard let index = textFields.firstIndex(of: textField) else {
            return
        }
        
        if index > 0 {
            textFields[index - 1].becomeFirstResponder()
        } else {
            view.endEditing(true)
        }
    }
}

extension VerifyNumberVC {
    //MARK: - Is Data Valid
    func IsDataValid() -> (isValid: Bool, OTP: String) {
        let otp = "\(tf1.text ?? "")\(tf2.text ?? "")\(tf3.text ?? "")\(tf4.text ?? "")\(tf5.text ?? "")\(tf6.text ?? "")".trim()
        if Validation.isBlank(for: otp) {
            Common.showAlertMessage(message: Messages.validOtp, alertType: .error)
            return (false, "")
        }
        return (true, otp)
    }
    //MARK: - Resend OTP Action
    func VerifyPhone(phoneNumber: String){
        Auth.auth().languageCode = Constants.lc
        DispatchQueue.main.async {
            Global.showLoadingSpinner(nil, sender: self.view)
        }
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) {[unowned self] (verificationID, error) in
            DispatchQueue.main.async {
                Global.dismissLoadingSpinner(self.view)
                if error != nil {
                    Common.showAlertMessage(message: "Veuillez entrer un numéro de téléphone valide avant de continuer.".localized, alertType: .error)
                    return
                }
                UserDefaults.standard.set(verificationID, forKey: Constants.kAUTHVERIFICATIONID)
            }
        }
    }
    
    //MARK: - Authenticate OTP
    func AuthenticateOTP(completion: @escaping(_ uid: String)->()) {
        if IsDataValid().isValid {
            if let verificationID = UserDefaults.standard.string(forKey: Constants.kAUTHVERIFICATIONID) {
                
                let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: IsDataValid().OTP)
                
                Auth.auth().languageCode = Constants.lc
                DispatchQueue.main.async {
                    Global.showLoadingSpinner(nil, sender: self.view)
                }
                Auth.auth().signIn(with: credential) { (authResult, error) in
                    Global.dismissLoadingSpinner(self.view)
                    if error != nil {
                        if let error = error as NSError? {
                            if error.code == AuthErrorCode.invalidVerificationCode.rawValue {
                                Common.showAlertMessage(message: "Le code de confirmation ne correspond pas. Merci de réessayer à nouveau.".localized, alertType: .error)
                            }
                        }
                        completion("")
                        return
                    }
                    if let uid = authResult?.user.uid {
                        completion(uid)
                    } else {
                        completion("")
                    }
                }
            } else {
                completion("")
            }
        } else {
            completion("")
        }
    }
    
    func moveToNext(uid: String) {
        self.Login(uid: uid, dialCode: self.countryPhoneCode.trimmingCharacters(in: ["+"]), phoneNumber: self.phno.replacingOccurrences(of: " ", with: ""), socialType: .DeviceId) { (tokenData, error) in
            DispatchQueue.main.async {
                if let tokenData = tokenData {
                    if tokenData.isRegistered == false {
                        //goto registration according to steps
                        
                        if tokenData.tokenData.accessToken != "" {
                            Constants.saveAPITokens(accessToken: tokenData.tokenData.accessToken, refreshToken: tokenData.tokenData.refreshToken)
                        }
                        HpGlobal.shared.registrationData = ProfileDataViewModel(data: ProfileDataModel())
                        HpGlobal.shared.registrationData?.uid = uid
                        HpGlobal.shared.registrationData?.socialTypeGetter = SocialType.DeviceId.rawValue
                        HpGlobal.shared.registrationData?.countryPhoneCode = self.countryPhoneCode
                        HpGlobal.shared.registrationData?.countryCode = self.countryFlag
                        HpGlobal.shared.registrationData?.mobileNumber = self.phno
                        HpGlobal.shared.registrationData?.nationalNumber = self.countryPhoneCode
                        self.ShowPermissionVC(shouldGotoHomeScreen: false)
                        
                    } else {
                        if tokenData.tokenData.accessToken != "" {
                            Constants.saveAPITokens(accessToken: tokenData.tokenData.accessToken, refreshToken: tokenData.tokenData.refreshToken)
                        }
                        
                        self.ShowPermissionVC(shouldGotoHomeScreen: true)
                    }
                }
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
                            self.navigationController?.pushViewController(vc, animated: true)
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
