//
//  NotificationManager.swift
//  BeTasker
//
//  Created by kishlay kishore on 15/04/25.
//

import Foundation

extension UIViewController {
    
    //⭐
    @objc func receiveDetailsNotification(_ notification: NSNotification) {
        if notification.name == .appNotification {
            if let aps = notification.object as? PushNotifyModel {
                self.navigate(data: PushNotifyViewModel(model: aps))
            }
        }
    }
    
    func navigate(data: PushNotifyViewModel) {
        switch data.redirectType {
        case .NewTask:
//            let vc = Constants.Home.instantiateViewController(withIdentifier: "TaskDetailsVC") as! TaskDetailsVC
//            vc.isRecalled = false
//            vc.taskId = data.relatedId
//            if let topVC = self as? TasksVC {
//                vc.delegate = topVC
//            }
//            guard let getNav = UIApplication.topViewController()?.navigationController else {
//                self.present(vc, animated: true, completion: nil)
//                return
//            }
//            getNav.present(vc, animated: true, completion: nil)
            break
        case .Chat:
            let vc = Constants.Chat.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
            vc.isFromNotification = true
            vc.taskId = Int(data.taskId) ?? 0
            if let topVC = self as? TasksVC {
                vc.delegate = topVC
            }
            if let topVC = UIApplication.topViewController() {
                let navVC = UINavigationController(rootViewController: vc)
                topVC.present(navVC, animated: true)
            }
            //Constants.kAppDelegate.removeNotificationsWithTaskId(data.taskId)
        case .UrgentTask:
            let vc = Constants.Chat.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
            vc.isFromNotification = true
            vc.taskId = Int(data.taskId) ?? 0
            if let topVC = self as? TasksVC {
                vc.delegate = topVC
            }
            if let topVC = UIApplication.topViewController() {
                let navVC = UINavigationController(rootViewController: vc)
                topVC.present(navVC, animated: true)
            }
        case .WorkspaceList:
            let vc = Constants.WorkSpace.instantiateViewController(withIdentifier: "MyWorkSpaceListVC") as! MyWorkSpaceListVC
            vc.isFromNotify = true
            if let topVC = UIApplication.topViewController() {
                if let navController = topVC.navigationController {
                    navController.pushViewController(vc, animated: true)
                } else {
                    let navVC = UINavigationController(rootViewController: vc)
                    topVC.present(navVC, animated: true)
                }
            }
        case .Archive:
            break
        default:
            //HpGlobal.shared.notificationData = nil
            self.tabBarController?.selectedIndex = 0
            self.dismissPresentedViewControllerIfAny(animated: true)
            NotificationCenter.default.post(name: .updateNotificationList, object: nil, userInfo: nil)
            break
        }
    }
}
