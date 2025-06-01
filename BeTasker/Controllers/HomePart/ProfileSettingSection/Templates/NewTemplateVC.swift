//
//  NewTemplateVC.swift
//  teamAlerts
//
//  Created by B2Cvertical A++ on 09/05/24.
//

import UIKit
import IQKeyboardManagerSwift

class NewTemplateVC: UIViewController {
    
    @IBOutlet weak var switchPhotos: UISwitch!
    @IBOutlet weak var switchCritical: UISwitch!
    @IBOutlet weak var switchMessage: UISwitch!
    @IBOutlet weak var txtMessage: IQTextView!
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var stkView: UIStackView!
    @IBOutlet weak var lblGroupTitle: UILabel!
    @IBOutlet weak var lblLine: UILabel!
    
    var templateData = TemplateViewModel()
    var delegate: PrRefreshData?
    var arrGroups = [GroupViewModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.main.async { [self] in
            btnSave.applyShadow(radius: 3, opacity: 0.1, offset: CGSize(width: 0.0, height: 3.0))
        }
        
        GetGroups(showLoader: true)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.setNavigationBarImage(color: .white, requireShadowLine: true)
        setBackButton(isImage: true)
        self.title = templateData.id > 0 ? "Modifier le modèle".localized : "Nouveau modèle".localized
        self.btnDelete.isHidden = templateData.id == 0
        IQKeyboardManager.shared.enableAutoToolbar = true
        if templateData.id > 0 {
            txtTitle.text = templateData.title
            txtMessage.text = templateData.description
            switchPhotos.setOn(templateData.isPhotos, animated: true)
            switchMessage.setOn(templateData.isMessage, animated: true)
            switchCritical.setOn(templateData.isCritical, animated: true)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        IQKeyboardManager.shared.enableAutoToolbar = false
    }
    
    override func backBtnTapAction() {
        Global.setVibration()
        self.navigationController?.dismiss(animated: true)
    }

    @IBAction func saveTemplate(_ sender: Any) {
        Global.setVibration()
        
        guard let templateTitle = txtTitle.text?.trim(), Validation.isBlank(for: templateTitle) == false else {
            Common.showAlertMessage(message: "Le titre est requis.".localized, alertType: .error)
            return
        }
        
        guard let templateDescription = txtMessage.text?.trim(), Validation.isBlank(for: templateDescription) == false else {
            Common.showAlertMessage(message: "Une description est requise.".localized, alertType: .error)
            return
        }
        
        guard switchPhotos.isOn == true || switchMessage.isOn == true || switchCritical.isOn else {
            Common.showAlertMessage(message: "Veuillez sélectionner au moins une autorisation de notification.".localized, alertType: .error)
            return
        }
        
        let selectedGroupIds = arrGroups.filter({ $0.isSelected }).map({"\($0.id)"}).joined(separator: ",")
        guard selectedGroupIds != "" else {
            Common.showAlertMessage(message: "Veuillez sélectionner au moins un groupe.".localized, alertType: .error, isPreferLightStyle: true)
            return
        }
        
        var params: [String: Any] = [
            "lc": Constants.lc,
            "title": templateTitle,
            "description": templateDescription,
            "is_photos": switchPhotos.isOn ? 1 : 0,
            "is_message": switchMessage.isOn ? 1 : 0,
            "is_critical": switchCritical.isOn ? 1 : 0,
            "group_ids": selectedGroupIds,
            "template_type": "Normal" // => Normal/Programme
        ]
        if templateData.id > 0 {
            params["template_id"] = templateData.id
        }
        TemplateViewModel.addEditTemplate(params: params, sender: self, showLoader: true) { done in
            DispatchQueue.main.async {
                if done {
                    self.delegate?.refreshData()
                    let vc = Constants.Profile.instantiateViewController(withIdentifier: "TemplateSuccessVC") as! TemplateSuccessVC
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    fileprivate func deleteTemplate() {
        TemplateViewModel.deleteTemplate(templateId: templateData.id, sender: self, showLoader: true) { done in
            DispatchQueue.main.async {
                if done {
                    self.delegate?.refreshData()
                    self.navigationController?.dismiss(animated: true)
                }
            }
        }
    }
    
    @IBAction func deleteTemplate(_ sender: Any) {
        Global.setVibration()
        guard templateData.id > 0 else { return }
        
        let alertVC = UIAlertController(title: "Supprimer le modèle".localized, message: "Êtes-vous certain de vouloir supprimer ce modèle ? Attention, cette action est irreversible.".localized, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Confirmer la suppression".localized, style: .destructive) { _ in
            self.deleteTemplate()
        }
        let cancelAction = UIAlertAction(title: "Annuler".localized, style: .cancel)
        alertVC.addAction(okAction)
        alertVC.addAction(cancelAction)
        self.present(alertVC, animated: true)
    }
}

extension NewTemplateVC {
    func GetGroups(showLoader: Bool) {
        GroupResponseViewModel.getGroupList(sender: self, showLoader: showLoader, page: 1, limit: 10000, completion: { (arrGroups, total) in
            DispatchQueue.main.async {
                self.arrGroups = arrGroups
                if arrGroups.count > 0 {
                    self.lblGroupTitle.isHidden = false
                    self.lblLine.isHidden = false
                    self.stkView.subviews.forEach { (vw) in
                        self.stkView.removeArrangedSubview(vw)
                        vw.removeFromSuperview()
                    }
                    for i in 0..<self.templateData.arrGropIds.count {
                        if let idx = self.arrGroups.firstIndex(where: {$0.id == self.templateData.arrGropIds[i]}) {
                            self.arrGroups[idx].isSelected = true
                        }
                    }
                    for (idx, item) in arrGroups.enumerated() {
                        if let vw = GroupSelectionView.instanceFromNib() as? GroupSelectionView {
                            vw.setData(item: item)
                            vw.itemSelectedClouser = {
                                vw.imgCheck.isHighlighted = !vw.imgCheck.isHighlighted
                                self.arrGroups[idx].isSelected = !self.arrGroups[idx].isSelected
                                let selectedCount = self.arrGroups.filter({$0.isSelected}).count
                                let groupCountText = selectedCount > 1 ? "équipes".localized : "équipe".localized
                                self.lblGroupTitle.text = "\("Associé dans".localized) \(selectedCount) \(groupCountText)"
                            }
                            self.stkView.addArrangedSubview(vw)
                        }
                    }
                    self.stkView.spacing = 0
                } else {
                    self.lblGroupTitle.isHidden = true
                    self.lblLine.isHidden = true
                }
            }
        })
    }
}
