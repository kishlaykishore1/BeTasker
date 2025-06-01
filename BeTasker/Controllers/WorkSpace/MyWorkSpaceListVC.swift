//
//  MyWorkSpaceListVC.swift
//  teamAlerts
//
//  Created by MAC on 29/01/25.
//

import UIKit
import SDWebImage

class MyWorkSpaceListVC: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var viewEmpty: UIView!
    
    // MARK: - Properties
    let refreshControl = UIRefreshControl()
    var arrworkSpaces = [WorkSpaceDataViewModel]()
    var groupId: Int?
    var canManageMembers = false
    var requestStatus = false
    var page: Int = 1
    var limit: Int = 10000
    var isPresented = false
    var isFromNotify = false
    
    // MARK: - View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        viewEmpty.isHidden = true
        tblView.delegate = self
        tblView.dataSource = self
        refreshControl.addTarget(self, action: #selector(RefreshList), for: .valueChanged)
        tblView.addSubview(refreshControl)
        NotificationCenter.default.addObserver(self, selector: #selector(RefreshList), name: .updateMembersList, object: nil)
        GetWorkSpaces(shouldShowLoader: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.title = "Espaces de travail".localized
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.color191919 as Any,
            .font: UIFont(name: Constants.KGraphikMedium, size: 14)!
        ]
        let attributes2: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.color191919 as Any,
            .font: UIFont(name: Constants.KGraphikMedium, size: 33)!
        ]
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        self.navigationController?.navigationBar.largeTitleTextAttributes = attributes2
        setBackButton(isImage: true)
        setRightButton(isImage: true, image: UIImage(named: "plus") ?? UIImage(), inset: UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2))
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func backBtnTapAction() {
        Global.setVibration()
        if isPresented {
            self.dismiss(animated: true)
        } else if isFromNotify {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.navigationController?.backToViewController(vc: ProfileVC.self)
        }
    }
    
    override func rightBtnTapAction(sender: UIButton) {
        btnAddWorkSpaceAction(sender)
    }
    
    // MARK: - Button Action Method
    @IBAction func showTable(_ sender: UIControl) {
        btnAddWorkSpaceAction(sender)
    }
    
    func btnMoreTapaction(workSpace: WorkSpaceDataViewModel, sender: UIButton, idx: Int) {
        Global.setVibration()
        
        let alert = UIAlertController(title: "\(workSpace.workSpaceName)", message: nil, preferredStyle: .actionSheet)
        
        let viewMemberAction = UIAlertAction(title: "Voir les membres".localized, style: .default, handler: { _ in
            self.showMemberListFor(workSpace: workSpace, sender: sender, idx: idx)
            
        })
        alert.addAction(viewMemberAction)
        
        if workSpace.isAdmin || workSpace.isWorkspaceCreator {
            let editWorkspaceAction = UIAlertAction(title: "Modifier l'espace de travail".localized, style: .default, handler: { _ in
                self.editThisWorkSpace(index: idx)
                
            })
            alert.addAction(editWorkspaceAction)
        }
        
        
        if self.arrworkSpaces.count > 1 && (workSpace.isAdmin || workSpace.isWorkspaceCreator) {
            let deleteAction = UIAlertAction(title: "Supprimer l’espace de travail".localized, style: .destructive, handler: { _ in
                self.showDeleteWorkSpaceConfirmation(workSpace: workSpace, sender: sender, idx: idx)
                
            })
            alert.addAction(deleteAction)
        }
        
        alert.addAction(UIAlertAction.init(title: Messages.txtCancel, style: .cancel, handler: nil))
        alert.popoverPresentationController?.sourceView = sender
        alert.popoverPresentationController?.sourceRect = sender.bounds
        alert.popoverPresentationController?.permittedArrowDirections = .up
        self.present(alert, animated: true, completion: nil)
    }
    
    func showDeleteWorkSpaceConfirmation(workSpace: WorkSpaceDataViewModel, sender: UIButton, idx: Int) {
        Global.setVibration()
        //if self.arrworkSpaces.count > 1 {
            let alert  = UIAlertController(title: "Supprimer l'espace de travail".localized, message: "Etes-vous sûr de vouloir supprimer l'espace de travail ?".localized, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: Messages.txtDeleteConfirm, style: .destructive, handler: { _ in
                WorkSpaceViewModel.DeleteWorkSpace(sender: self, id: workSpace.id, groupId: 0) { isDone in
                    DispatchQueue.main.async {
                        if isDone {
                            self.arrworkSpaces.remove(at: idx)
                            self.viewEmpty.isHidden = self.arrworkSpaces.count > 0
                            self.tblView.reloadData()
                        }
                    }
                }
            }))
            alert.addAction(UIAlertAction(title: Messages.txtCancel, style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
//        } else {
//            Common.showAlertMessage(message: "At least one workSpace Required.", alertType: .error, isPreferLightStyle: false)
//        }
    }
    
    func showMemberListFor(workSpace: WorkSpaceDataViewModel, sender: UIButton, idx: Int) {
        Global.setVibration()
        let vc = Constants.WorkSpace.instantiateViewController(withIdentifier: "WorkSpaceMemberListVC") as! WorkSpaceMemberListVC
        vc.currentWorkSpace = workSpace
        vc.workSpaceId = workSpace.id
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func editThisWorkSpace(index: Int) {
        if arrworkSpaces.count > index && (arrworkSpaces[index].isAdmin || arrworkSpaces[index].isWorkspaceCreator) {
            let data = arrworkSpaces[index]
            let workSpaceId = data.id
            let vc = Constants.WorkSpace.instantiateViewController(withIdentifier: "AddWorkSpaceVC") as! AddWorkSpaceVC
            vc.delegate = self
            vc.workSpaceId = workSpaceId
            vc.workSpaceName = data.workSpaceName
            let nvc = UINavigationController(rootViewController: vc)
            nvc.isModalInPresentation = true
            self.present(nvc, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnAddWorkSpaceAction(_ sender: Any) {
        Global.setVibration()
        if PremiumManager.shared.canCreateWorkspace(worspaceCount: arrworkSpaces.count) {
            let vc = Constants.WorkSpace.instantiateViewController(withIdentifier: "AddWorkSpaceVC") as! AddWorkSpaceVC
            vc.delegate = self
            let nvc = UINavigationController(rootViewController: vc)
            nvc.isModalInPresentation = true
            self.present(nvc, animated: true, completion: nil)
        } else {
            PremiumManager.shared.openPremiumScreen()
        }
    }
}

extension MyWorkSpaceListVC: PrClose {
    func closedDelegateAction() {
        RefreshList()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension MyWorkSpaceListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrworkSpaces.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MembersTblViewCell", for: indexPath) as! MembersTblViewCell
        cell.selectionStyle = .none
        if arrworkSpaces.count > indexPath.row {
            let data = arrworkSpaces[indexPath.row]
            cell.lblName.text = data.workSpaceName
            cell.lblEmail.text = "\(data.numberOfmembers) \("membre".localized)"
            
            if data.numberOfmembers > 1
            {
                cell.lblEmail.text = "\(data.numberOfmembers) \("membres".localized)"
                
            }
            cell.imgProfile.sd_imageIndicator = SDWebImageActivityIndicator.white
            cell.imgProfile.sd_imageTransition = SDWebImageTransition.fade
            let img = UIImage(named: "emptyImage")
            cell.imgProfile.sd_setImage(with: data.workSpaceLogoURL, placeholderImage: img)
            cell.moreMenuClosure = { [weak self] sender in
                self?.btnMoreTapaction(workSpace: data, sender: sender, idx: indexPath.row)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Global.setVibration()
        self.editThisWorkSpace(index: indexPath.row)
    }
}

extension MyWorkSpaceListVC {
    @objc func RefreshList() {
        GetWorkSpaces(shouldShowLoader: false)
    }
    
    func GetWorkSpaces(shouldShowLoader: Bool) {
        WorkSpaceViewModel.GetMyWorkSpaceList( page: page, limit: limit, sender: self, shouldShowLoader: shouldShowLoader) { arrMembers, totalTask  in
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
                self.arrworkSpaces = arrMembers
                self.viewEmpty.isHidden = arrMembers.count > 0
                self.tblView.reloadData()
            }
        }
    }
    
    
}
