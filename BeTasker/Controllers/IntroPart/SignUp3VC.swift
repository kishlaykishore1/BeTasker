//
//  SignUp3VC.swift
//  EasyAC
//
//  Created by MAC3 on 27/04/23.
//

import UIKit

class SignUp3VC: UIViewController {

    //MARK: IBOutlets
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var dtPicker: UIDatePicker!
    @IBOutlet weak var viewBtn: UIView!
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        btnNext.layer.cornerRadius = btnNext.frame.height/2
        // Do any additional setup after loading the view.
        DispatchQueue.main.async { [self] in
            viewBtn.applyShadow(radius: 3, opacity: 0.1, offset: CGSize(width: 0.0, height: 3.0))
        }
        setBackButton(isImage: true)
        let calendar = Calendar(identifier: .gregorian)
        dtPicker.maximumDate = calendar.date(byAdding: .year, value: -13, to: Date())
        dtPicker.date = calendar.date(byAdding: .year, value: -13, to: Date())!
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    override func backBtnTapAction() {
        Global.setVibration()
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func btnAddLaterTapAction(_ sender: UIButton) {
        Global.setVibration()
        //Constants.kAppDelegate.isUserLogin(true)
        let vc = Constants.Main.instantiateViewController(withIdentifier: "SignUp4VC") as! SignUp4VC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnNextTapAction(_ sender: UIButton) {
        Global.setVibration()
        let dtString = Global.GetFormattedDate(date: dtPicker.date, outputFormate: "yyyy-MM-dd", isInputUTC: true, isOutputUTC: true).dateString
        HpGlobal.shared.registrationData?.dateOfBirth = dtString ?? ""
        let vc = Constants.Main.instantiateViewController(withIdentifier: "SignUp4VC") as! SignUp4VC
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
