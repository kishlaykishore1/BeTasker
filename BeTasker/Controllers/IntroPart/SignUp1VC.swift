//
//  SignUp1VC.swift
//  EasyAC
//
//  Created by MAC3 on 27/04/23.
//

import UIKit
import MaterialComponents

class SignUp1VC: UIViewController {

    //MARK: IBOutlets
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var tfFName: MDCOutlinedTextField!
    @IBOutlet weak var viewBtn: UIView!
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        btnNext.layer.cornerRadius = btnNext.frame.height/2
        // Do any additional setup after loading the view.
        DispatchQueue.main.async { [self] in
            viewBtn.applyShadow(radius: 3, opacity: 0.1, offset: CGSize(width: 0.0, height: 3.0))
            Global.setTextField(txtField: tfFName, label: "Votre prénom".localized, fontSize: 30, labelFontSize: 10)
        }
        setBackButton(isImage: true)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
       
        tfFName.delegate = self
        
        if let firstName = HpGlobal.shared.registrationData?.firstName, firstName != "" {
            tfFName.text = firstName
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tfFName.becomeFirstResponder()
    }
    
    override func backBtnTapAction() {
        Global.setVibration()
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func btnNextTapAction(_ sender: UIButton) {
        Global.setVibration()
        if HpGlobal.shared.registrationData?.socialType != .Apple {
            if Validation.isBlank(for: tfFName.text ?? "") {
                Common.showAlertMessage(message: Messages.emptyFirstName, alertType: .error)
                return
            }
        }
        HpGlobal.shared.registrationData?.firstName = tfFName.text?.trim() ?? ""
        let vc = Constants.Main.instantiateViewController(withIdentifier: "SignUp2VC") as! SignUp2VC
        self.navigationController?.pushViewController(vc, animated: true)
    }

}

//MARK: UITextFieldDelegate
extension SignUp1VC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return view.endEditing(true)
    }
}
