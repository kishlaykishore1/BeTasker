//
//  NotiPermissionVC.swift
//  EasyAC
//
//  Created by MAC3 on 27/04/23.
//

import UIKit

class NotiPermissionVC: UIViewController {

    //MARK: IBOutlets
    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var viewBtn: UIView!
    
    var shouldGotoHomeScreen = false
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        btnContinue.layer.cornerRadius = btnContinue.frame.height / 2
        // Do any additional setup after loading the view.
        DispatchQueue.main.async { [self] in
            viewBtn.applyShadow(radius: 3, opacity: 0.1, offset: CGSize(width: 0.0, height: 3.0))
        }
        setBackButton(isImage: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func backBtnTapAction() {
        Global.setVibration()
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func btnContinueTapAction(_ sender: UIButton) {
        Global.setVibration()
        let current = UNUserNotificationCenter.current()
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        current.requestAuthorization( options: authOptions, completionHandler: { granted, error in
            if error != nil { }// Handle the error here.
            DispatchQueue.main.async {
                if granted {
                    self.moveToNext()
                } else {
                    self.showNotificationAlert()
                }
            }
        })
        UIApplication.shared.registerForRemoteNotifications()
    }
    
   func moveToNext() {
       let center = UNUserNotificationCenter.current()
       center.getNotificationSettings { [self] settings in
           DispatchQueue.main.async {
               if settings.criticalAlertSetting == .enabled {
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
               } else {
                   let vc = Constants.Main.instantiateViewController(withIdentifier: "CriticalNotificationPermissionVC") as! CriticalNotificationPermissionVC
                   vc.shouldGotoHomeScreen = self.shouldGotoHomeScreen
                   self.navigationController?.pushViewController(vc, animated: true)
               }
           }
       }
    }
    
    func showNotificationAlert() {
        let alert = UIAlertController(title: "Autoriser les notifications".localized, message: "Pour recevoir des notifications, vous devez les autoriser dans les réglages de votre téléphone.".localized, preferredStyle: .alert)
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
        guard let getNav = UIApplication.topViewController()?.navigationController else {
            return
        }
       
        getNav.present( alert, animated: true, completion: nil)
    }
    
}
