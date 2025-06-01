//
//  SettingVC.swift
//  EasyAC
//
//  Created by MAC3 on 03/05/23.
//

import UIKit
import MessageUI

class SettingVC: UIViewController {
    
    @IBOutlet weak var btnYoutube: UIButton!
    @IBOutlet weak var btnTiktok: UIButton!
    @IBOutlet weak var btnInstagram: UIButton!
    @IBOutlet weak var btnFacebook: UIButton!
    @IBOutlet weak var lblCoryright: UILabel!
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setBackButton(isImage: true)
        let calendar = Calendar(identifier: .gregorian)
        let year = calendar.component(.year, from: Date())
        lblCoryright.text = """
\("Réalisation".localized) : 55 · agency
© \(year) BeTasker
"""
    }
    
    override func backBtnTapAction() {
        Global.setVibration()
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.title = "Réglages".localized
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.color191919 as Any,
            .font: UIFont(name: Constants.KGraphikMedium, size: 14)!
        ]
        let attributes2: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.color191919 as Any,
            .font: UIFont(name: Constants.KGraphikMedium, size: 33)!
        ]
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        self.navigationController?.navigationBar.largeTitleTextAttributes = attributes2
    }
    
    @IBAction func viewTapAction(_ sender: UIControl) {
        Global.setVibration()
        guard let data = HpGlobal.shared.settingsData else { return }
        switch sender.tag {
        case 101:
            let vc = Constants.Profile.instantiateViewController(withIdentifier: "EditProfileVC") as! EditProfileVC
            let nvc = UINavigationController(rootViewController: vc)
            if #available(iOS 13.0, *) {
                nvc.isModalInPresentation = true
            } else {
                // Fallback on earlier versions
            }
            self.present(nvc, animated: true, completion: nil)
        case 102:
            let vc = Constants.Profile.instantiateViewController(withIdentifier: "EditPhoneNumberVC") as! EditPhoneNumberVC
            let nvc = UINavigationController(rootViewController: vc)
            if #available(iOS 13.0, *) {
                nvc.isModalInPresentation = true
            } else {
                // Fallback on earlier versions
            }
            self.present(nvc, animated: true, completion: nil)
        case 103:
            let vc = Constants.Profile.instantiateViewController(withIdentifier: "NotificationSettingVC") as! NotificationSettingVC
            let nvc = UINavigationController(rootViewController: vc)
            if #available(iOS 13.0, *) {
                nvc.isModalInPresentation = true
            } else {
                // Fallback on earlier versions
            }
            self.present(nvc, animated: true, completion: nil)
        case 104:
            let vc = Constants.Profile.instantiateViewController(withIdentifier: "FaqVC") as! FaqVC
            let nvc = UINavigationController(rootViewController: vc)
            if #available(iOS 13.0, *) {
                nvc.isModalInPresentation = true
            } else {
                // Fallback on earlier versions
            }
            self.present(nvc, animated: true, completion: nil)
        case 105:
            let vc = Constants.Main.instantiateViewController(withIdentifier: "WebViewVC") as! WebViewVC
            vc.titleString = "Conditions Générales d’Utilisation".localized
            vc.url = data.termsCondition
            let nvc = UINavigationController(rootViewController: vc)
            if #available(iOS 13.0, *) {
                nvc.isModalInPresentation = true
            } else {
                // Fallback on earlier versions
            }
            self.present(nvc, animated: true, completion: nil)
        case 106:
            let vc = Constants.Main.instantiateViewController(withIdentifier: "WebViewVC") as! WebViewVC
            vc.titleString = "Politique de confidentialité".localized
            vc.url = data.confidentiality
            let nvc = UINavigationController(rootViewController: vc)
            if #available(iOS 13.0, *) {
                nvc.isModalInPresentation = true
            } else {
                // Fallback on earlier versions
            }
            self.present(nvc, animated: true, completion: nil)
        case 107:
            self.sendMail(email: data.contactEmail)
        case 108:
            showReportMessagePopup()
        case 109:
            Global.openURL(data.webURL)
        default:
            break
        }
        
    }
    
    @IBAction func preferences(_ sender: UIControl) {
        Global.setVibration()
        //PreferencesVC
        let vc = Constants.Profile.instantiateViewController(withIdentifier: "PreferencesVC") as! PreferencesVC
        let nvc = UINavigationController(rootViewController: vc)
        nvc.isModalInPresentation = true
        self.present(nvc, animated: true, completion: nil)
    }
    
    
    @IBAction func btnLogOutTapAction(_ sender: UIButton) {
        Global.setVibration()
        let alert  = UIAlertController(title: Messages.txtDeleteAlert, message: Messages.logoutMsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Messages.txtDeleteConfirm, style: .destructive, handler: { _ in
            HpAPI.STATIC.apiLogoutUser()
            Constants.kAppDelegate.isUserLogin(false)
        }))
        alert.addAction(UIAlertAction(title: Messages.txtCancel, style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func btnDeleteAccountTapAction(_ sender: UIButton) {
        let alertController = UIAlertController(title: Messages.txtDeleteAlert, message: Messages.deleteAccountMsg, preferredStyle: .alert)
        let logoutAction = UIAlertAction(title: Messages.txtDeleteAccount, style: .destructive, handler: { alert -> Void in
            HpAPI.DELETEACCOUNT.DataAPI(params: [:], shouldShowError: true, shouldShowSuccess: true, key: nil) { (response: Result<GeneralModel, Error>) in
                DispatchQueue.main.async {
                    Global.dismissLoadingSpinner()
                    switch response {
                    case .success(_):
                        HpAPI.STATIC.clearLogoutDataFromApp()
                        Constants.kAppDelegate.isUserLogin(false)
                        break
                    case .failure(_):
                        break
                    }
                }
            }
        })
        let cancelAction = UIAlertAction(title: Messages.txtCancel, style: .cancel, handler: { (action : UIAlertAction!) -> Void in
        })
        alertController.addAction(logoutAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func btnLinkTapAction(_ sender: UIButton) {
        Global.setVibration()
        guard let data = HpGlobal.shared.settingsData else { return }
        switch sender.tag {
        case 101:
            Global.openURL(data.fbUrl)
        case 102:
            Global.openURL(data.instaURL)
        case 103:
            //Global.openURL("https://www.tiktok.com/")
            break
        case 104:
            //Global.openURL("https://www.youtube.com/")
            break
        default:
            break
        }
    }
}

// MARK: Report Popup
extension SettingVC {
    func showReportMessagePopup() {
        SendReport(title: Messages.txtSettingReportBug, message: Messages.bugReportTitle, placeholderText: Messages.txtSettingReportTextField, reportType: .bugReport, id: nil, key: "", isDarkMode: false) { isDone in
            DispatchQueue.main.async {
                
            }
        }
        /*
         let alertController = UIAlertController(title: Messages.txtSettingReportBug, message: Messages.bugReportTitle, preferredStyle: .alert)
         let saveAction = UIAlertAction(title: Messages.txtSettingSend, style: .destructive, handler: { alert -> Void in
         let firstTextField = alertController.textFields![0] as UITextField
         if firstTextField.text?.trim().count == 0 {
         Common.showAlertMessage(message: Messages.txtSettingBugDetail, alertType: .error)
         return
         }
         
         let textfield = firstTextField.text!
         
         })
         let cancelAction = UIAlertAction(title: Messages.txtCancel, style: .default, handler: { (action : UIAlertAction!) -> Void in
         
         })
         
         alertController.addTextField { (textField : UITextField!) -> Void in
         saveAction.isEnabled = false
         textField.placeholder = Messages.txtSettingReportTextField
         textField.autocapitalizationType = .sentences
         textField.isEnabled = false
         NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main, using:
         {_ in
         let textCount = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0
         let textIsNotEmpty = textCount > 0
         saveAction.isEnabled = textIsNotEmpty
         })
         }
         
         alertController.addAction(cancelAction)
         alertController.addAction(saveAction)
         self.present(alertController, animated: true, completion: {
         let firstTextField = alertController.textFields![0] as UITextField
         firstTextField.isEnabled = true
         firstTextField.becomeFirstResponder()
         })
         */
    }
    
}

// MARK: Send Mail
extension SettingVC: MFMailComposeViewControllerDelegate {
    
    func sendMail(email: String) {
        if !MFMailComposeViewController.canSendMail() {
            Common.showAlertMessage(message: Messages.mailNotFound, alertType: .warning)
            return
        }
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        composeVC.setToRecipients([email])
        composeVC.setSubject("Demande de contact".localized)
        composeVC.setMessageBody("", isHTML: false)
        self.present(composeVC, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
