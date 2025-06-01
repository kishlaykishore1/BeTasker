//
//  UIViewController.swift
//

import UIKit

extension UIViewController {
    
    func isLastRow(indexPath: IndexPath, tableView: UITableView) -> Bool {
        let totalRows = tableView.numberOfRows(inSection: indexPath.section)
        return indexPath.row == totalRows - 1
    }
    
  public func setNavigationBarImage(for image: UIImage? = nil, color: UIColor = .clear, txtcolor: UIColor = #colorLiteral(red: 0.1490196078, green: 0.1490196078, blue: 0.1490196078, alpha: 1), requireShadowLine: Bool = false, isTans: Bool? = false) {
      if let image = image {
          self.navigationController?.navigationBar.shadowImage = image
          self.navigationController?.navigationBar.setBackgroundImage(image, for: .default)
      } else{
          self.navigationController?.navigationBar.shadowImage = nil
          self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
      }
      
      if #available(iOS 13, *) {
          let appearance = UINavigationBarAppearance()
          appearance.configureWithOpaqueBackground()
          appearance.shadowImage = image
          appearance.backgroundColor = color
          if !requireShadowLine {
            appearance.shadowColor = .clear
          }
          appearance.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Graphik-Medium", size: 15) ?? UIFont.systemFont(ofSize: 15, weight: .medium), NSAttributedString.Key.foregroundColor: txtcolor]
          self.navigationController?.navigationBar.standardAppearance = appearance
          self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
      } else {
          self.navigationController?.navigationBar.tintColor = color
          self.navigationController?.navigationBar.barTintColor = color
          self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Graphik-Medium", size: 13) ?? UIFont.systemFont(ofSize: 13, weight: .medium), NSAttributedString.Key.foregroundColor: txtcolor]
          self.navigationController?.navigationBar.isTranslucent = isTans ?? false
      }
  
    }
    
    //MARK: BackButton
    public func setBackButton(tintColor: UIColor = .white, isImage: Bool = false, image: UIImage = #imageLiteral(resourceName: "back") ) {
        let btn1 = UIButton(type: .custom)
        if isImage {
            btn1.setImage(image, for: .normal)
            btn1.imageView?.contentMode = .scaleAspectFit
            btn1.frame = CGRect(x: 0, y: 0, width: 25, height: 24)
        } else {
            btn1.setTitle("Retour".localized, for: .normal)
            btn1.frame = CGRect(x: 0, y: 0, width: 60, height: 30)
        }
        btn1.contentHorizontalAlignment = .left
        btn1.setTitleColor(tintColor, for: .normal)
        btn1.addTarget(self, action: #selector(self.backBtnTapAction), for: .touchUpInside)
        let item1 = UIBarButtonItem(customView: btn1)
        let negativeSpacer:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        negativeSpacer.width = -16
        self.navigationItem.leftBarButtonItems = [negativeSpacer, item1]
    }
    
    //MARK: Like Button
    public func setRightButton(tintColor: UIColor = .white, isImage: Bool = false, image: UIImage =  #imageLiteral(resourceName: "setting_white"), inset: UIEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)){
        let btn1 = UIButton(type: .custom)
        if isImage {
            btn1.setImage(image, for: .normal)
            btn1.imageEdgeInsets = inset
            btn1.imageView?.contentMode = .scaleAspectFit
            btn1.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        } else {
            btn1.setTitle("Plus tard".localized, for: .normal)
            btn1.setTitleColor(#colorLiteral(red: 0.2235294118, green: 0.3176470588, blue: 0.3843137255, alpha: 1), for: .normal)
            btn1.titleLabel?.font = UIFont(name: "DMSans-Medium", size: 13)
            btn1.titleLabel?.textColor = #colorLiteral(red: 0.2235294118, green: 0.3176470588, blue: 0.3843137255, alpha: 1)
            btn1.frame = CGRect(x: 0, y: 0, width: 80, height: 30)
        }
        btn1.addTarget(self, action: #selector(self.rightBtnTapAction(sender:)), for: .touchUpInside)
        let item1 = UIBarButtonItem(customView: btn1)
        self.navigationItem.setRightBarButton(item1, animated: true)
    }
    
    @objc func rightBtnTapAction(sender: UIButton){}
    
    @objc func backBtnTapAction(){}
    
    public var topDistance : CGFloat {
        get {
            if self.navigationController != nil && !self.navigationController!.navigationBar.isTranslucent {
                return 0
            } else {
                let barHeight = self.navigationController?.navigationBar.frame.height ?? 0
                var statusBarHeight = CGFloat(0)
                 if #available(iOS 13.0, *) {
                    let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
                    statusBarHeight = (window?.windowScene?.statusBarManager?.isStatusBarHidden ?? true) ? CGFloat(0) : window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
                 } else {
                     statusBarHeight = UIApplication.shared.isStatusBarHidden ? CGFloat(0) : UIApplication.shared.statusBarFrame.height
                }
                return barHeight + statusBarHeight
            }
        }
    }
    
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func dismissAllControllers(){
       view.window!.rootViewController?.dismiss(animated: true, completion: nil)
     }
    func dismissPresentedViewControllerIfAny(animated: Bool, completion: (() -> Void)? = nil) {
        if let presentedVC = self.presentedViewController {
            presentedVC.dismiss(animated: animated, completion: completion)
        } else {
            completion?()
        }
    }
}

extension UINavigationController {
    
    func backToViewController(vc: Any) {
        // iterate to find the type of vc
        for element in viewControllers as Array {
            if "\(type(of: element)).Type" == "\(type(of: vc))" {
                self.popToViewController(element, animated: true)
                break
            }
        }
    }
}

extension UISegmentedControl {
    
    func defaultConfiguration(font: UIFont = UIFont(name: Constants.KGraphikMedium, size: 13) ?? UIFont.systemFont(ofSize: 13, weight: .medium), color: UIColor = .color929292) {
        let defaultAttributes = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: color
        ]
        setTitleTextAttributes(defaultAttributes, for: .normal)
    }
    
    func selectedConfiguration(font: UIFont = UIFont(name: Constants.KGraphikMedium, size: 13) ?? UIFont.systemFont(ofSize: 13, weight: .medium), color: UIColor = .color202020FFFFFF) {
        let selectedAttributes = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: color
        ]
        setTitleTextAttributes(selectedAttributes, for: .selected)
    }
}

extension UITapGestureRecognizer {
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x, y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x, y: locationOfTouchInLabel.y - textContainerOffset.y)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
}

extension Range where Bound == String.Index {
    var nsRange:NSRange {
        return NSRange(location: self.lowerBound.encodedOffset,
                       length: self.upperBound.encodedOffset -
                       self.lowerBound.encodedOffset)
    }
}
