//
//  NewFilterVC.swift
//  BeTasker
//
//  Created by kishlay kishore on 03/03/25.
//

import UIKit
import BottomPopup
import SDWebImage
import IQKeyboardManagerSwift

class NewFilterVC: BottomPopupViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var backViewContainer: UIView!
    @IBOutlet weak var txtStartDate: UITextField!
    @IBOutlet weak var txtEndDate: UITextField!
    @IBOutlet weak var statusCollectionView: UICollectionView!
    @IBOutlet weak var lblChooseSender: UILabel!
    @IBOutlet weak var collectionUsers: UICollectionView!
    @IBOutlet weak var btnFilterTask: UIButton!
    @IBOutlet weak var lblSearchBy: UILabel!
    
    // MARK: - Variables
    private var containerHeight: CGFloat = Constants.kScreenHeight
    override var popupHeight: CGFloat {
        return containerHeight // Use the updated container height
    }
    override var popupTopCornerRadius: CGFloat {
        return 38
    }
    var arrUsers = [MembersDataViewModel]()
    var listFor: EnumTaskListType = .assignedToMe
    weak var delegate: PrRefreshData?
    var filterData: FilterDataModel?
    var arrStatus = [TaskStatusViewModel]()
    var selectedStatusIndex: Int? = 0
    var workspaceId: Int?
    var formattedStartDate = ""
    var formattedEndDate = ""
    
    lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.sizeToFit()
        if #available(iOS 13.4, *) {
            picker.preferredDatePickerStyle = .wheels
        }
        //        let date = Calendar.current.date(byAdding: .year, value: -17, to: Date())
        //        picker.maximumDate = date
        return picker
    }()
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        btnFilterTask.layer.cornerRadius = btnFilterTask.frame.height / 2
        filterData = FilterDataCache.get().data
        lblSearchBy.text = listFor == .assignedToMe ? "PAR EXPÉDITEUR".localized : "PAR DESTINATAIRE".localized
        backViewContainer.layer.cornerRadius = 24
        backViewContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        getWorkspaceMembers(shouldShowLoader: true)
        getStatusList()
        self.statusCollectionView.register(UINib(nibName: "StatusCollectionCell", bundle: nil), forCellWithReuseIdentifier: "StatusCollectionCell")
        self.collectionUsers.isHidden = true
        self.lblChooseSender.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enableAutoToolbar = true
    }
    
    // MARK: - Helper Methods
    
    func setupFilterData() {
        let filterData = FilterDataCache.get()
        let startDateToShow = Global.GetFormattedDate(dateString: filterData.startDate, currentFormate: "yyyy-MM-dd", outputFormate: "d MMM yyyy", isInputUTC: false, isOutputUTC: false).dateString ?? ""
        txtStartDate.text = startDateToShow
        formattedStartDate = filterData.startDate
        
        let endDateToShow = Global.GetFormattedDate(dateString: filterData.endDate, currentFormate: "yyyy-MM-dd", outputFormate: "d MMM yyyy", isInputUTC: false, isOutputUTC: false).dateString ?? ""
        txtEndDate.text = endDateToShow
        formattedEndDate = filterData.endDate
        
        if !arrUsers.filter ({ $0.isSelected }).isEmpty {
            self.collectionUsers.isHidden = false
            self.lblChooseSender.isHidden = true
            self.collectionUsers.reloadData()
        }
    }
    
    func getStatusList() {
        let filterData = FilterDataCache.get()
        TaskStatusViewModel.taskStatusList { [weak self] list in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.arrStatus = list
                for i in 0..<filterData.statusIds.count {
                    if let idx = self.arrStatus.firstIndex(where: {$0.id == filterData.statusIds[i]}) {
                        self.arrStatus[idx].isSelected = true
                    }
                }
                self.setupFilterData()
                self.statusCollectionView.reloadData()
            }
        }
    }
    
    // MARK: - Button Action Methods
    
    @IBAction func applyFilter(_ sender: Any) {
        Global.setVibration()
        filterData?.isFilterApplied = true
        let selectedUsers = arrUsers.filter({ $0.isSelected }).map({$0.id})
        filterData?.userIds = selectedUsers
        if !self.arrStatus.isEmpty {
            let selectedStatusId = self.arrStatus.filter({ $0.isSelected }).map({$0.id})
            filterData?.statusIds = selectedStatusId
        }
        filterData?.startDate = formattedStartDate
        filterData?.endDate = formattedEndDate
        if filterData?.statusIds?.count == 0 && filterData?.userIds?.count == 0 && filterData?.startDate == "" && filterData?.endDate == "" {
            filterData?.isFilterApplied = false
        }
        if let filterData {
            FilterDataCache.save(filterData)
        }
        self.dismiss(animated: true) { [weak self] in
            self?.delegate?.refreshData()
        }
    }
    
    @IBAction func resetFilter(_ sender: Any) {
        Global.setVibration()
        FilterDataCache.remove()
        self.dismiss(animated: true) { [weak self] in
            self?.delegate?.refreshData()
        }
    }
    
    @IBAction func selectMember_action(_ sender: Any) {
        Global.setVibration()
        let vc = Constants.Home.instantiateViewController(withIdentifier: "TeamUsersListVC") as! TeamUsersListVC
        vc.delegate = self
        vc.isFromFilter = true
        vc.workspaceId = self.workspaceId
        let nvc = UINavigationController(rootViewController: vc)
        nvc.isModalInPresentation = true
        self.present(nvc, animated: true, completion: nil)
    }
    
    
}

