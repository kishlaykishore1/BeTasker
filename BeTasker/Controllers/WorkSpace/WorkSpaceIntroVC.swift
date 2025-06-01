//
//  WorkSpaceIntroVC.swift
//  teamAlerts
//
//  Created by MAC on 29/01/25.
//

import UIKit

class WorkSpaceIntroVC: UIViewController {
    
    //MARK: IBOutlets
    @IBOutlet weak var btnGotIt: UIButton!
    
    var isPresented = false
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        DispatchQueue.main.async { [self] in
            btnGotIt.applyShadow(radius: 3, opacity: 0.1, offset: CGSize(width: 0.0, height: 3.0))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.isNavigationBarHidden = true
            
    }
    
    @IBAction func btnGotItTapAction(_ sender: UIButton) {
        Global.setVibration()
        
        UserDefaults.standard.set(true, forKey: Constants.kWorkSpaceIntroShown)
        let vc = Constants.WorkSpace.instantiateViewController(withIdentifier: "MyWorkSpaceListVC") as! MyWorkSpaceListVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
