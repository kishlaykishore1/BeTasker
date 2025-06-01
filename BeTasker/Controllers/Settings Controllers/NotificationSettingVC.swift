//
//  NotificationSettingVC.swift
//  EasyAC
//
//  Created by MAC3 on 03/05/23.
//

import UIKit

class NotificationSettingVC: UIViewController {

    //MARK: IBOutlets
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var switchNewsNotifications: UISwitch!
    @IBOutlet weak var switchNotifications: UISwitch!
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        DispatchQueue.main.async { [self] in
            btnSave.applyShadow(radius: 3, opacity: 0.1, offset: CGSize(width: 0.0, height: 3.0))
        }
        setBackButton(isImage: true)
        if HpGlobal.shared.userInfo?.allowNotification == false {
            switchNotifications.setOn(false, animated: false)
            switchNewsNotifications.setOn(false, animated: false)
            switchNewsNotifications.isUserInteractionEnabled = false
        } else {
            switchNotifications.setOn(true, animated: false)
            switchNewsNotifications.isUserInteractionEnabled = true
        }
        switchNewsNotifications.setOn(HpGlobal.shared.userInfo?.notifyNewMessage ?? false, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarImage(color: UIColor.colorFFFFFF000000, txtcolor: UIColor.color262626, requireShadowLine: true)
        self.navigationItem.title = "Paramètres de notifications".localized
    }

    override func backBtnTapAction() {
        Global.setVibration()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func SwitchNotification(_ sender: UISwitch) {
        if sender.isOn == false {
            switchNewsNotifications.setOn(false, animated: true)
            switchNewsNotifications.isUserInteractionEnabled = false
        } else {
            switchNewsNotifications.isUserInteractionEnabled = true
        }
    }
    @IBAction func SwitchNewsNotification(_ sender: UISwitch) {
        
    }
    
    
    @IBAction func btnSaveTapAction(_ sender: UIButton) {
        Global.setVibration()
        let params: [String: Any] = [
            "lc": Constants.lc,
            "post_for": "notificationSetting",
            "notification": switchNotifications.isOn ? 1 : 0,
            "application_news_notification": switchNewsNotifications.isOn ? 1 : 0
        ]
        DispatchQueue.main.async {
            Global.showLoadingSpinner(sender: self.view)
        }
        HpAPI.EDITSETTING.DataAPI(params: params, shouldShowError: true, shouldShowSuccess: false, key: nil) { (response: Result<GeneralModel, Error>) in
            DispatchQueue.main.async {
                Global.dismissLoadingSpinner()
                switch response {
                case .success(_):
                    HpGlobal.shared.userInfo?.allowNotification = self.switchNotifications.isOn
                    HpGlobal.shared.userInfo?.notifyNewMessage = self.switchNewsNotifications.isOn
                    self.dismiss(animated: true, completion: nil)
                    break
                case .failure(_):
                    break
                }
            }
        }
        
    }
}