// MARK: - Collection View Delegate and Datasource Methods
extension NewFilterVC: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == statusCollectionView {
            return arrStatus.count
        } else {
            return arrUsers.filter{ $0.isSelected == true }.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == statusCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StatusCollectionCell", for: indexPath) as! StatusCollectionCell
            let data = arrStatus[indexPath.row]
            cell.configureCell(with: data)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UsersViewCollectionCell", for: indexPath) as! UsersViewCollectionCell
            let data = arrUsers[indexPath.row]
            cell.configureCell(with: data)
            cell.removeActionClosure = {[weak self] in
                self?.arrUsers.remove(at: indexPath.row)
                self?.collectionUsers.reloadData()
                if self?.arrUsers.count == 0 {
                    self?.lblChooseSender.isHidden = false
                    self?.collectionUsers.isHidden = true
                }
            }
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Global.setVibration()
        switch collectionView {
        case statusCollectionView:
            arrStatus[indexPath.item].isSelected.toggle()
            
            if !arrStatus[indexPath.item].isSelected {
                statusCollectionView.deselectItem(at: indexPath, animated: false)
            }
            
            statusCollectionView.reloadItems(at: [indexPath])
        default:
            let vc = Constants.Home.instantiateViewController(withIdentifier: "TeamUsersListVC") as! TeamUsersListVC
            vc.arrMembers = self.arrUsers
            vc.delegate = self
            vc.isFromFilter = true
            vc.workspaceId = self.workspaceId
            let nvc = UINavigationController(rootViewController: vc)
            nvc.isModalInPresentation = true
            self.present(nvc, animated: true, completion: nil)
        }
    }
}

// MARK: - Collection View DelegateFlow Layout Methods
extension NewFilterVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == statusCollectionView {
            let size = (arrStatus[indexPath.row].title).size(withAttributes: [
                NSAttributedString.Key.font: UIFont(name: Constants.KGraphikMedium, size: 13.0) ?? UIFont.systemFont(ofSize: 13, weight: .medium)
            ])
            return CGSize(width: size.width + 32, height: self.statusCollectionView.frame.height)
        } else {
            return UICollectionViewFlowLayout().itemSize
        }
    }
}

// MARK: - TextFiels Delegate Methods
extension NewFilterVC: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        IQKeyboardManager.shared.enableAutoToolbar = true
        return true
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == txtStartDate {
            textField.inputView = datePicker
        } else if textField == txtEndDate {
            textField.inputView = datePicker
        }
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField == txtStartDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "d MMM yyyy"
            dateFormatter.locale = Locale(identifier: "fr")
            textField.text = dateFormatter.string(from: datePicker.date)
            self.formattedStartDate = Global.GetFormattedDate(date: datePicker.date, outputFormate: "yyyy-MM-dd", isInputUTC: true, isOutputUTC: false).dateString ?? ""
            DispatchQueue.main.async {
                self.txtEndDate.becomeFirstResponder()
            }
        } else if textField == txtEndDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "d MMM yyyy"
            dateFormatter.locale = Locale(identifier: "fr")
            textField.text = dateFormatter.string(from: datePicker.date)
            self.formattedEndDate = Global.GetFormattedDate(date: datePicker.date, outputFormate: "yyyy-MM-dd", isInputUTC: true, isOutputUTC: false).dateString ?? ""
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - Add Users Collection View Delegate
extension NewFilterVC: PrTeamMember {
    func setSelectedMembers(arrMembers: [MembersDataViewModel]) {
        self.arrUsers = arrMembers
        self.collectionUsers.isHidden = false
        self.lblChooseSender.isHidden = true
        self.collectionUsers.reloadData()
    }
}

// MARK: - Api Methods
extension NewFilterVC {
    func getWorkspaceMembers(shouldShowLoader: Bool) {
        let filterData = FilterDataCache.get()
        MembersViewModel.GetWorkSpaceMembersList(workSpaceId: workspaceId ?? 0, page: 1, limit: 1000, sender: self, shouldShowLoader: shouldShowLoader) { arrMembers in
            DispatchQueue.main.async {
                var arr = arrMembers
                for i in 0..<filterData.userIds.count {
                    if let idx = arr.firstIndex(where: {$0.id == filterData.userIds[i]}) {
                        arr[idx].isSelected = true
                    }
                }
                self.arrUsers = arr
                self.setupFilterData()
            }
        }
    }
}
