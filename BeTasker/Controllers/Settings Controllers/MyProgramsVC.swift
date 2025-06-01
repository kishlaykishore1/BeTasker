//
//  MyProgramsVC.swift
//  teamAlerts
//
//  Created by B2Cvertical A++ on 02/12/24.
//

import UIKit
import SDWebImage

class MyProgramsVC: BaseViewController {
    
    // MARK: - outlets
    @IBOutlet weak var vwAddTask: UIView!
    @IBOutlet weak var vwEmpty: UIControl!
    @IBOutlet weak var tblView: UITableView!
    
    // MARK: - Variables
    var arrData = [WorkSpaceOnlyTasksViewModel]()
    let refreshControl:UIRefreshControl = UIRefreshControl()
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(pullRefresh), name: .updateTaksList, object: nil)
        //tblView.applyBorder(width: 1, color: UIColor.colorE8E8E8)
        tblView.applyShadow(radius: 1, opacity: 0.1, offset: CGSize(width: 0, height: 0), color: .black)
        tblView.showsVerticalScrollIndicator = false
        refreshControl.addTarget(self, action: #selector(pullRefresh), for: .valueChanged)
        tblView.refreshControl = refreshControl
        getTaskList()
        getWorkSpaces(shouldShowLoader: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.prefersLargeTitles = false
        self.setNavigationBarImage(for: nil, color: UIColor.colorFFFFFF000000, txtcolor: UIColor.color191919, requireShadowLine: true)
        setBackButton(isImage: true)
        //setRightButton(isImage: true, image: UIImage(named: "plus") ?? UIImage(), inset: UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2))
        self.title = "Mes programmations".localized
    }
    
    override func backBtnTapAction() {
        Global.setVibration()
        self.dismiss(animated: true)
    }
    
    override func rightBtnTapAction(sender: UIButton) {
        Global.setVibration()
        let vc = Constants.Home.instantiateViewController(withIdentifier: "AddTaskVC") as! AddTaskVC
        vc.currentWorkSpace = HpGlobal.shared.selectedWorkspace
        vc.isopenedFromMyProgramVC = true
        let nvc = UINavigationController(rootViewController: vc)
        nvc.isModalInPresentation = true
        self.present(nvc, animated: true, completion: nil)
    }
    
    // MARK: - Helper Methods
    
    func setupTheCellCorner(tableView: UITableView, cellForRowAt indexPath: IndexPath, cell: UITableViewCell) {
        cell.backgroundColor = .clear
        let cornerRadius: CGFloat = 25  // Change as needed
        let maskLayer = CAShapeLayer()
        let bounds = cell.bounds.insetBy(dx: 0, dy: 0) // Adjust horizontal insets
        var corners: UIRectCorner = []
        // Apply rounded corners to first and last cell in a section
        if indexPath.row == 0 {
            corners.insert(.topLeft)
            corners.insert(.topRight)
        }
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            corners.insert(.bottomLeft)
            corners.insert(.bottomRight)
        }
        
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        maskLayer.path = path.cgPath
        
        let backgroundView = UIView(frame: bounds)
        backgroundView.backgroundColor = .colorFFFFFF000000
        backgroundView.layer.mask = maskLayer
        
        cell.backgroundView = backgroundView
    }
    
    private func checkForAdmin(data: TasksViewModel) -> Bool {
        guard let myData = HpGlobal.shared.userInfo else { return false }
        if myData.userId == data.taskAssignerUserId {
            return true
        }
        return false
    }
    
    // MARK: - Button Action Methods
    @IBAction func addNewProgram(_ sender: Any) {
        Global.setVibration()
        let vc = Constants.Home.instantiateViewController(withIdentifier: "AddTaskVC") as! AddTaskVC
        vc.isFromPeogrammimgMenu = true
        let nvc = UINavigationController(rootViewController: vc)
        nvc.isModalInPresentation = true
        self.present(nvc, animated: true, completion: nil)
    }
    
}

