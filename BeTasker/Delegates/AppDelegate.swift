//
//  AppDelegate.swift
//  EasyAC
//
//  Created by MAC3 on 26/04/23.
//

import UIKit
import CoreData
import IQKeyboardManagerSwift
import Firebase
import FirebaseMessaging
import GoogleSignIn
import FacebookCore
import SwiftyStoreKit


@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        
        let config = IQBarButtonItemConfiguration(title: "Valider".localized)
        IQKeyboardManager.shared.toolbarConfiguration.doneBarButtonConfiguration = config
        
        FirebaseApp.configure()
        
        UNUserNotificationCenter.current().delegate = self
        setupReplyMessageStart()
        
        Messaging.messaging().delegate = self
        
        application.registerForRemoteNotifications()
        
        callgeneralSettingApi()
        return true
    }
    
    fileprivate func configureFacebook(with application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        Profile.enableUpdatesOnAccessTokenChange(true)  //enableUpdates(onAccessTokenChange: true)
    }
    
    func application( _ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        var handled: Bool
        handled = GIDSignIn.sharedInstance.handle(url)
        if handled {
            return true
        }
        
        return ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
    }
    
    // MARK: - Handel Global Url Redirection
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let incomingURL = userActivity.webpageURL else {
            return false
        }

        // Handle the deep link here
        let urlComponents = URLComponents(url: incomingURL, resolvingAgainstBaseURL: true)
        if let path = urlComponents?.path, path.contains("/user_search") {
            if let queryItems = urlComponents?.queryItems,
               let randomId = queryItems.first(where: { $0.name == "random_id" })?.value {
                // Navigate to the desired screen
                print("Deep link triggered with random_id:", randomId)
                DeepLinkManager.shared.handleUserSearch(randomID: randomId)
            }
        }
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    //MARK: - Device Token
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        //Auth.auth().setAPNSToken(deviceToken, type: AuthAPNSTokenType.prod)
        Auth.auth().setAPNSToken(deviceToken, type: AuthAPNSTokenType.unknown)
        let strToken = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        Messaging.messaging().apnsToken = deviceToken
        debugPrint("DEVICE TOKEN",strToken)
        Constants.kDeviceToken = strToken
        getFCMToken()
    }
    
    func getFCMToken() {
        Messaging.messaging().token { token, error in
            if let error = error {
                debugPrint("Error fetching FCM token: \(error.localizedDescription)")
            } else if let token = token {
                debugPrint("FCM Token: \(token)")
                Constants.kFCMToken = "\(token)"
                // Send token to server if needed
            }
        }
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        debugPrint("FCM Token updated: \(fcmToken ?? "No Token")")
        if let token = fcmToken {
            Constants.kFCMToken = "\(token)"
        }
    }
    
    //MARK: didFailToRegisterForRemoteNotificationsWithError
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        //NotificationCenter.default.post(name: .tokenNotification, object: nil, userInfo: ["deviceToken": "No"])
    }
    
    //MARK: - It will be called when app is in background and user taps the notification(Killed State)
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        if Auth.auth().canHandleNotification(userInfo) {
            completionHandler(.noData)
            return
        }
        
        switch application.applicationState {
        case .active,.background:
            let notificationDic = userInfo as? [String : Any] ?? [:]
            debugPrint(notificationDic)
            debugPrint("Application is open, do not override")
        case .inactive :
            debugPrint("Killed application state")
        default:
            debugPrint("unrecognized application state")
        }
        completionHandler(.newData)
    }
    
    //MARK: - It will be called when app is in background and user taps the notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        print(userInfo as? [String: Any] ?? [:])
        switch response.actionIdentifier {
        case UNNotificationDefaultActionIdentifier:
            // 👇 User tapped on the notification
            if let data = userInfo as? [String: Any] {
                do {
                    let data = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                    var result = try JSONDecoder().decode(PushNotifyModel.self, from: data)
                    result.isFromBackground = true
                    HpGlobal.shared.pushNotificationData = result
                    NotificationCenter.default.post(name: .appNotification, object: result, userInfo: nil)
                }
                catch (let err) {
                    print("❌❌❌❌❌Error", err)
                    completionHandler()
                }
            }
            
        case "REPLY_ACTION": // your custom reply action identifier
            if let textResponse = response as? UNTextInputNotificationResponse {
                let userReply = textResponse.userText
                if let data = userInfo as? [String: Any] {
                    let taskId = data["task_id"] as? String ?? ""
                    guard let userData = HpGlobal.shared.userInfo else {
                        let myUserId = UserDefaults.standard.value(forKey: Constants.KUserIDKey) as? Int ?? 0
                        Global().sendNewMessageToFireBase(taskID: taskId, message: userReply, isfromNotify: true, senderId: myUserId, data: [:])
                        return
                    }
                    Global().sendNewMessageToFireBase(taskID: taskId, message: userReply, isfromNotify: true, senderId: userData.userId, data: [:])
                }
            }
        default:
            break
        }
        completionHandler()
    }
    
    //MARK: - It will be called every time when notification arrives
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert, .badge, .sound])
        
    }
}

