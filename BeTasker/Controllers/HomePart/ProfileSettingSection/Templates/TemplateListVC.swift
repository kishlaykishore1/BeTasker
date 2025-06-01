//
//  TemplateListVC.swift
//  teamAlerts
//
//  Created by B2Cvertical A++ on 09/05/24.
//

import UIKit

class TemplateListVC: UIViewController {
    
    //MARK: IBOutlets
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var viewEmpty: UIView!
    
    //MARK: Properties
    var arrData = [TemplateViewModel]()
    let refreshControl:UIRefreshControl = UIRefreshControl()
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tblView.delegate = self
        tblView.dataSource = self
        tblView.dragDelegate = self
        tblView.dragInteractionEnabled = true
        
        tblView.isHidden = false
        viewEmpty.isHidden = false
        
        setBackButton(isImage: true)
        setRightButton(isImage: true, image: #imageLiteral(resourceName: "plus-green"))
        
        refreshControl.addTarget(self, action: #selector(RefreshRooms), for: .valueChanged)
        if #available(iOS 10.0, *) {
            tblView.refreshControl = refreshControl
        } else {
            tblView.addSubview(refreshControl)
        }
        GetTemplates(showLoader: true)
        NotificationCenter.default.addObserver(self, selector: #selector(RefreshRooms), name: .updateTemplateList, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Graphik-Medium", size: 30)!,NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.1490196078, green: 0.1490196078, blue: 0.1490196078, alpha: 1)]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func backBtnTapAction() {
        Global.setVibration()
        self.navigationController?.backToViewController(vc: ProfileVC.self)
    }
    
    override func rightBtnTapAction(sender: UIButton) {
        Global.setVibration()
        gotoNewTemplateVC(data: nil)
    }

    @IBAction func showTable(_ sender: UIControl) {
        Global.setVibration()
        gotoNewTemplateVC(data: nil)
    }
    
    func gotoNewTemplateVC(data: TemplateViewModel?) {
        let vc = Constants.Profile.instantiateViewController(withIdentifier: "NewTemplateVC") as! NewTemplateVC
        vc.delegate = self
        if let tempData = data {
            vc.templateData = tempData
        }
        let nvc = UINavigationController(rootViewController: vc)
        self.present(nvc, animated: true, completion: nil)
    }
    
}

//MARK: UITableViewDelegate, UITableViewDataSource
extension TemplateListVC: UITableViewDelegate, UITableViewDataSource, UITableViewDragDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PartsTblViewCell", for: indexPath) as! PartsTblViewCell
        cell.selectionStyle = .none
        let data = arrData[indexPath.row]
        cell.lblName.text = data.title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Global.setVibration()
        gotoNewTemplateVC(data: arrData[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Supprimer".localized) { [unowned self] action, view, completionHandler in
            
            let alertVC = UIAlertController(title: "Supprimer le modèle".localized, message: "Êtes-vous certain de vouloir supprimer ce modèle ? Attention, cette action est irreversible.".localized, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Confirmer la suppression".localized, style: .destructive) { _ in
                self.deleteTemplate(templateId: self.arrData[indexPath.row].id, idx: indexPath.row)
            }
            let cancelAction = UIAlertAction(title: "Annuler".localized, style: .cancel)
            alertVC.addAction(okAction)
            alertVC.addAction(cancelAction)
            self.present(alertVC, animated: true)
            
            
            completionHandler(true)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true // Yes, the table view can be reordered
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // Update the model
        let mover = arrData.remove(at: sourceIndexPath.row)
        arrData.insert(mover, at: destinationIndexPath.row)
        let ids = arrData.map({ "\($0.id)" }).joined(separator: ",")
        TemplateViewModel.reorderTemplates(templateIds: ids, sender: self, showLoader: false) { done in
            
        }
    }
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        dragItem.localObject = arrData[indexPath.row]
        return [ dragItem ]
    }
}

extension TemplateListVC {
    @objc func RefreshRooms() {
        GetTemplates(showLoader: false)
    }
    func GetTemplates(showLoader: Bool) {
        TemplateViewModel.getMyTemplates(sender: self, showLoader: showLoader) { arrTemplates in
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
                self.arrData = arrTemplates
                self.viewEmpty.isHidden = self.arrData.count > 0
                self.tblView.reloadData()
            }
        }
    }
    fileprivate func deleteTemplate(templateId: Int, idx: Int) {
        TemplateViewModel.deleteTemplate(templateId: templateId, sender: self, showLoader: true) { done in
            DispatchQueue.main.async {
                if done {
                        DispatchQueue.main.async {
                            if done {
                                self.arrData.remove(at: idx)
                                self.viewEmpty.isHidden = self.arrData.count > 0
                                self.tblView.reloadData()
                            }
                        }
                }
            }
        }
    }
        
}

extension TemplateListVC: PrRefreshData {
    func refreshData() {
        RefreshRooms()
    }
}
