//
//  FaqVC.swift
//  EasyAC
//
//  Created by MAC3 on 04/05/23.
//

import UIKit

class FaqVC: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var tblView: UITableView!
    
    // MARK: Properties
    var arrFaq = [FAQViewModel]()
    var refreshControl = UIRefreshControl()
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        
        setBackButton(isImage: true)
        
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tblView.addSubview(refreshControl)
        
    }
        
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarImage(color: UIColor.colorFFFFFF000000, txtcolor: UIColor.color262626, requireShadowLine: true)
        self.navigationItem.title = "Foire aux questions".localized
        FAQViewModel.FaqList { (data) in
            DispatchQueue.main.async {
                self.arrFaq = data
                self.tblView.reloadData()
            }
        }
    }
    
    override func backBtnTapAction() {
        Global.setVibration()
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func refresh(_ sender: AnyObject) {
      FAQViewModel.FaqList { (data) in
          DispatchQueue.main.async {
              self.arrFaq = data
              self.tblView.reloadData()
              self.refreshControl.endRefreshing()
              self.tblView.tableFooterView = UIView()
          }
      }
    }
    
}
// MARK: Table View DataSource Methods
extension FaqVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrFaq.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrFaq[section].list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"FaqDataCell") as! FaqDataCell
        cell.layer.borderWidth = 0.4
        cell.layer.borderColor = UIColor.colorE8E8E8.cgColor
        
        cell.imgDropDownArrow.image = (arrFaq[indexPath.section].listViewModel[indexPath.row].isExpendable) ? #imageLiteral(resourceName: "ic_UpGrey") : #imageLiteral(resourceName: "ic_DownGrey")
        cell.lblQuestion.text = arrFaq[indexPath.section].listViewModel[indexPath.row].question
        cell.lblAnswers.text = arrFaq[indexPath.section].listViewModel[indexPath.row].answer
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 44))
        
        let label = UILabel()
        label.frame = CGRect.init(x: 0, y: 0, width: headerView.frame.width, height: headerView.frame.height)
        
        if !arrFaq.isEmpty {
            label.text = arrFaq[section].title
        }
        label.font = UIFont(name: Constants.KGraphikMedium, size: 12) ?? UIFont()
        label.textColor = UIColor.color363636
        headerView.addSubview(label)
        return headerView
    }
}

// MARK: - Table View Delegates Methods
extension FaqVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.performBatchUpdates {
            arrFaq[indexPath.section].list[indexPath.row].isExpendable = !(arrFaq[indexPath.section].list[indexPath.row].isExpendable ?? false)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        } completion: { _ in
          tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (arrFaq[indexPath.section].listViewModel[indexPath.row].isExpendable) ? UITableView.automaticDimension : 64
    }
    
}

// MARK: Table View First Cell Class
class FaqDataCell: UITableViewCell {
    
    @IBOutlet weak var imgDropDownArrow: UIImageView!
    @IBOutlet weak var lblQuestion: UILabel!
    @IBOutlet weak var lblAnswers: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
}

// MARK: Struct For Expandable Cells
struct DataIsExpendable {
    var headerTitle: String
    var isExpendable = [Bool]()
    
    init(headerTitle: String, isExpendable: [Bool]) {
        self.headerTitle = headerTitle
        self.isExpendable = isExpendable
    }
}

