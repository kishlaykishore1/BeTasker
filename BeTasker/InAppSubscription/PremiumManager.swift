//
//  PremiumManager.swift
//  BeTasker
//
//  Created by kishlay kishore on 03/04/25.
//

import Foundation

class PremiumManager {
    static let shared = PremiumManager()  // Singleton instance
    
    private let premiumKey = Constants.userSubscribed

    private init() {}  // Private initializer to prevent multiple instances

    // ✅ Check if user is premium
    var isPremium: Bool {
        return HpGlobal.shared.userInfo?.isPremium ?? false //true
    }

//    // ✅ Set premium status (use after purchase or verification)
//    func setPremiumStatus(_ status: Bool) {
//        UserDefaults.standard.set(status, forKey: premiumKey)
//    }
//
//    // ✅ Reset premium status (e.g., on logout)
//    func resetPremiumStatus() {
//        UserDefaults.standard.removeObject(forKey: premiumKey)
//    }
    
    // ✅ Add a new workspace (if allowed)
        func canCreateWorkspace(worspaceCount currentWorkspaceCount: Int) -> Bool {
            if isPremium {
                return true  // Unlimited workspaces for premium users
            } else {
                return currentWorkspaceCount < 2  // Limit to 2 for free users
            }
        }
    
    // ✅ Function to check if user can create a new task
        func canCreateTask(workspaceCreatorIsPremium: Bool, currentTaskCount: Int) -> Bool {
            // If the current user is premium or the workspace creator is premium, allow unlimited tasks
            if isPremium || workspaceCreatorIsPremium {
                return true
            } else {
                // Non-premium users can create up to 30 tasks per workspace
                return currentTaskCount < 30
            }
        }
    
    // ✅ Add a new Urgent task (if allowed)
        func canCreateUrgentTask() -> Bool {
            if isPremium {
                return true  // Unlimited Urgent Task for premium users
            } else {
                return false  // No Urgent Task for free users
            }
        }
    
    // ✅ Add a new Schedule task (if allowed)
        func canCreateScheduleTask() -> Bool {
            if isPremium {
                return true  // Unlimited Schedule Task for premium users
            } else {
                return false  // No Schedule Task for free users
            }
        }
    
    // ✅ Add a new Contact (if allowed)
        func canAddNewUsers(memberCount currentMembersCount: Int) -> Bool {
            if isPremium {
                return true  // Unlimited Contact Add for premium users
            } else {
                return currentMembersCount < 10  // Limit to 10 for free users
            }
        }
}

extension PremiumManager: PrClose {
    
    func openPremiumScreen() {
        let vc = Constants.Profile.instantiateViewController(withIdentifier: "SubscriptionVC") as! SubscriptionVC
        vc.delegate = self
        vc.isModalInPresentation = true
        guard let getNav = UIApplication.topViewController()?.navigationController else {
            return
        }
        let rootNavView = UINavigationController(rootViewController: vc)
        getNav.present(rootNavView, animated: true, completion: nil)
    }
    
    func closedDelegateAction() {
        //code
    }
}
