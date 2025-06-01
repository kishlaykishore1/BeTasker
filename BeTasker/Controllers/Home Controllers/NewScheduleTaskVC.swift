//
//  NewScheduleTaskVC.swift
//  BeTasker
//
//  Created by kishlay kishore on 31/03/25.
//

import UIKit

class NewScheduleTaskVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var mainCollectionView: UICollectionView!
    @IBOutlet weak var btnNext: UIView!
    @IBOutlet weak var switchIsActive: UISwitch!
    @IBOutlet weak var segmentControll: UISegmentedControl!
    @IBOutlet weak var viewWithSwitch: UIView!
    @IBOutlet weak var switchBottomConstraint: NSLayoutConstraint! //24
    @IBOutlet weak var switchTopConstraint: NSLayoutConstraint! //12
    
    // MARK: - Variables
    var arrDayName = [WeekDaysViewModel]()
    var time: [String] = []
    var navTitle = ""
    var selectedUserIds: String = ""
    var deletedImageIds: String?
    var selectedImageNames: String?
    var taskTitle: String?
    var taskDescription: String?
    var taskId: Int?
    var dispalyLink: String?
    var taskData: TasksViewModel?
    var tabBarVC: UITabBarController?
    var isRecurring: Bool?
    var isMessageRequired: Bool?
    var isPhotoRequired: Bool?
    var isCriticalNotification: Bool?
    var currentWorkSpace: WorkSpaceDataViewModel?
    var scheduleType: String?
    var durationDays: String?
    var startDate: String?
    var isFromChat = false
    var isFromDuplicateTask = false
    var isFromEditSchedule = false
    
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTheWeekDaysData()
        if taskData == nil {
            self.isRecurring = true
            setupActiveSwitch()
        }
        setupCollectionView()
        DispatchQueue.main.async { [self] in
            btnNext.layer.cornerRadius = btnNext.frame.height / 2
            btnNext.applyShadow(radius: 3, opacity: 0.1, offset: CGSize(width: 0.0, height: 3.0))
        }
        fixBackgroundSegmentControl(self.segmentControll)
        self.segmentControll.defaultConfiguration()
        self.segmentControll.selectedConfiguration()
        if isFromEditSchedule {
            self.allAPIs()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        //IQKeyboardManager.shared.enableAutoToolbar = true
        setBackButton(isImage: true)
        self.setNavigationBarImage()
        self.navigationItem.title = navTitle
    }
    
    override func backBtnTapAction() {
        Global.setVibration()
        if isFromEditSchedule {
            self.dismiss(animated: true)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: - Helper Methods
    
    func setupCollectionView() {
        mainCollectionView.delegate = self
        mainCollectionView.dataSource = self
        
        let bubbleLayout = MICollectionViewBubbleLayout()
        bubbleLayout.delegate = self
        bubbleLayout.minimumLineSpacing = 10.0
        bubbleLayout.minimumInteritemSpacing = 10.0
        bubbleLayout.horizontalAlignment = .leading
        mainCollectionView.setCollectionViewLayout(bubbleLayout, animated: false)
        bubbleLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
        mainCollectionView.register(UINib(nibName: "ReccuringDaysCollCell", bundle: nil), forCellWithReuseIdentifier: "ReccuringDaysCollCell")
        mainCollectionView.register(UINib(nibName: "ReccurringHoursCollCell", bundle: nil), forCellWithReuseIdentifier: "ReccurringHoursCollCell")
        mainCollectionView.register(UINib(nibName: "ReoccurTimeCollCell", bundle: nil), forCellWithReuseIdentifier: "ReoccurTimeCollCell")
        mainCollectionView.register(UINib(nibName: "InitialOccurCollCell", bundle: nil), forCellWithReuseIdentifier: "InitialOccurCollCell")
        mainCollectionView.register(UINib(nibName: "CustomFooterCollCell", bundle: nil),
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                withReuseIdentifier: CustomFooterCollCell.reuseIdentifier)
    }
    
    func setupTheWeekDaysData() {
        arrDayName = WeekDaysViewModel.GetWeekDays()
        if let taskData {
            for i in 0..<taskData.arrRecurrenceDaysInteger.count {
                if let idx = arrDayName.firstIndex(where: {$0.weekDayPosition == taskData.arrRecurrenceDaysInteger[i]}) {
                    arrDayName[idx].isSelected = true
                }
            }
            time = taskData.hourHHmm
            startDate = taskData.formattedStartDate
            durationDays = taskData.durationDays
            scheduleType = taskData.scheduleType
            if scheduleType != "" && scheduleType != nil {
                self.segmentControll.selectedSegmentIndex = Int(scheduleType!)! - 1
                handelViewSwitch(sender: scheduleType ?? "1")
            } else {
                self.segmentControll.selectedSegmentIndex = 0
                handelViewSwitch(sender: scheduleType ?? "1")
            }
            isRecurring = taskData.isRecurring
            setupActiveSwitch()
            //HpGlobal.shared.programTemplateCreationData.alarmHour = taskData.hourHHmm
        }
    }
    
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
    
    func calculateNoOfSections() -> Int {
        switch segmentControll.selectedSegmentIndex {
        case 0:
            return 1
        case 1:
            return 5
        case 2:
            return 2
        default:
            return 0
        }
    }
    
    func setHeaderTitleForCells(indexPath: IndexPath) -> String {
        switch segmentControll.selectedSegmentIndex {
        case 0:
            return "Heure".localized
        case 1:
            return indexPath.section == 0 ? "Jours de récurence".localized : (indexPath.section == 4 ? "Heure".localized : "")
        case 2:
            return indexPath.section == 0 ? "Occurrence initiale".localized : "Récurence".localized
        default:
            return ""
        }
    }
    
    func checkForDataChange(param: [String:Any]) -> Bool {
        if let data = self.taskData {
            if data.description != param["description"] as? String || data.title != param["title"] as? String || data.displayLink != param["display_link"] as? String {
                return true
            } else {
                return false
            }
        }
        return false
    }
    
    func handelViewSwitch(sender: String) {
        if sender == "2" {
            self.viewWithSwitch.isHidden = true
            self.switchBottomConstraint.constant = 0
            self.switchTopConstraint.constant = 0
        } else {
            self.viewWithSwitch.isHidden = false
            self.switchBottomConstraint.constant = 24
            self.switchTopConstraint.constant = 12
        }
    }
    
    func setupActiveSwitch() {
        if isRecurring ?? false {
           switchIsActive.isOn = true
       } else {
           switchIsActive.isOn = false
       }
    }
    
    // MARK: - Button Action Methods
    @IBAction func segmentControll_Action(_ sender: UISegmentedControl) {
        Global.setVibration()
        self.scheduleType = "\(sender.selectedSegmentIndex + 1)"
        handelViewSwitch(sender: "\(sender.selectedSegmentIndex + 1)")
        mainCollectionView.reloadData()
    }
    
    @IBAction func btnNextTapAction(_ sender: UIButton) {
        Global.setVibration()
        if PremiumManager.shared.canCreateScheduleTask() {
            self.configureDataToScheduleTask()
        } else {
            PremiumManager.shared.openPremiumScreen()
        }
    }
    
    @IBAction func switchActive_Action(_ sender: UISwitch) {
        Global.setVibration()
        isRecurring = sender.isOn
    }
    
}

//MARK: Collection View DataSource Methods
extension NewScheduleTaskVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return calculateNoOfSections()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if segmentControll.selectedSegmentIndex == 1 {
            return (section == 0 || section == 1 || section == 2) ? 2 : 1
        } else {
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch segmentControll.selectedSegmentIndex {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReccurringHoursCollCell", for: indexPath) as! ReccurringHoursCollCell
            cell.configure(with: time.isEmpty ? ["09:00"] : time)
            cell.section = indexPath.section
            cell.delegate = self
            return cell
        case 1:
            if indexPath.section == 4 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReccurringHoursCollCell", for: indexPath) as! ReccurringHoursCollCell
                cell.configure(with: time.isEmpty ? ["09:00"] : time)
                cell.section = indexPath.section
                cell.delegate = self
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReccuringDaysCollCell", for: indexPath) as! ReccuringDaysCollCell
                let tag = (2 * indexPath.section) + indexPath.row
                cell.lblTitleName.text = arrDayName[tag].weekDayName
                if arrDayName[tag].isSelected {
                    cell.bkgView.backgroundColor = #colorLiteral(red: 1, green: 0.8235294118, blue: 0, alpha: 1)
                    cell.lblTitleName.textColor = UIColor.colorFFFFFF000000
                } else {
                    cell.bkgView.backgroundColor = UIColor.colorF5F5F5616161
                    cell.lblTitleName.textColor = UIColor.color2D2D2D
                }
                return cell
            }
        case 2:
            if indexPath.section == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InitialOccurCollCell", for: indexPath) as! InitialOccurCollCell
                cell.delegate = self
                cell.configure(with: startDate)
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReoccurTimeCollCell", for: indexPath) as! ReoccurTimeCollCell
                cell.delegate = self
                cell.configure(with: durationDays)
                return cell
            }
        default:
            return UICollectionViewCell()
        }
    }
}


