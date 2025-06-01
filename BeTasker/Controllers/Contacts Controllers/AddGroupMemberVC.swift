//
//  AddGroupMemberVC.swift
//  teamAlerts
//
//  Created by B2Cvertical A++ on 29/11/24.
//

import UIKit
import SDWebImage
import BottomPopup

enum AddType {
    case search
    case found
    case retry
}

class AddGroupMemberVC: BottomPopupViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var btnNewSearch: UIButton!
    @IBOutlet weak var btnTryAgain: UIView!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var vwEmpty: UIView!
    @IBOutlet weak var vwUserContainer: UIView!
    @IBOutlet weak var workSpaceCollectionView: UICollectionView!
    @IBOutlet weak var vwSearchUserContainer: UIView!
    @IBOutlet weak var vwButton: UIView!
    @IBOutlet weak var vwContainer: UIView!
    @IBOutlet weak var lblButtonTitle: UILabel!
    @IBOutlet weak var btnAddUser: UIView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lblSmallNavTitle: UILabel!
    @IBOutlet weak var viewForAddWorkspace: UIView!
    @IBOutlet weak var segmentControll: UISegmentedControl!
    @IBOutlet weak var viewNotMember: UIView!
    @IBOutlet weak var lblNotMember: UILabel!
    @IBOutlet weak var btnScanQR: UIButton!
    
    // MARK: - Properties
    private var containerHeight: CGFloat = Constants.kScreenHeight // Variable to store vwContainer height
    override var popupHeight: CGFloat {
        return containerHeight // Use the updated container height
    }
    override var popupTopCornerRadius: CGFloat {
        return 38
    }
    weak var delegate: PrClose?
    var isLayoutDone = false
    var selectedMember: MembersDataViewModel?
    var currentSelectedWorkspace: WorkSpaceDataViewModel?
    var arrworkSpaces = [WorkSpaceDataViewModel]()
    var isfromWorkspace: Bool = false
    var currentView: AddType = .search
    var randomId: String?
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.vwButton.applyShadow(radius: 3, opacity: 0.1, offset: CGSize(width: 0.0, height: 3.0))
        fixBackgroundSegmentControl(self.segmentControll)
        isfromWorkspace ? (viewForAddWorkspace.isHidden = true) : (viewForAddWorkspace.isHidden = false)
        self.segmentControll.defaultConfiguration(color: .color00000036)
        self.segmentControll.selectedConfiguration(color: .colorFFFFFF000000)
        let tapLabel = UITapGestureRecognizer(target: self, action: #selector(tapLabel(tap:)))
        lblNotMember.addGestureRecognizer(tapLabel)
        lblNotMember.isUserInteractionEnabled = true
        self.setupContactShareText()
        if let id = randomId {
            searchMemberData(searchID: id)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !isLayoutDone {
            isLayoutDone = true
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.vwContainer.roundCorners([.topLeft, .topRight], radius: 38)
                let containerHeight = self.vwContainer.bounds.height
                self.updatePopupHeight(to: containerHeight)
            }
        }
    }
    
    // MARK: - Helper Methods
    func fixBackgroundSegmentControl( _ segmentControl: UISegmentedControl){
        if #available(iOS 13.0, *) {
            //just to be sure it is full loaded
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                for i in 0...(segmentControl.numberOfSegments-1)  {
                    let backgroundSegmentView = segmentControl.subviews[i]
                    //it is not enogh changing the background color. It has some kind of shadow layer
                    backgroundSegmentView.isHidden = true
                }
            }
        }
    }
    
    func setupDisplayViews(type: AddType, data: MembersDataViewModel? = nil) {
        switch type {
        case .search:
            isLayoutDone = false
            lblSmallNavTitle.isHidden = true
            vwSearchUserContainer.isHidden = false
            vwUserContainer.isHidden = true
            vwEmpty.isHidden = true
            vwButton.isHidden = false
            btnAddUser.isHidden = true
            btnNewSearch.isHidden = true
            btnTryAgain.isHidden = true
            viewNotMember.isHidden = false
        case .found:
            self.selectedMember = data
            let img = #imageLiteral(resourceName: "no-user")
            self.imgUser.sd_imageIndicator = SDWebImageActivityIndicator.gray
            self.imgUser.sd_imageTransition = SDWebImageTransition.fade
            self.imgUser.sd_setImage(with: data?.profilePicURL, placeholderImage: img)
            self.lblName.text = data?.fullNameFormatted
            self.lblSmallNavTitle.isHidden = false
            self.viewNotMember.isHidden = true
            if var workspace = currentSelectedWorkspace {
                workspace.isSelected = true
                self.arrworkSpaces = [workspace]
            } else {
                self.arrworkSpaces = []
            }
            var obj = WorkSpaceDataModel()
            obj.isAddType = true
            self.arrworkSpaces.append(WorkSpaceDataViewModel(data: obj))
            self.workSpaceCollectionView.reloadData()
        case .retry:
            self.selectedMember = nil
            self.imgUser.image = #imageLiteral(resourceName: "no-user")
            self.lblName.text = nil
            self.vwSearchUserContainer.isHidden = true
            self.vwUserContainer.isHidden = true
            self.vwEmpty.isHidden = false
            self.vwButton.isHidden = true
            self.btnAddUser.isHidden = true
            self.btnNewSearch.isHidden = true
            self.btnTryAgain.isHidden = false
            self.lblSmallNavTitle.isHidden = true
            self.viewNotMember.isHidden = false
        }
        let containerHeight = self.vwContainer.bounds.height
        self.updatePopupHeight(to: containerHeight)
    }
    
    func setupContactShareText() {
        let clr = #colorLiteral(red: 0.631372549, green: 0.631372549, blue: 0.631372549, alpha: 1)
        lblNotMember.numberOfLines = 0
        lblNotMember.textColor = clr
        let txtYourContact = NSMutableAttributedString(string: "Votre contact n’est pas encore sur BeTasker ? \n".localized, attributes: [NSAttributedString.Key.foregroundColor: clr, NSAttributedString.Key.font: UIFont(name: Constants.KGraphikRegular, size: lblNotMember.font.pointSize) ?? UIFont.systemFont(ofSize: lblNotMember.font.pointSize, weight: .regular)])
        let txtDownload = NSMutableAttributedString(string: "Invitez-le à télécharger l’app".localized, attributes: [NSAttributedString.Key.foregroundColor: clr, NSAttributedString.Key.font: UIFont(name: Constants.KGraphikMedium, size: lblNotMember.font.pointSize) ?? UIFont.systemFont(ofSize: lblNotMember.font.pointSize, weight: .medium)])
        let finalString = NSMutableAttributedString()
        finalString.append(txtYourContact)
        finalString.append(txtDownload)
        lblNotMember.attributedText = finalString
    }
    
    @objc func tapLabel(tap: UITapGestureRecognizer) {
        Global.setVibration()
        let textToShare = Global.shareToConnect()
        let activityVC = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
        activityVC.setValue("Découvre l'app BeTasker".localized, forKey: "Subject")
        self.present(activityVC, animated: true, completion: nil)
    }
    
    func searchMemberData(searchID: String) {
        Global.showLoadingSpinner(sender: self.vwContainer)
        MembersViewModel.SearchMembersList(groupId: 0, searchKeyword: searchID, shouldShowInfo: true, sender: self) { memberData in
            if !memberData.isAlreadyAdded {
                let arrUsers = memberData.arrMembers
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    Global.dismissLoadingSpinner(self.vwContainer)
                    
                    self.txtSearch.text = nil
                    
                    self.isLayoutDone = false
                    self.vwSearchUserContainer.isHidden = true
                    self.vwUserContainer.isHidden = false
                    self.vwEmpty.isHidden = true
                    self.vwButton.isHidden = true
                    self.btnAddUser.isHidden = false
                    self.btnNewSearch.isHidden = false
                    self.btnTryAgain.isHidden = true
                    self.viewNotMember.isHidden = false
                    
                    if let data = arrUsers.first {
                        setupDisplayViews(type: .found, data: data)
                    } else {
                        setupDisplayViews(type: .retry)
                    }
                }
            } else {
                Global.dismissLoadingSpinner(self.vwContainer)
            }
        }
    }
    
    // MARK: - Button Action Methods
    @IBAction func searchAction(_ sender: Any) {
        Global.setVibration()
        self.view.endEditing(true)
        guard let user = txtSearch.text?.replacingOccurrences(of: "#", with: "").trim(), user != "" else { return }
        searchMemberData(searchID: user)
    }
    
    @IBAction func newSearch(_ sender: Any) {
        Global.setVibration()
        setupDisplayViews(type: .search)
    }
    
    @IBAction func searchAgain(_ sender: Any) {
        setupDisplayViews(type: .search)
    }
    
    @IBAction func addUserAction(_ sender: Any) {
        Global.setVibration()
        var params: [String: Any] = [
            "lc": Constants.lc,
            "access_type": AccessType.Limited.rawValue,
            "manage_members": 0,
            "member_user_id": selectedMember?.id ?? 0, //selectedMember?.memberUserId ?? 0,
            "group_id": 0,
            "workspcae_id": arrworkSpaces.filter({ $0.isSelected }).map({"\($0.id)"}).joined(separator: ",")
        ]
        
        if arrworkSpaces.filter({ $0.isSelected }).count > 0 {
            params["type"] = segmentControll.selectedSegmentIndex == 0 ? "member" : "admin"
        }
        HpAPI.addMember.DataAPI(params: params, shouldShowError: true, shouldShowSuccess: false, key: nil) { (response: Result<GeneralModel, Error>) in
            DispatchQueue.main.async { [unowned self] in
                Global.dismissLoadingSpinner(self.view)
                switch response {
                case .success(_):
                    self.dismiss(animated: true) {
                        self.delegate?.closedDelegateAction()
                    }
                    break
                case .failure(_):
                    break
                }
            }
        }
        
    }
    
    @IBAction func btnScanQr_Action(_ sender: UIButton) {
        Global.setVibration()
        let vc = Constants.Profile.instantiateViewController(withIdentifier: "QRScannerVC") as! QRScannerVC
        vc.delegate = self
        let rootNavView = UINavigationController(rootViewController: vc)
        rootNavView.modalPresentationStyle = .fullScreen
        self.present(rootNavView, animated: true)
    }
    
}