// MARK: - TableView Delegate and Datasource
extension MyProgramsVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrData[section].arrTasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let taskData = arrData[indexPath.section].arrTasks[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyProgramsTableViewCell", for: indexPath) as! MyProgramsTableViewCell
        cell.vwBottomLine.isHidden = false
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            cell.vwBottomLine.isHidden = true
        }
        
        if indexPath.row < arrData[indexPath.section].arrTasks.count {
            let data = taskData
            cell.lblTitle.text = data.title
            if data.dayTextFormatted == "" {
                cell.icFlag.isHidden = true
                cell.flagConstraint.constant = 0
                cell.clockConstraint.constant = 0
            } else {
                cell.icFlag.isHidden = false
                cell.flagConstraint.constant = 5
                cell.clockConstraint.constant = 4
            }
            if data.isRecurring {
                cell.statusIndicator.tintColor = UIColor(hexString: "44BA3C")
                cell.lblStatus.text = "ACTIF".localized
                cell.lblStatus.textColor = #colorLiteral(red: 0.2666666667, green: 0.7294117647, blue: 0.2352941176, alpha: 1)
            } else {
                cell.statusIndicator.tintColor = UIColor(hexString: "BC4040")
                cell.lblStatus.text = "INACTIF".localized
                cell.lblStatus.textColor = #colorLiteral(red: 0.737254902, green: 0.2509803922, blue: 0.2509803922, alpha: 1)
            }
            cell.btnMore.isHidden = !checkForAdmin(data: data)
            cell.lblDay.text = data.dayTextFormatted
            if data.scheduleType == "3" {
                cell.lblTime.text = data.formattedStartDate
            } else {
                cell.lblTime.text = data.hour.joined(separator: ", ")
            }
        }
        
        cell.onMoreTapped = { [weak self] in
            self?.showMoreOptions(titleMessage: taskData.title, programData: taskData)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.setupTheCellCorner(tableView: tableView, cellForRowAt: indexPath, cell: cell)
        
        if let cell = cell as? MyProgramsTableViewCell {
            cell.stkView.subviews.forEach { (vw) in
                cell.stkView.removeArrangedSubview(vw)
                vw.removeFromSuperview()
            }
            if indexPath.row < arrData[indexPath.section].arrTasks.count {
                let data = arrData[indexPath.section].arrTasks[indexPath.row]
                for item in data.arrUsers {
                    if let vw = ViewUser.instanceFromNib() as? ViewUser {
                        let img = #imageLiteral(resourceName: "no-user")
                        vw.imgUser.sd_imageIndicator = SDWebImageActivityIndicator.gray
                        vw.imgUser.sd_imageTransition = SDWebImageTransition.fade
                        vw.imgUser.sd_setImage(with: item.profilePicURL, placeholderImage: img)
                        cell.stkView.axis = .horizontal
                        cell.stkView.addArrangedSubview(vw)
                    }
                }
                cell.stkView.spacing = -6
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 44))
        
        let label = UILabel()
        label.frame = CGRect.init(x: 0, y: 0, width: headerView.frame.width, height: headerView.frame.height)
        
        if !arrData.isEmpty {
            label.text = arrData[section].workspaceTitle.capitalized
        }
        label.font = UIFont(name: Constants.KGraphikMedium, size: 16) ?? UIFont()
        label.textColor = UIColor.color363636
        headerView.addSubview(label)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Global.setVibration()
    }
    
}

extension MyProgramsVC {
    
    func sendTaskNow(program: TasksViewModel) {
        self.scheduleTaskNow(taskData: program) {[weak self] done in
            DispatchQueue.main.async {
                guard let self = self else { return }
                //self.pullRefresh()
            }
        }
    }
    
    func editProgram(program: TasksViewModel) {
        let vc = Constants.Home.instantiateViewController(withIdentifier: "AddTaskVC") as! AddTaskVC
        vc.taskId = program.taskId
        vc.isFromPeogrammimgMenu = true
        let nvc = UINavigationController(rootViewController: vc)
        nvc.isModalInPresentation = true
        self.present(nvc, animated: true, completion: nil)
    }
    
    func editReccurenceProgram(program: TasksViewModel) {
        let vc = Constants.Home.instantiateViewController(withIdentifier: "NewScheduleTaskVC") as! NewScheduleTaskVC
        vc.taskId = program.taskId
        vc.isFromEditSchedule = true
        let nvc = UINavigationController(rootViewController: vc)
        nvc.isModalInPresentation = true
        self.present(nvc, animated: true, completion: nil)
    }
    
    func duplicateProgram(program: TasksViewModel) {
        let vc = Constants.Home.instantiateViewController(withIdentifier: "AddTaskVC") as! AddTaskVC
        vc.taskId = program.taskId
        vc.isFromDuplicateTask = true
        let nvc = UINavigationController(rootViewController: vc)
        nvc.isModalInPresentation = true
        self.present(nvc, animated: true, completion: nil)
    }
    