//MARK: MICollectionViewBubbleLayoutDelegate
extension NewScheduleTaskVC: MICollectionViewBubbleLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, layout: MICollectionViewBubbleLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if segmentControll.selectedSegmentIndex == 1 {
            if section == 4 {
                return .zero
            } else {
                return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20) // Special layout
            }
        } else {
            return .zero
        }
    }
    
    func collectionView(_ collectionView:UICollectionView, itemSizeAt indexPath:NSIndexPath) -> CGSize {
        if segmentControll.selectedSegmentIndex == 1 {
            var title = ""
            if indexPath.section < 4 {
                let tag = (2 * indexPath.section) + indexPath.row
                title = arrDayName[tag].weekDayName
            } else {
                title = time.first ?? "9:30"
            }
            
            var size = title.size(withAttributes: [NSAttributedString.Key.font: UIFont(name: "Graphik-Medium", size: 24) ?? .systemFont(ofSize: 24)])
            let spacing = 18.0
            let kItemPadding = 16
            let totalWidth = Float(size.width + spacing + CGFloat(kItemPadding * 2))
            size.width = CGFloat(ceilf(totalWidth))
            size.height = 56
           
            //...Checking if item width is greater than collection view width then set item width == collection view width.
            if size.width > collectionView.frame.size.width {
                size.width = collectionView.frame.size.width
            }
            if indexPath.section < 4 {
                return size
            } else {
                return CGSize(width: collectionView.bounds.width, height: 56)
            }
        } else {
            return CGSize(width: collectionView.bounds.width, height: 56)
        }
    }
    
}

