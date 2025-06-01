//
//  NotificationVC.swift
//  EasyAC
//
//  Created by MAC3 on 01/05/23.
//

import UIKit
import SkeletonView

class NotificationVC: UIViewController {
    
    //MARK: IBOutlets
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var viewEmpty: UIView!
    
    var pageNumber = 1
    var isFetchInProgress = false
    var total = 0
    var arrNotifications = [NotificationViewModel]()
    let refreshControl: UIRefreshControl = UIRefreshControl.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tblView.delegate = self
        tblView.dataSource = self
        
        viewEmpty.isHidden = false
        
        if #available(iOS 10.0, *) {
            tblView.refreshControl = refreshControl
        } else {
            tblView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //self.setNavigationBarImage()
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Graphik-Medium", size: 30)!,NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.1490196078, green: 0.1490196078, blue: 0.1490196078, alpha: 1)]
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        pageNumber = 1
        arrNotifications = []
        Notifications(refreshControl: nil)
    }
    
    @IBAction func showTable(_ sender: UIControl) {
//        tblView.isHidden = false
//        viewEmpty.isHidden = true
    }
    
    @objc func refresh(_ sender: UIRefreshControl) {
        _ = arrNotifications.map({$0.status = true}) //Mark all read
        if arrNotifications.count < total {
            self.Notifications(refreshControl: sender)
        } else {
            refreshControl.endRefreshing()
            tblView.reloadData()
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard isFetchInProgress == false else {
            return
        }
        let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if distanceFromBottom < height {
            //print("You reached end of the table")
            if arrNotifications.count < total {
                var spinner = UIActivityIndicatorView()
                if #available(iOS 13.0, *) {
                    spinner = UIActivityIndicatorView(style: .medium)
                }
                spinner.frame = CGRect(x: 0.0, y: 0.0, width: tblView.bounds.width, height: 70)
                spinner.startAnimating()
                tblView.tableFooterView = spinner
                self.Notifications(refreshControl: nil)
            } else {
                tblView.tableFooterView = nil
            }
        }
    }
    func Notifications(refreshControl: UIRefreshControl?) {
        isFetchInProgress = true
        self.tblView.showAnimatedGradientSkeleton()
        NotificationViewModel.GetNotificationsList(refreshControl: refreshControl, pageNumber: pageNumber) { (data, totalRecords) in
            DispatchQueue.main.async {
                self.tblView.stopSkeletonAnimation()
                self.view.hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0.25))
                self.isFetchInProgress = false
                self.total = totalRecords
                if self.pageNumber == 1 {
                    self.arrNotifications = data
                } else {
                    self.arrNotifications.append(contentsOf: data)
                }
                self.pageNumber += 1
                //self.tblView.isHidden = data.count == 0
                self.viewEmpty.isHidden = data.count > 0
                self.tblView.reloadData()
            }
        }
    }
    
}

//MARK: UITableViewDelegate, UITableViewDataSource
extension NotificationVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrNotifications.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationTblViewCell", for: indexPath) as! NotificationTblViewCell
        cell.selectionStyle = .none
        cell.lblTitle.text = arrNotifications[indexPath.row].title
        cell.lblSubTitle.text = arrNotifications[indexPath.row].message
        cell.lblDate.text = arrNotifications[indexPath.row].created
        cell.viewBlue.isHidden = arrNotifications[indexPath.row].status
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Global.setVibration()
    }
    
}

//MARK: UITableViewCell
class NotificationTblViewCell: UITableViewCell {
    @IBOutlet weak var viewBlue: UIView!
    @IBOutlet weak var viewBack: UIView!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.viewBack.applyBorder(width: 1, color: #colorLiteral(red: 0.9098039216, green: 0.9098039216, blue: 0.9098039216, alpha: 1))
    }
}
