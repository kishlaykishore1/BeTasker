//
//  SignUpSuccessVC.swift
//  EasyAC
//
//  Created by MAC3 on 28/04/23.
//

import UIKit

class SignUpSuccessVC: UIViewController {
    
    //MARK: IBOutlets
    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var viewBtn: UIView!
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        btnStart.layer.cornerRadius = btnStart.frame.height/2
        // Do any additional setup after loading the view.
        DispatchQueue.main.async { [self] in
            viewBtn.applyShadow(radius: 3, opacity: 0.1, offset: CGSize(width: 0.0, height: 3.0))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func btnStartTapAction(_ sender: UIButton) {
        Global.setVibration()
        Constants.kAppDelegate.isUserLogin(true)
    }
}