//MARK: Collection View delegate Methods
extension NewScheduleTaskVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if segmentControll.selectedSegmentIndex == 1 && indexPath.section < 4 {
            Global.setVibration()
            let tag = (2 * indexPath.section) + indexPath.row
            arrDayName[tag].isSelected = !arrDayName[tag].isSelected
            mainCollectionView.reloadData()
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "DayHeaderProgramCollCell", for: indexPath) as! DayHeaderProgramCollCell
            headerView.lblName.text = setHeaderTitleForCells(indexPath: indexPath)
            headerView.lblName.sizeToFit()
            return headerView
        case UICollectionView.elementKindSectionFooter:
            if segmentControll.selectedSegmentIndex == 1 {
                if indexPath.section != collectionView.numberOfSections - 1 {
                    let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "DayFooterProgramCollCell", for: indexPath) as! DayFooterProgramCollCell
                    return headerView
                } else {
                    let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CustomFooterCollCell.reuseIdentifier, for: indexPath) as! CustomFooterCollCell
                    headerView.configure(with: isRecurring ?? false)
                    headerView.updateButtonClosure = { [weak self] sender in
                        self?.isRecurring = sender
                        self?.setupActiveSwitch()
                    }
                    return headerView
                }
            } else {
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "DayFooterProgramCollCell", for: indexPath) as! DayFooterProgramCollCell
                return headerView
            }
        default:
            return UICollectionReusableView()
            
        }
    }
}

