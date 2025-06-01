//
//  PreferencesVC.swift
//  teamAlerts
//
//  Created by B2Cvertical A++ on 16/12/24.
//

import UIKit

enum EnumUserInterfaceStyle: String {
    case light
    case dark
    case unspecified
}

class PreferencesVC: UIViewController {

    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var switchSystem: UISwitch!
    @IBOutlet weak var switchMode: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnSave.applyShadow(radius: 3, opacity: 0.1, offset: CGSize(width: 0.0, height: 3.0))
        setBackButton(isImage: true)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarImage(color: UIColor.colorFFFFFF000000, txtcolor: UIColor.color262626, requireShadowLine: true)
        self.navigationItem.title = "Préférences".localized
        
        switch UIApplication.shared.keyWindowInConnectedScenes?.overrideUserInterfaceStyle {
        case .light:
            switchMode.isOn = false
            switchSystem.isOn = true
            break
        case .dark:
            switchMode.isOn = true
            switchSystem.isOn = false
            break
        default:
            switchMode.isOn = false
            switchSystem.isOn = true
        }
    }
    
    override func backBtnTapAction() {
        Global.setVibration()
        self.dismiss(animated: true)
    }
    
    @IBAction func btnSaveTapAction(_ sender: UIButton) {
        Global.setVibration()
        let mode = switchMode.isOn ? EnumUserInterfaceStyle.dark : EnumUserInterfaceStyle.unspecified
        UserDefaults.standard.set(mode.rawValue, forKey: Constants.kUserInterfaceStyle)
        UIApplication.shared.keyWindowInConnectedScenes?.overrideUserInterfaceStyle = mode == .dark ? .dark : .unspecified
        self.dismiss(animated: true)
    }
    
    
    @IBAction func modeChange(_ sender: UISwitch) {
        switchSystem.isOn = sender.isOn ? false : true
    }
    
    @IBAction func systemDefined(_ sender: UISwitch) {
        switchMode.isOn = sender.isOn ? false : true
    }
}

extension UIApplication {
    
    /// The app's key window.
    var keyWindowInConnectedScenes: UIWindow? {
        let windowScenes: [UIWindowScene] = connectedScenes.compactMap({ $0 as? UIWindowScene })
        let windows: [UIWindow] = windowScenes.flatMap({ $0.windows })
        return windows.first(where: { $0.isKeyWindow })
    }
    
}
