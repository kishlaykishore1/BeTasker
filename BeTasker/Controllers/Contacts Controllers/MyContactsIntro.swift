//
//  MyContactsIntro.swift
//  BeTasker
//
//  Created by kishlay kishore on 06/03/25.
//

import UIKit

class MyContactsIntro: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var btnGotIt: UIButton!
    
    // MARK: - Properties
    var navController: ProfileVC?
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async { [self] in
            btnGotIt.applyShadow(radius: 3, opacity: 0.1, offset: CGSize(width: 0.0, height: 3.0))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    // MARK: - Button Action Methods
    @IBAction func btnGotItTapAction(_ sender: UIButton) {
        Global.setVibration()
            UserDefaults.standard.set(true, forKey: Constants.kMemberContactIntroShown)
            let vc = Constants.Profile.instantiateViewController(withIdentifier: "MyContactsListVC") as! MyContactsListVC
            self.navigationController?.pushViewController(vc, animated: true)
    }
}
