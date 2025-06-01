//
//  CriticalNotificationPermissionVC.swift
//  teamAlerts
//
//  Created by B2Cvertical A++ on 14/05/24.
//

import UIKit

class CriticalNotificationPermissionVC: UIViewController {
    
    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var viewBtn: UIView!
    
    var shouldGotoHomeScreen = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        btnContinue.layer.cornerRadius = btnContinue.frame.height / 2
        // Do any additional setup after loading the view.
        DispatchQueue.main.async { [self] in
            viewBtn.applyShadow(radius: 3, opacity: 0.1, offset: CGSize(width: 0.0, height: 3.0))
        }
        
        setBackButton(isImage: true)
    }
    

    override func backBtnTapAction() {
        Global.setVibration()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnContinueTapAction(_ sender: UIButton) {
        Global.setVibration()
        CheckNotificationPermission()
    }
    
    func CheckNotificationPermission() {
        let current = UNUserNotificationCenter.current()
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound, .criticalAlert]
        current.requestAuthorization( options: authOptions, completionHandler: { granted, error in
            if error != nil { }// Handle the error here.
            DispatchQueue.main.async {
                if granted {
                    print("Notification Permission granted - \(granted)")
                    self.moveToNext()
                } else {
                    self.showNotificationAlert()
                }
            }
        })
    }
    
    func showNotificationAlert() {
        let alert = UIAlertController(title: "Autoriser les critical notifications".localized, message: "Pour recevoir des notifications, vous devez les autoriser dans les réglages de votre téléphone.".localized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Messages.txtSetting, style: .default, handler: { (error) in
            
            let url = URL(string: UIApplication.openSettingsURLString)
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url!, options: [:], completionHandler: { (error) in
                })
            }
        }))
        
        alert.addAction(UIAlertAction(title: Messages.txtCancel, style: .cancel, handler: { (action : UIAlertAction!) -> Void in
            self.moveToNext()
        }))
        
        self.present( alert, animated: true, completion: nil)
    }
    
    func moveToNext() {
        self.dismiss(animated: true) {
            guard self.shouldGotoHomeScreen == false else {
                Constants.kAppDelegate.isUserLogin(true)
                return
            }
            let vc = Constants.Main.instantiateViewController(withIdentifier: "WelcomeVC") as! WelcomeVC
            guard let getNav = UIApplication.topViewController()?.navigationController else {
                return
            }
            let rootNavView = UINavigationController(rootViewController: vc)
            rootNavView.modalPresentationStyle = .overFullScreen
            getNav.present(rootNavView, animated: true, completion: nil)
        }
    }

}
