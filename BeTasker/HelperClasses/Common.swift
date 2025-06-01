 
 import UIKit
 import Foundation
 import SwiftMessages
 
 enum MessageType {
    case warning
    case error
    case success
    case info
 }
 
 class Common: NSObject {
     
    class func showAlertMessage(message: String, alertType: MessageType = .error, isPreferLightStyle: Bool = true)
    {
        DispatchQueue.main.async {
            var config = SwiftMessages.Config()
            config.presentationContext = .window(windowLevel: UIWindow.Level(rawValue: UIWindow.Level(rawValue: UIWindow.Level.statusBar.rawValue).rawValue))
            config.interactiveHide = true
            config.preferredStatusBarStyle = isPreferLightStyle ? .lightContent : .default
            let messageView = MessageView.viewFromNib(layout: .messageView)
            
            switch alertType {
            case .error:
                messageView.configureTheme(.error)
                messageView.configureContent(title: Messages.txtError, body: message)
                messageView.button?.isHidden = true
                SwiftMessages.show(config: config, view: messageView)
            case .warning:
                messageView.configureTheme(.warning)
                messageView.configureContent(title: Messages.txtAlertMes, body: message)
                messageView.button?.isHidden = true
                SwiftMessages.show(config: config, view: messageView)
            case .success:
                messageView.configureTheme(.success)
                messageView.configureContent(title: Messages.txtSuccess, body: message)
                messageView.button?.isHidden = true
                SwiftMessages.show(config: config, view: messageView)
            case .info:
                messageView.configureTheme(.info)
                messageView.configureContent(title: "", body: message)
                messageView.button?.isHidden = true
                SwiftMessages.show(config: config, view: messageView)
            }
        }
    }
     
 }
