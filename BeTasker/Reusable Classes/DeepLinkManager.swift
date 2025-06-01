//
//  DeepLinkManager.swift
//  BeTasker
//
//  Created by kishlay kishore on 10/04/25.
//

import Foundation

class DeepLinkManager {
    static let shared = DeepLinkManager()
    
    func handleUserSearch(randomID: String) {
        // Access the root view controller
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let navController = window.rootViewController as? UINavigationController {
            
            let vc = Constants.Profile.instantiateViewController(withIdentifier: "AddGroupMemberVC") as! AddGroupMemberVC
            vc.randomId = randomID
            navController.present(vc, animated: true, completion: nil)
        }
    }
}
