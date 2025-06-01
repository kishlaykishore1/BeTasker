//
//  EditPhoneNumberVC.swift
//  EasyAC
//
//  Created by MAC3 on 04/05/23.
//

import UIKit
import CountryPickerView
import FirebaseAuth

class EditPhoneNumberVC: UIViewController {

    //MARK: IBOutlets
    @IBOutlet weak var viewOuterTelp: UIView!
    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var tfPhoneNo: UITextField!
    @IBOutlet weak var btnCountryCode: UIButton!
    
    // MARK: Properties
    let countryPickerView = CountryPickerView()
    var countryPhoneCode = "+33"
    var countryFlag = "FR"
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        DispatchQueue.main.async { [self] in
            let brdrClr = UIColor.colorE8E8E8
            viewOuterTelp.applyBorder(width: 1, color: brdrClr)
            btnContinue.applyShadow(radius: 3, opacity: 0.1, offset: CGSize(width: 0.0, height: 3.0))
        }
        
        setBackButton(isImage: true)
        
        countryPickerView.delegate = self
        countryPickerView.dataSource = self
        
        tfPhoneNo.delegate = self
        tfPhoneNo.becomeFirstResponder()
        if let data = HpGlobal.shared.userInfo {
            tfPhoneNo.text = data.mobileNumber.formattedPhoneNumber()
            self.countryPickerView.setCountryByCode(data.dialCodeWithFlag.countryCode)
            self.countryPhoneCode = data.countryPhoneCode
            self.btnCountryCode.setTitle(data.dialCodeWithFlag.codeWithFlag, for: .normal)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarImage(color: UIColor.colorFFFFFF000000, txtcolor: UIColor.color262626, requireShadowLine: true)
        self.navigationItem.title = "Modifier le numéro de téléphone".localized
    }
    
    override func backBtnTapAction() {
        Global.setVibration()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnContinueTapAction(_ sender: UIButton) {
        Global.setVibration()
        
        let numberString = (tfPhoneNo.text?.trim() ?? "").replacingOccurrences(of: " ", with: "")
        
        self.view.endEditing(true)
        if Validation.isBlank(for: numberString) {
            Common.showAlertMessage(message: Messages.emptyPhoneNo, alertType: .error)
            return
        } else if !Validation.isValidMobileNumber(value: numberString) {
            Common.showAlertMessage(message: Messages.validPhoneNo, alertType: .error)
            return
        }
        VerifyPhone(phoneNumber: "\(countryPhoneCode)\(tfPhoneNo.text?.trim() ?? "")".replacingOccurrences(of: " ", with: ""))
        
    }
    
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
                    Common.showAlertMessage(message: "Veuillez entrer un numéro de téléphone valide avant de continuer.".localized, alertType: .error)
                    return
                }
                UserDefaults.standard.set(verificationID, forKey: Constants.kAUTHVERIFICATIONID)
                
                let vc = Constants.Profile.instantiateViewController(withIdentifier: "EditVerifyNumberVC") as! EditVerifyNumberVC
                vc.countryPhoneCode = countryPhoneCode
                vc.phoneNumberWithCode = phoneNumber
                vc.phno = tfPhoneNo.text?.trim() ?? ""
                vc.countryFlag = self.countryFlag
                self.navigationController?.pushViewController(vc, animated: true)
            }
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
extension EditPhoneNumberVC: CountryPickerViewDelegate, CountryPickerViewDataSource {
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
extension EditPhoneNumberVC: UITextFieldDelegate {
    
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
    
}
