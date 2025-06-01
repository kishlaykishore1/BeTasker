//
//  EditVerifyNumberVC.swift
//  EasyAC
//
//  Created by MAC3 on 04/05/23.
//

import UIKit
import FirebaseAuth

class EditVerifyNumberVC: UIViewController {
    
    //MARK: IBOutlets
    @IBOutlet var viewTf: [UIView]!
    @IBOutlet weak var tf1: BackspaceTextField!
    @IBOutlet weak var tf6: BackspaceTextField!
    @IBOutlet weak var tf5: BackspaceTextField!
    @IBOutlet weak var tf4: BackspaceTextField!
    @IBOutlet weak var tf3: BackspaceTextField!
    @IBOutlet weak var tf2: BackspaceTextField!
    @IBOutlet weak var btnResendCode: UIButton!
    @IBOutlet weak var lblPhoneNumber: UILabel!
    
    //MARK: Properties
    var textFields: [BackspaceTextField] {
        return [tf1,tf2,tf3,tf4,tf5,tf6]
    }
    var count = 30  // 60sec if you want
    var resendTimer = Timer()
    var phno = ""
    var countryPhoneCode = ""
    var phoneNumberWithCode = ""
    var countryFlag = ""
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblPhoneNumber.text = """
\("Nous vous avons envoyé un code de vérification".localized)
\("au".localized) \(phoneNumberWithCode)
"""
        
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarImage(color: UIColor.colorFFFFFF000000, txtcolor: UIColor.color262626, requireShadowLine: true)
        self.navigationItem.title = "Modifier le numéro de téléphone".localized
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
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnTapActions(_ sender: UIButton) {
        Global.setVibration()
        VerifyPhone(phoneNumber: "\(countryPhoneCode)\(phno)".replacingOccurrences(of: " ", with: ""))
        count = 30
        resendTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(update), userInfo: nil, repeats: true)
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
    
    func verifyOtp() {
        self.view.endEditing(true)
        AuthenticateOTP { uid in
            guard uid != "" else { return }
            DispatchQueue.main.async {
                self.UpdateMobile(uid: uid)
            }
        }
    }
    
}

//MARK: UITextFieldDelegate
extension EditVerifyNumberVC: UITextFieldDelegate {
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
extension EditVerifyNumberVC: BackspaceTextFieldDelegate {
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

extension EditVerifyNumberVC {
    func UpdateMobile(uid: String) {
        let params: [String: Any] = [
            "lc": Constants.lc,
            "post_for": "editMobile",
            "mobile": phno.replacingOccurrences(of: " ", with: ""),
            "country_code": countryPhoneCode,
            "country_flag": countryFlag,
            "national_number": countryPhoneCode.replacingOccurrences(of: "+", with: ""),
            "dudid": uid
        ]
        DispatchQueue.main.async {
            Global.showLoadingSpinner(sender: self.view)
        }
        HpAPI.EDITSETTING.DataAPI(params: params, shouldShowError: true, shouldShowSuccess: true, key: "data") { (response: Result<ProfileModel, Error>) in
            DispatchQueue.main.async {
                Global.dismissLoadingSpinner()
                switch response {
                case .success(let res):
                    if let userInfo = res.user_info {
                        HpGlobal.shared.userInfo = ProfileDataViewModel(data: userInfo)
                        //NotificationCenter.default.post(name: .updateProfile, object: nil)
                        self.dismiss(animated: true, completion: nil)
                    }
                    break
                case .failure(_):
                    break
                }
            }
        }
    }
    
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
}
