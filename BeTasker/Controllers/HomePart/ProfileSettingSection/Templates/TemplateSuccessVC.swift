//
//  TemplateSuccessVC.swift
//  teamAlerts
//
//  Created by B2Cvertical A++ on 09/05/24.
//

import UIKit

class TemplateSuccessVC: UIViewController {
    //MARK: IBOutlets
    @IBOutlet weak var btnReturn: UIButton!
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        NotificationCenter.default.post(name: .updateRoomList, object: nil)
        self.navigationController?.dismiss(animated: true)
    }
}