    func showMoreOptions(titleMessage: String, programData: TasksViewModel) {
        Global.setVibration()
        DispatchQueue.main.async {
            let alert = UIAlertController(title: titleMessage, message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title:  Messages.txtSendTaskNow, style: .default, handler: { _ in
                self.sendTaskNow(program: programData)
            }))
            alert.addAction(UIAlertAction(title:  Messages.txtModify, style: .default, handler: { _ in
                self.editProgram(program: programData)
            }))
            alert.addAction(UIAlertAction(title:  Messages.txtEditRecurrence, style: .default, handler: { _ in
                self.editReccurenceProgram(program: programData)
            }))
            alert.addAction(UIAlertAction(title:  Messages.txtDuplicate, style: .default, handler: { _ in
                self.duplicateProgram(program: programData)
            }))
            alert.addAction(UIAlertAction(title: Messages.txtDelete, style: .destructive, handler: { _ in
                self.deleteSelectedProgram(programToDelete: programData)
            }))
            alert.addAction(UIAlertAction.init(title: Messages.txtCancel, style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension MyProgramsVC {
    @objc func pullRefresh() {
        getTaskList()
    }
    
    func getTaskList() {
        if refreshControl.isRefreshing == false {
            Global.showLoadingSpinner(sender: self.view)
        }
        TasksViewModel.getScheduledTaskList {[weak self] arrData in
            DispatchQueue.main.async {
                Global.dismissLoadingSpinner(self?.view)
                self?.refreshControl.endRefreshing()
                guard let self = self else { return }
                Global.dismissLoadingSpinner(self.view)
                self.arrData = arrData
                self.vwEmpty.isHidden = arrData.count > 0
                self.vwAddTask.isHidden = arrData.count > 0
                self.tblView.reloadData()
            }
        }
    }
    
    private func deleteSelectedProgram(programToDelete:TasksViewModel?) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: Messages.txtDeletePrograme, message: Messages.txtDeleteConfirmationPrograme, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title:  "Supprimer le programme".localized, style: .destructive, handler: { _ in
                self.deleteProgram(taskData: programToDelete) {[weak self] done in
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        self.pullRefresh()
                    }
                }
            }))
            alert.addAction(UIAlertAction.init(title: Messages.txtCancel, style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func deleteProgram(taskData:TasksViewModel?,completion: @escaping(_ done: Bool)->()) {
        guard let taskData = taskData else { return }
        let params: [String: Any] = [
            "task_id": taskData.taskId,
            "client_secret": Constants.kClientSecret,
        ]
        
        Global.showLoadingSpinner(sender: self.view)
        let hdpiApiname = HpAPI.taskArchiveDelete
        hdpiApiname.DataAPI(params: params, shouldShowError: true, shouldShowSuccess: false, key: nil) { (response: Result<GeneralModel, Error>) in
            DispatchQueue.main.async {
                Global.dismissLoadingSpinner(self.view)
                switch response {
                case .success(_):
                    completion(true)
                    break
                case .failure(_):
                    completion(false)
                    break
                }
            }
        }
    }
    
    private func scheduleTaskNow(taskData:TasksViewModel?,completion: @escaping(_ done: Bool)->()) {
        guard let taskData = taskData else { return }
        let params: [String: Any] = [
            "task_id": taskData.taskId,
            "workspcae_id": taskData.workSpaceId,
            "client_secret": Constants.kClientSecret,
        ]
        
        Global.showLoadingSpinner(sender: self.view)
        let hdpiApiname = HpAPI.taskPrioritySchedule
        hdpiApiname.DataAPI(params: params, shouldShowError: true, shouldShowSuccess: true, key: nil) { (response: Result<GeneralModel, Error>) in
            DispatchQueue.main.async {
                Global.dismissLoadingSpinner(self.view)
                switch response {
                case .success(_):
                    completion(true)
                    break
                case .failure(_):
                    completion(false)
                    break
                }
            }
        }
    }
    
    private func getWorkSpaces(shouldShowLoader: Bool) {
        WorkSpaceViewModel.GetWorkSpaceList( page: 1, limit: 1000, sender: self, shouldShowLoader: shouldShowLoader) { arrWorkspaces, totalTask  in
            DispatchQueue.main.async {
                let allNonAdmins = arrWorkspaces.allSatisfy { !$0.isAdmin }
                if !allNonAdmins {
                    self.setRightButton(isImage: true, image: UIImage(named: "plus") ?? UIImage(), inset: UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2))
                }
            }
        }
    }
}

// MARK: - Table View Cell Class
class MyProgramsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var vwBottomLine: UIView!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblDay: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var stkView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var statusIndicator: UIImageView!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var icFlag: UIImageView!
    @IBOutlet weak var flagConstraint: NSLayoutConstraint! //5
    @IBOutlet weak var clockConstraint: NSLayoutConstraint! //4
    @IBOutlet weak var btnMore: UIButton!
    
    // MARK: - Variable
    var onMoreTapped: (() -> Void)?
    
    override func awakeFromNib() {
        self.btnMore.addTarget(self, action: #selector(moreTapped), for: .touchUpInside)
    }
    
    @objc private func moreTapped() {
        onMoreTapped?()
    }
}