// MARK: - Collection view Delegate And DataSource methods
extension AddGroupMemberVC: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrworkSpaces.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if arrworkSpaces[indexPath.row].isAddType {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddMoreCollectionCell", for: indexPath) as! AddMoreCollectionCell
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UsersViewCollectionCell", for: indexPath) as! UsersViewCollectionCell
            cell.removeActionClosure = {[weak self] in
                self?.arrworkSpaces.remove(at: indexPath.row)
                self?.workSpaceCollectionView.reloadData()
            }
            
            cell.lblName.text = arrworkSpaces[indexPath.row].workSpaceName
            let img = UIImage(named: "emptyImage")
            cell.imgProfile.sd_imageIndicator = SDWebImageActivityIndicator.white
            cell.imgProfile.sd_imageTransition = SDWebImageTransition.fade
            cell.imgProfile.sd_setImage(with: arrworkSpaces[indexPath.row].workSpaceLogoURL, placeholderImage: img)
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Global.setVibration()
        if arrworkSpaces[indexPath.row].isAddType {
            let vc = Constants.Profile.instantiateViewController(withIdentifier: "SelectWorkspaceVC") as! SelectWorkspaceVC
            vc.arrWorkspaces = self.arrworkSpaces.dropLast()
            vc.delegate = self
            let nvc = UINavigationController(rootViewController: vc)
            nvc.isModalInPresentation = true
            self.present(nvc, animated: true, completion: nil)
        }
    }
}

// MARK: - Protocol Methods
extension AddGroupMemberVC: PrSelectedWorkspaces, QRScannerDelegate {
    
    func setSelectedWorkspaces(arrWorkspaces: [WorkSpaceDataViewModel]) {
        self.arrworkSpaces = arrWorkspaces
        var obj = WorkSpaceDataModel()
        obj.isAddType = true
        self.arrworkSpaces.append(WorkSpaceDataViewModel(data: obj))
        self.workSpaceCollectionView.reloadData()
    }
    
    func didScan(result: String) {
        if let randomID = Global.extractRandomID(from: result) {
            searchMemberData(searchID: randomID)
        }
    }
    
}
