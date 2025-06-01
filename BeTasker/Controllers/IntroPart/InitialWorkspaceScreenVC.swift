//
//  InitialWorkspaceScreenVC.swift
//  BeTasker
//
//  Created by kishlay kishore on 07/05/25.
//

import UIKit

class InitialWorkspaceScreenVC: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var viewShareId: UIView!
    @IBOutlet weak var viewAddWorkspace: UIView!
    
    // MARK: - Variables
    var workspaceAdded: (() -> Void)?
    var workspaceTimer: Timer?
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        startWorkspaceTimer()
        self.viewShareId.applyShadow(radius: 3, opacity: 0.1, offset: CGSize(width: 0.0, height: 3.0))
        self.viewAddWorkspace.applyShadow(radius: 3, opacity: 0.1, offset: CGSize(width: 0.0, height: 3.0))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        self.setNavigationBarImage(color: .clear, requireShadowLine: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        workspaceTimer?.invalidate()
        workspaceTimer = nil
    }
    
    func startWorkspaceTimer() {
        workspaceTimer = Timer.scheduledTimer(withTimeInterval: 25.0, repeats: true) { [weak self] _ in
            self?.callWorkSpaceAPI()
        }
    }

   // MARK: - Button Action Methods
    @IBAction func btnShareID(_ sender: UIButton) {
        Global.setVibration()
        guard let popupViewController = Constants.Profile.instantiateViewController(withIdentifier: "DisplayScannerVC") as? DisplayScannerVC else { return }
        present(popupViewController, animated: true, completion: nil)
    }
    
    @IBAction func btnAddWorkspace(_ sender: UIButton) {
        Global.setVibration()
        let vc = Constants.WorkSpace.instantiateViewController(withIdentifier: "AddWorkSpaceVC") as! AddWorkSpaceVC
        vc.delegate = self
        let nvc = UINavigationController(rootViewController: vc)
        nvc.isModalInPresentation = true
        self.present(nvc, animated: true, completion: nil)
    }
    
    @IBAction func btnLogout_Action(_ sender: UIButton) {
        Global.setVibration()
        let alert  = UIAlertController(title: Messages.txtDeleteAlert, message: Messages.logoutMsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Messages.txtDeleteConfirm, style: .destructive, handler: { _ in
            HpAPI.STATIC.apiLogoutUser()
            Constants.kAppDelegate.isUserLogin(false)
        }))
        alert.addAction(UIAlertAction(title: Messages.txtCancel, style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func btnDeleteAccount_Action(_ sender: UIButton) {
        Global.setVibration()
        let alertController = UIAlertController(title: Messages.txtDeleteAlert, message: Messages.deleteAccountMsg, preferredStyle: .alert)
        let logoutAction = UIAlertAction(title: Messages.txtDeleteAccount, style: .destructive, handler: { alert -> Void in
            HpAPI.DELETEACCOUNT.DataAPI(params: [:], shouldShowError: true, shouldShowSuccess: true, key: nil) { (response: Result<GeneralModel, Error>) in
                DispatchQueue.main.async {
                    Global.dismissLoadingSpinner()
                    switch response {
                    case .success(_):
                        HpAPI.STATIC.clearLogoutDataFromApp()
                        Constants.kAppDelegate.isUserLogin(false)
                        break
                    case .failure(_):
                        break
                    }
                }
            }
        })
        let cancelAction = UIAlertAction(title: Messages.txtCancel, style: .cancel, handler: { (action : UIAlertAction!) -> Void in
        })
        alertController.addAction(logoutAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
}

// MARK: - Api Methods
extension InitialWorkspaceScreenVC {
    func callWorkSpaceAPI() {
        WorkSpaceViewModel.GetWorkSpaceList( page: 1, limit: 1000, sender: self, shouldShowLoader: true) { [weak self] workSpaceList, totalTaskPending in
            DispatchQueue.main.async {
                if workSpaceList.count > 0 {
                    self?.dismiss(animated: true) {
                        self?.workspaceAdded?()
                    }
                }
            }
        }
    }
}

// MARK: - Close Delegate Methods
extension InitialWorkspaceScreenVC: PrClose {
    func closedDelegateAction() {
        self.dismiss(animated: true) {
            self.workspaceAdded?()
        }
    }
}