extension NewScheduleTaskVC: UICollectionViewDelegateFlowLayout {
    
    // MARK: - Collection View Delegate Flow Layout Methods
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 44.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 6.0
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 2.0
//    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if segmentControll.selectedSegmentIndex == 1 {
            return CGSize(width: collectionView.bounds.width, height: ((section == 0 || section == 4) ? 44.0 : 0.0))
        } else {
            return CGSize(width: collectionView.bounds.width, height: 44.0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if segmentControll.selectedSegmentIndex == 1 {
            if section != collectionView.numberOfSections - 1 {
                return CGSize(width: collectionView.bounds.width, height: ((section == 3) ? 24.0 : 10.0))
            } else {
                return CGSize(width: collectionView.bounds.width, height: 50.0)
            }
        } else {
            return CGSize(width: collectionView.bounds.width, height: 10.0)
        }
        
    }
}

// MARK: - Api Methods
extension NewScheduleTaskVC {
    
    func configureDataToScheduleTask() {
        if scheduleType == "2" {
            let weekDays = arrDayName.filter({$0.isSelected == true}).map({"\($0.weekDayPosition)"}).joined(separator: ",")
            guard weekDays != "" else {
                Common.showAlertMessage(message: "Veuillez sélectionner un jour de la semaine.".localized, alertType: .error)
                return
            }
            HpGlobal.shared.programTemplateCreationData.recurrenceDays = weekDays
        }
        
        let arrTime = time.filter{$0 != ""}.compactMap { time in
            return Global.GetFormattedDate(dateString: time, currentFormate: "HH:mm", outputFormate: "HH:mm", isInputUTC: false, isOutputUTC: true).dateString ?? ""
        }
        
        Global.showLoadingSpinner(sender: self.view)
        let timeZone = TimeZone.current
        print("Current time zone: \(timeZone.identifier)")
        var params: [String: Any] = [
            "title": self.taskTitle?.trim() ?? "",
            "description": self.taskDescription?.trim() ?? "",
            "is_photo": isPhotoRequired == true ? 1 : 0,
            "is_message": isMessageRequired == true ? 1 : 0,
            "client_secret": Constants.kClientSecret,
            "is_notification": isCriticalNotification == true ? 1 : 0,
            "recurrence_days": HpGlobal.shared.programTemplateCreationData.recurrenceDays,
            //"hour": arrTime.joined(separator: ","),
            "schedule_type": scheduleType ?? segmentControll.selectedSegmentIndex + 1 ,
            "duration_days": durationDays ?? "",
            "start_date": startDate ?? "",
            "is_schedule": 1, //isScheduled ?? false ? 1 : 0
            "is_recurring": isRecurring ?? false ? 1 : 0,
            "member_ids": selectedUserIds,
            "file_name": selectedImageNames ?? "",
            "delete_image_ids": deletedImageIds ?? "",
            "display_link": dispalyLink ?? "",
            "user_timezone": timeZone.identifier
        ]
        
        if scheduleType == "3" {
            params["hour"] = ""
        } else {
            params["hour"] = arrTime.joined(separator: ",")
        }
        
        if let selectedWS = self.currentWorkSpace {
            params["workspcae_id"] = selectedWS.id
        } else if isFromEditSchedule {
            params["workspcae_id"] = self.taskData?.workSpaceId
        } else {
            let currenWorkSpaceId = UserDefaults.standard.integer(forKey: Constants.kSelectedWorkSpaceId)
            if currenWorkSpaceId > 0 {
                params["workspcae_id"] = currenWorkSpaceId
            }
        }
        if let taskId {
            if !isFromDuplicateTask {
                params["task_id"] = taskId
            }
        }
        
        HpAPI.taskCreateUpdate.DataAPI(params: params, shouldShowError: true, shouldShowSuccess: false, key: nil) { (response: Result<GeneralModel, Error>) in
            DispatchQueue.main.async {
                Global.dismissLoadingSpinner(self.view)
                switch response {
                case .success(_):
                    if self.isFromChat && self.checkForDataChange(param: params) {
                        Global().sendNewMessageToFireBase(taskID: "\(self.taskData?.taskId ?? 0)", data: params, files: self.taskData?.arrFileDict ?? [])
                        NotificationCenter.default.post(name: .updateTaskChat, object: nil)
                    }
                    NotificationCenter.default.post(name: .updateTaksList, object: nil)
                    let vc = Constants.Home.instantiateViewController(withIdentifier: "AddTaskSuccessVC") as! AddTaskSuccessVC
                    vc.tabBarVC = self.tabBarVC
                    self.navigationController?.dismiss(animated: true, completion: {
                        if let nav = UIApplication.topViewController()?.navigationController {
                            vc.modalPresentationStyle = .fullScreen
                            nav.present(vc, animated: true)
                        }
                    })
                    break
                case .failure(_):
                    break
                }
            }
        }
    }
}

