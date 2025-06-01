//
//  WelcomeVC.swift
//  EasyAC
//
//  Created by MAC3 on 27/04/23.
//

import UIKit

class WelcomeVC: UIViewController {

    //MARK: IBOutlets
    @IBOutlet weak var btnBegin: UIButton!
    @IBOutlet weak var btnView: UIView!
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        btnBegin.layer.cornerRadius = btnBegin.frame.height / 2
        // Do any additional setup after loading the view.
        DispatchQueue.main.async { [self] in
            btnView.applyShadow(radius: 3, opacity: 0.1, offset: CGSize(width: 0.0, height: 3.0))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }

    @IBAction func btnContinueTapAction(_ sender: UIButton) {
        Global.setVibration()
        //HpGlobal.shared.registrationData = ProfileDataViewModel(data: ProfileDataModel())
        let vc = Constants.Main.instantiateViewController(withIdentifier: "SignUp1VC") as! SignUp1VC
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
