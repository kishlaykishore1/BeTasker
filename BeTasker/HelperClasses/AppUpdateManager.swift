//
//  AppUpdateManager.swift
//  BeTasker
//
//  Created by kishlay kishore on 12/06/25.
//

import Foundation
import UIKit

struct AppUpdateConfig {
    let forceUpdate: Bool
    let latestVersion: String
    let shouldShowPopUp: Bool
    let appStoreURL: String = "itms-apps://itunes.apple.com/app/betasker-trello-made-easy/id6741470217"
}

class AppUpdateManager {

    static func checkForAppUpdate(config: AppUpdateConfig) {
        let currentVersion = currentAppVersion()

        if isNewVersionAvailable(latestVersion: config.latestVersion, currentVersion: currentVersion) {
            if config.forceUpdate {
                showForceUpdateAlert(storeURL: config.appStoreURL)
            } else if config.shouldShowPopUp {
                showOptionalUpdateAlert(storeURL: config.appStoreURL)
            }
        }
    }

    private static func currentAppVersion() -> String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
    }

    private static func isNewVersionAvailable(latestVersion: String, currentVersion: String) -> Bool {
        return latestVersion.compare(currentVersion, options: .numeric) == .orderedDescending
    }

    private static func showForceUpdateAlert(storeURL: String) {
        let alert = UIAlertController(
            title: "Mise à jour requise".localized,
            message: "Veuillez mettre à jour l'application pour continuer.".localized,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Update".localized, style: .default) { _ in
            openAppStore(urlString: storeURL)
        })

        alert.isModalInPresentation = true // Prevent dismiss (iOS 13+)

        topMostController()?.present(alert, animated: true)
    }

    private static func showOptionalUpdateAlert(storeURL: String) {
        let alert = UIAlertController(
            title: "Nouvelle version disponible".localized,
            message: "Une nouvelle version de l'application est disponible. Souhaitez-vous la mettre à jour ?".localized,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Plus tard".localized, style: .cancel))
        alert.addAction(UIAlertAction(title: "Mettre à jour".localized, style: .default) { _ in
            if let url = URL(string: storeURL) {
                UIApplication.shared.open(url)
            }
        })

        topMostController()?.present(alert, animated: true)
    }

    private static func topMostController() -> UIViewController? {
        var topController = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController
        while let presented = topController?.presentedViewController {
            topController = presented
        }
        return topController
    }
    
    private static func openAppStore(urlString: String) {
            if let url = URL(string: urlString) {
                UIApplication.shared.open(url)
            }
        }
}