// MARK: - Cell Delegate Methods
extension NewScheduleTaskVC: ReccuringHoursDelegate, SelectedDurationDelegate, SelectedDateTimeDelegate {
    func sendSelectedHours(section: Int, arrHours: [String]) {
        self.time = arrHours
        print(self.time)
        self.mainCollectionView.reloadSections(IndexSet(integer: section))
    }
    
    func sendSelectedHours(arrHours: [String]) {
        self.time = arrHours
        print(arrHours)
    }
    
    func sendSelectedDuration(duration: Int) {
        self.durationDays = "\(duration)"
    }
    
    func sendSelectedDate(date: String) {
        // TODO: - Need To Change the format
        self.startDate = date
    }
}

// MARK: - Api Calls For Details Method
extension NewScheduleTaskVC {
    func allAPIs() {
        let gcd = DispatchGroup()
        let queue = DispatchQueue(label: "com.BeTasker.AddTaskAPIs", qos: .background, attributes: .concurrent)
        let semaphore = DispatchSemaphore(value: 1)
        if let taskId {
            queue.async(group: gcd) { // Use group parameter to automatically manage enter and leave
                gcd.enter()
                TasksViewModel.getTaskDetails(id: taskId, type: "task") {[weak self] taskData in
                    if let taskData {
                        self?.taskData = taskData
                    }
                    semaphore.signal()
                    gcd.leave()
                }
            }
            semaphore.wait() // Wait for semaphore
        }
        
        gcd.notify(queue: .main) {
            if let taskData = self.taskData {
                if taskData.arrUsers.count > 0 {
                  self.selectedUserIds = taskData.arrUsers.map({"\($0.id)"}).joined(separator: ",")
                }
                self.taskTitle = taskData.title
                self.taskDescription = taskData.description
                self.dispalyLink = taskData.displayLink
                self.isPhotoRequired = taskData.isPhotoRequired
                self.isMessageRequired = taskData.isMessageRequired
                self.isCriticalNotification = taskData.isUrgent
                
                if taskData.arrImages.count > 0 {
                    self.selectedImageNames = taskData.arrImages.map({ $0.receivedFileName }).joined(separator: ",")
                }
                self.setupTheWeekDaysData()
            }
            self.mainCollectionView.reloadData()
        }
    }
}

class DatePickerButton: UIButton {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        
        if hitView == self {
            return nil
        }
        
        return hitView
    }
}
