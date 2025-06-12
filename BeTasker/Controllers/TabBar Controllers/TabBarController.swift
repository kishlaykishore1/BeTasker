//
//  TabBarController.swift
//  EasyAC
//
//  Created by MAC3 on 01/05/23.
//

import UIKit

protocol PrClose: AnyObject {
    func closedDelegateAction()
}

class TabBarController: UITabBarController {

    @IBOutlet weak var lblTermine: UILabel!
    @IBOutlet weak var lblTask: UILabel!
    @IBOutlet var vwBar: UIView!
    @IBOutlet weak var tabIconView2: UIImageView!
    @IBOutlet weak var redViewTab2: UIView!
    @IBOutlet weak var lblTab2Count: UILabel!
    @IBOutlet weak var tabIconView1: UIImageView!
    @IBOutlet weak var redViewTab1: UIView!
    @IBOutlet weak var lblTab1Count: UILabel!
    @IBOutlet weak var customTabBar: CustomTabBar!
    @IBOutlet weak var viewAdd: UIView!
    
    // MARK: Properties
    fileprivate lazy var defaultTabBarHeight = { customTabBar.frame.size.height } () //{ tabBar.frame.size.height } ()
    var arrMembers = [MembersDataViewModel]()
    weak var delegateTab: PrTabSelected?
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.delegate = self
        self.lblTask.text = "Reçues".localized
        self.lblTermine.text = "Envoyées".localized
        self.redViewTab1.layer.cornerRadius = self.redViewTab1.frame.height / 2
        self.redViewTab2.layer.cornerRadius = self.redViewTab2.frame.height / 2
        self.viewAdd.applyShadow(radius: 3, opacity: 0.1, offset: CGSize(width: 0.0, height: 3.0))
        if let tabBar = self.tabBar as? CustomTabBar {
            tabBar.invalidateIntrinsicContentSize() // Ensure proper layout
        }
        tabIconView1.tintColor = UIColor.color333333
        tabIconView2.tintColor = UIColor.colorACAEBB
        setupCustomTabBar()
        GetMembers(shouldShowLoader: false) {
            
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(setTheTabCountView(_:)), name: .workspaceSelectedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setArrMembers(_:)), name: .groupMembersNotification, object: nil)
    }
    
    private func setupCustomTabBar() {
            // Hide the default tab bar
            //tabBar.isHidden = true

            // Add the custom tab bar
        vwBar.backgroundColor = .clear //.colorFFFFFF000000
            vwBar.layer.shadowColor = UIColor.black.cgColor
            vwBar.layer.shadowOpacity = 0.1
            vwBar.layer.shadowOffset = CGSize(width: 0, height: -1)
            vwBar.layer.shadowRadius = 0

            view.addSubview(vwBar)

            // Layout the custom tab bar
            vwBar.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                vwBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                vwBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                vwBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                vwBar.heightAnchor.constraint(equalToConstant: defaultTabBarHeight) // Set your desired height
            ])

            // Add tab bar buttons
            //setupTabBarButtons()
        }

    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
//        let newTabBarHeight: CGFloat = 100
//        var newFrame = tabBar.frame
//        newFrame.size.height = newTabBarHeight
//        newFrame.origin.y = view.frame.size.height - newTabBarHeight
//        tabBar.frame = newFrame
        
//        let newTabBarHeight: CGFloat = defaultTabBarHeight
//        var newFrame = customTabBar.frame
//        newFrame.size.height = newTabBarHeight
//        newFrame.origin.y = view.frame.size.height - newTabBarHeight
//        customTabBar.frame = newFrame
    }
    
    @objc func setTheTabCountView(_ notification: Notification) {
        if let obj = notification.object as? WorkSpaceDataViewModel {
            if obj.receivedTaskCount > 0 {
                self.redViewTab1.isHidden = false
                self.lblTab1Count.text = "\(obj.receivedTaskCount)"
            } else {
                self.redViewTab1.isHidden = true
                self.lblTab1Count.text = "\(obj.receivedTaskCount)"
            }
            
            if obj.sentTaskCount > 0 {
                self.redViewTab2.isHidden = false
                self.lblTab2Count.text = "\(obj.sentTaskCount)"
            } else {
                self.redViewTab2.isHidden = true
                self.lblTab2Count.text = "\(obj.sentTaskCount)"
            }
        }
    }
    
    func showAddTaskButton(_ show: Bool) {
        viewAdd.isHidden = !show
    }
    
    @IBAction func btnAddtask_Action(_ sender: UIButton) {
        Global.setVibration()
        delegateTab?.selectedTab?(idx: 3)
       
    }
    
    @IBAction func btnAddByCamera(_ sender: UIButton) {
        Global.setVibration()
        delegateTab?.selectedTab?(idx: 4)
    }
    
    @IBAction func btnAction(_ sender: UIButton) {
        Global.setVibration()
        switch sender.tag {
        case 0:
            delegateTab?.selectedTab?(idx: sender.tag)
            selectedIndex = sender.tag
            lblTask.textColor = UIColor.color333333       //colorFFD200
            lblTermine.textColor = UIColor.colorACAEBB
            tabIconView1.tintColor = UIColor.color333333 //colorFFD200
            tabIconView2.tintColor = UIColor.colorACAEBB
            
        case 2:
            if delegateTab?.shouldAllowTabSwitch?() ?? false {
                delegateTab?.selectedTab?(idx: sender.tag)
                selectedIndex = sender.tag
                lblTask.textColor = UIColor.colorACAEBB
                lblTermine.textColor = UIColor.color333333
                tabIconView1.tintColor = UIColor.colorACAEBB
                tabIconView2.tintColor = UIColor.color333333
            } else {
                return
            }
        default:
            
            if self.arrMembers.count > 0 {
                let vc = Constants.Home.instantiateViewController(withIdentifier: "AddTaskVC") as! AddTaskVC
                vc.arrUsers = self.arrMembers
                vc.tabBarVC = self
                let nvc = UINavigationController(rootViewController: vc)
                nvc.isModalInPresentation = true
                self.present(nvc, animated: true, completion: nil)
            } else {
                let vc = Constants.Profile.instantiateViewController(withIdentifier: "AddGroupMemberVC") as! AddGroupMemberVC
                vc.delegate = self
                self.present(vc, animated: true, completion: nil)
            }
            break
        }
        
    }
    
    func GetMembers(shouldShowLoader: Bool, done: @escaping()->()) {
        MembersViewModel.GetMembersList(groupId: 0, page: 1, limit: 10000, sender: self, shouldShowLoader: shouldShowLoader) { arrMembers in
            DispatchQueue.main.async {
                self.arrMembers = arrMembers
                done()
            }
        }
    }
    
    @objc func setArrMembers(_ notification: Notification) {
        if let obj = notification.object as? [MembersDataViewModel] {
            self.arrMembers = obj
        }
    }

}

extension TabBarController: PrClose {
    func closedDelegateAction() {
        GetMembers(shouldShowLoader: false) {
            DispatchQueue.main.async {
                let vc = Constants.Home.instantiateViewController(withIdentifier: "AddTaskVC") as! AddTaskVC
                vc.arrUsers = self.arrMembers
                vc.tabBarVC = self
                let nvc = UINavigationController(rootViewController: vc)
                nvc.isModalInPresentation = true
                //nvc.modalPresentationStyle = .automatic
                self.present(nvc, animated: true, completion: nil)
            }
        }
    }
}

// MARK: TabBarController
extension TabBarController: UITabBarControllerDelegate {
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        Global.setVibration()
    }
}
