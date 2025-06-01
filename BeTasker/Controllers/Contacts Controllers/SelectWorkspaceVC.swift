//
//  SelectWorkspaceVC.swift
//  BeTasker
//
//  Created by kishlay kishore on 22/03/25.
//

import UIKit
import SDWebImage
import IQKeyboardManagerSwift

protocol PrSelectedWorkspaces {
    func setSelectedWorkspaces(arrWorkspaces: [WorkSpaceDataViewModel])
}

class SelectWorkspaceVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var viewSearch: UIView!
    @IBOutlet weak var btnDone: UIButton!
    
    // MARK: - Variables
    let refreshControl = UIRefreshControl()
    var arrWorkspaces = [WorkSpaceDataViewModel]()
    var filteredWorkspaces = [WorkSpaceDataViewModel]()
    var requestStatus = false
    var page: Int = 1
    var limit: Int = 10000
    var isPresented = false
    var delegate: PrSelectedWorkspaces?
    var arrExcludedWorkSpaces = [WorkSpaceDataViewModel]()
    
    // MARK: - View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.btnDone.applyShadow(radius: 3, opacity: 0.1, offset: CGSize(width: 0.0, height: 3.0))
        self.btnDone.layer.cornerRadius = self.btnDone.frame.height / 2
        self.viewSearch.applyShadow(radius: 8, opacity: 0.1, offset: CGSize(width: 0.0, height: 4.0))
        txtSearch.delegate  = self
        txtSearch.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        setupTableView()
        getWorkSpaces(shouldShowLoader: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        setBackButton(isImage: true)
        self.setNavigationBarImage(for: nil, color: UIColor.colorFFFFFF000000, txtcolor: UIColor.color191919, requireShadowLine: true, isTans: true)
        self.title = "Sélectionnez vos espaces de travail".localized
    }
    
    override func backBtnTapAction() {
        Global.setVibration()
        self.dismiss(animated: true)
    }
    
    // MARK: - Helper Methods
    
    func setupTableView() {
        tableView.register(UINib(nibName: "SelectWorkspaceTableCell", bundle: nil), forCellReuseIdentifier: "SelectWorkspaceTableCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        refreshControl.addTarget(self, action: #selector(RefreshList), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        self.filterDataBasedOnText(searchText: textField.text ?? "")
    }
    
    func filterDataBasedOnText(searchText:String) {
        self.filteredWorkspaces.removeAll()
        if searchText.count != 0 {
            self.filteredWorkspaces = self.searchWorkspaces(by: searchText.lowercased(), in: arrWorkspaces)
        } else {
            self.filteredWorkspaces = self.arrWorkspaces
        }
        //        self.viewEmpty.isHidden = self.filteredarrMembers.count > 0
        self.tableView.reloadData()
    }
    
    func searchWorkspaces(by searchText: String, in workspaces: [WorkSpaceDataViewModel]) -> [WorkSpaceDataViewModel] {
        let options: NSString.CompareOptions = [.caseInsensitive, .diacriticInsensitive]
        
        return workspaces.filter { member in
            return member.workSpaceName.range(of: searchText, options: options) != nil
        }
    }
    
    // MARK: - Button Action Methods
    
    @IBAction func doneAction(_ sender: Any) {
        Global.setVibration()
        let selectedWorkspaces = filteredWorkspaces.filter({ $0.isSelected })
        guard selectedWorkspaces.count > 0 else {
            Common.showAlertMessage(message: "Veuillez sélectionner au moins un espace de travail.".localized, alertType: .error, isPreferLightStyle: false)
            return
        }
        self.delegate?.setSelectedWorkspaces(arrWorkspaces: selectedWorkspaces)
        self.dismiss(animated: true)
    }
    
}

//MARK: UITableViewDelegate, UITableViewDataSource
extension SelectWorkspaceVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredWorkspaces.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectWorkspaceTableCell", for: indexPath) as! SelectWorkspaceTableCell
        if filteredWorkspaces.count > indexPath.row {
            
            let workSpace = filteredWorkspaces[indexPath.row]
            cell.lblWSName.text = workSpace.workSpaceName
            let member_count = workSpace.numberOfmembers
            cell.lblWSMember.text = "\(member_count) \("membre".localized)"
            
            cell.bottomLine.isHidden = indexPath.row >= 0
            if isLastRow(indexPath: indexPath, tableView: tableView) {
                cell.bottomLine.isHidden = false
            }
            
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
        filteredWorkspaces[indexPath.row].isSelected = !filteredWorkspaces[indexPath.row].isSelected
        for i in 0..<self.filteredWorkspaces.count {
            if let idx = self.arrWorkspaces.firstIndex(where: {$0.id == self.filteredWorkspaces[i].id}) {
                self.arrWorkspaces[idx].isSelected = !self.arrWorkspaces[idx].isSelected
            }
        }
        tableView.reloadData()
    }
}

// MARK: - TextField Delegate Methods
extension SelectWorkspaceVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        IQKeyboardManager.shared.enableAutoToolbar = true
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
}
// MARK: - Close Deleagte
extension SelectWorkspaceVC: PrClose {
    func closedDelegateAction() {
        RefreshList()
    }
}

// MARK: - Api Methods
extension SelectWorkspaceVC {
    
    @objc func RefreshList() {
        getWorkSpaces(shouldShowLoader: false)
    }
    
    func getWorkSpaces(shouldShowLoader: Bool) {
        WorkSpaceViewModel.GetWorkSpaceList( page: page, limit: limit, sender: self, shouldShowLoader: shouldShowLoader) { arrMembers, totalTask  in
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
                var totalPendingTask = totalTask
                var arr = arrMembers
                for i in 0..<self.arrWorkspaces.count {
                    if let idx = arr.firstIndex(where: {$0.id == self.arrWorkspaces[i].id}) {
                        arr[idx].isSelected = true
                    }
                }
                
                if self.arrExcludedWorkSpaces.count > 0 {
                    for i in 0..<self.arrExcludedWorkSpaces.count {
                        if let idx = arr.firstIndex(where: {$0.id == self.arrExcludedWorkSpaces[i].id}) {
                            arr.remove(at: idx)
                        }
                    }
                }
                self.arrWorkspaces = arr
                self.filterDataBasedOnText(searchText: self.txtSearch.text ?? "")
                //self.viewEmpty.isHidden = self.filteredarrMembers.count > 0
                self.tableView.reloadData()
            }
        }
    }
}
