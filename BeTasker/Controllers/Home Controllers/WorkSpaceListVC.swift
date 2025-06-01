//
//  WorkSpaceListVC.swift
//  teamAlerts
//
//  Created by MAC on 28/01/25.
//

import Foundation
import BottomPopup
import SDWebImage
protocol WorkSpaceSelectclose:AnyObject {
    func workSpaceSelectionChange(selectedWS:WorkSpaceDataViewModel)
}
class WorkSpaceListVC: BottomPopupViewController {
    
    @IBOutlet weak var vwContainer: UIView!
    @IBOutlet weak var tblworkSpaces: UITableView!
    
    
    @IBOutlet weak var addWorkSpaceButton: UIButton!
    private var containerHeight: CGFloat = Constants.kScreenHeight // Variable to store vwContainer height
    
    override var popupHeight: CGFloat {
        return containerHeight // Use the updated container height
    }
    
    override var popupTopCornerRadius: CGFloat {
        return 38
    }
        
    var currentWorkSpace: WorkSpaceDataViewModel?
    weak var delegate: WorkSpaceSelectclose?
    let refreshControl = UIRefreshControl()

    var arrworkSpaces = [WorkSpaceDataViewModel]()
    var groupId: Int?
    var canManageMembers = false
    var requestStatus = false
    var page: Int = 1
    var limit: Int = 10000
    var isPresented = false
    var isOpenedForMyPrograms: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vwContainer.layer.cornerRadius = 24
        vwContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        addWorkSpaceButton.imageView?.contentMode = .scaleAspectFit
        
        tblworkSpaces.rowHeight = UITableView.automaticDimension
        tblworkSpaces.estimatedRowHeight = UITableView.automaticDimension
        addWorkSpaceButton.layer.cornerRadius = addWorkSpaceButton.frame.height / 2
        
        refreshControl.addTarget(self, action: #selector(RefreshList), for: .valueChanged)
        tblworkSpaces.addSubview(refreshControl)
        
        self.tblworkSpaces.reloadData()
        GetWorkSpaces(shouldShowLoader: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Update the container height dynamically
        //containerHeight = vwContainer.bounds.height
        containerHeight = Constants.kScreenHeight * 0.66
        self.updatePopupHeight(to: containerHeight)
    }
    
    @IBAction func addWorkSpaceTapped(_ sender: UIButton) {
        Global.setVibration()
        let vc = Constants.WorkSpace.instantiateViewController(withIdentifier: "AddWorkSpaceVC") as! AddWorkSpaceVC
        vc.delegate = self
        let nvc = UINavigationController(rootViewController: vc)
        nvc.isModalInPresentation = true
        self.present(nvc, animated: true, completion: nil)
    }
}

extension WorkSpaceListVC: PrClose {
    func closedDelegateAction() {
        RefreshList()
    }
}

//MARK: UITableViewDelegate, UITableViewDataSource
extension WorkSpaceListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrworkSpaces.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WorkSpaceCell", for: indexPath) as! WorkSpaceCell
        cell.selectionStyle = .none
        if arrworkSpaces.count > indexPath.row {
            let workSpace = arrworkSpaces[indexPath.row]
            cell.lblWSName.text = workSpace.workSpaceName
            let member_count = workSpace.numberOfmembers
            cell.lblWSMember.text = "\(member_count) \("membre".localized)"

            if member_count > 1 {
                cell.lblWSMember.text = "\(member_count) \("membres".localized)"
            }
            cell.imgCheck.isHighlighted = workSpace.isSelected
            let pendingTaskCount = workSpace.numberOfUrgentTasks
            if pendingTaskCount > 0 {
                cell.notificationCountContainer.isHidden = false
                cell.countLabel.text = "\(pendingTaskCount)"
            } else {
                cell.notificationCountContainer.isHidden = true
            }
            cell.imgWorkSpace.sd_imageIndicator = SDWebImageActivityIndicator.white
            cell.imgWorkSpace.sd_imageTransition = SDWebImageTransition.fade
            let img = UIImage(named: "emptyImage")
            cell.imgWorkSpace.sd_setImage(with: workSpace.workSpaceLogoURL, placeholderImage: img)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Global.setVibration()
        arrworkSpaces[indexPath.row].isSelected = !arrworkSpaces[indexPath.row].isSelected
        tableView.reloadData()
        self.dismiss(animated: true) {
            HpGlobal.shared.selectedWorkspace = self.arrworkSpaces[indexPath.row]
            NotificationCenter.default.post(name: .workspaceSelectedNotification, object: self.arrworkSpaces[indexPath.row])
            self.delegate?.workSpaceSelectionChange(selectedWS: self.arrworkSpaces[indexPath.row])

        }
    }
}
// MARK: - Api Functions
extension WorkSpaceListVC {
    @objc func RefreshList() {
        GetWorkSpaces(shouldShowLoader: false)
    }
    
    func GetWorkSpaces(shouldShowLoader: Bool) {
        WorkSpaceViewModel.GetWorkSpaceList( page: page, limit: limit, sender: self, shouldShowLoader: shouldShowLoader) { arrMembers,totalTask  in
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
                var updatedArray: [WorkSpaceDataViewModel] = []
                if self.isOpenedForMyPrograms {
                    updatedArray = arrMembers.filter { $0.isAdmin }
                } else {
                    updatedArray = arrMembers
                }
                if let currenWorkSpace = self.currentWorkSpace {
                    var arr = updatedArray
                        if let idx = arr.firstIndex(where: {$0.id == currenWorkSpace.id}) {
                            arr[idx].isSelected = true
                        }
                    self.arrworkSpaces = arr
                } else {
                    self.arrworkSpaces = updatedArray
                }
                
                self.tblworkSpaces.reloadData()
            }
        }
    }

    
}
class WorkSpaceCell: UITableViewCell {
    @IBOutlet weak var lblWSName: UILabel!
    @IBOutlet weak var lblWSMember: UILabel!
    @IBOutlet weak var imgCheck: UIImageView!
    @IBOutlet weak var imgWorkSpace: UIImageView!
    
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var notificationCountContainer: UIView!
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        DispatchQueue.main.async { [self] in
            notificationCountContainer.layer.cornerRadius = notificationCountContainer.frame.height / 2
            notificationCountContainer.clipsToBounds = true
        }
       
    }
}
