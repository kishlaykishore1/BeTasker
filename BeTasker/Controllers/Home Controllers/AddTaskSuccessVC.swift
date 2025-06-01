//
//  AddTaskSuccessVC.swift
//  teamAlerts
//
//  Created by B2Cvertical A++ on 26/11/24.
//

import UIKit

class AddTaskSuccessVC: UIViewController {
    //MARK: IBOutlets
    @IBOutlet weak var btnReturn: UIButton!
    
    var tabBarVC: UITabBarController?
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnReturn.layer.cornerRadius = btnReturn.frame.height / 2
        // Do any additional setup after loading the view.
        DispatchQueue.main.async { [self] in
            btnReturn.applyShadow(radius: 3, opacity: 0.1, offset: CGSize(width: 0.0, height: 3.0))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func btnReturnTapAction(_ sender: UIButton) {
        Global.setVibration()
        self.tabBarVC?.selectedIndex = 0
        self.dismiss(animated: true)
    }
}