extension AppDelegate {
    
    func setTabbarAppearance() {
        let backgroundColor = UIColor.white
        let selectedItemTextColor = UIColor(named: "ColorFFD01E") ?? .black
        let unselectedItemTextColor = UIColor(named: "ColorACAEBB") ?? .black
        let selectedTextFont = UIFont(name: "SFProText-Medium", size: 12) ?? UIFont.systemFont(ofSize: 12, weight: .regular)
        let unselectedTextFont = UIFont(name: "SFProText-Regular", size: 12) ?? UIFont.systemFont(ofSize: 12, weight: .regular)
        
        if #available(iOS 15, *) {
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.backgroundColor = backgroundColor
            tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: selectedItemTextColor, .font: selectedTextFont]
            tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: unselectedItemTextColor, .font: unselectedTextFont]
            tabBarAppearance.stackedLayoutAppearance.selected.iconColor = selectedItemTextColor
            tabBarAppearance.stackedLayoutAppearance.normal.iconColor = unselectedItemTextColor
            tabBarAppearance.shadowImage = nil
            tabBarAppearance.shadowColor = #colorLiteral(red: 0.9098039216, green: 0.9098039216, blue: 0.9098039216, alpha: 1)
            UITabBar.appearance().standardAppearance = tabBarAppearance
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        } else {
            UITabBarItem.appearance().setTitleTextAttributes([.foregroundColor: selectedItemTextColor, .font: selectedTextFont], for: .selected)
            UITabBarItem.appearance().setTitleTextAttributes([.foregroundColor: unselectedItemTextColor, .font: unselectedTextFont], for: .normal)
            UITabBar.appearance().barTintColor = backgroundColor
            UITabBar.appearance().shadowImage = UIImage()
            UITabBar.appearance().backgroundImage = UIImage()
        }
    }
    
    //Check User Login
    func isUserLogin(_ isLogin:Bool) {
        if isLogin {
            let vc = Constants.Home.instantiateViewController(withIdentifier: "TabBarController") as! TabBarController
            window?.rootViewController = vc
            window?.makeKeyAndVisible()
        } else {
            if Constants.kUserDefaults.bool(forKey: "isNotFirstTime") {
                let vc = Constants.Main.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                let nav = UINavigationController(rootViewController: vc)
                window?.rootViewController = nav
                window?.makeKeyAndVisible()
            } else {
                let vc = Constants.Main.instantiateViewController(withIdentifier: "TutorialVC") as! TutorialVC
                let nav = UINavigationController(rootViewController: vc)
                window?.rootViewController = nav
                window?.makeKeyAndVisible()
            }
        }
    }
    
    func callgeneralSettingApi() {
        HpAPI.STATIC.apiGeneralSettingData { completed in
            if completed {
                if let settingsData = HpGlobal.shared.settingsData {
                    let config = AppUpdateConfig(
                        forceUpdate: settingsData.forceStatusIos,
                        latestVersion: settingsData.appVersionIos,
                        shouldShowPopUp: settingsData.shouldShowPopup
                    )
                    AppUpdateManager.checkForAppUpdate(config: config)
                }
            }
        }
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    // Unlock content
                case .failed, .purchasing, .deferred:
                    break // do nothing
                @unknown default:
                    break
                }
            }
        }
    }
    
    func setupReplyMessageStart() {
        let replyAction = UNTextInputNotificationAction(
            identifier: "REPLY_ACTION",
            title: "Reply",
            options: [],
            textInputButtonTitle: "Envoyer".localized,
            textInputPlaceholder: "Tapez votre message...".localized
        )

        let category = UNNotificationCategory(
            identifier: "MESSAGE_CATEGORY",
            actions: [replyAction],
            intentIdentifiers: [],
            options: []
        )
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
    
    func removeNotificationsWithTaskId(_ taskId: String) {
        UNUserNotificationCenter.current().getDeliveredNotifications { notifications in
            let matchingNotifications = notifications.filter {
                guard let payload = $0.request.content.userInfo as? [String: Any],
                      let payloadTaskId = payload["task_id"] as? String else { return false }
                return payloadTaskId == taskId
            }

            let identifiers = matchingNotifications.map { $0.request.identifier }

            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: identifiers)
        }
    }
}
