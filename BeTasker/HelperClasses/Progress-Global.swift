import UIKit
import MBProgressHUD

extension Global {
    
    /*************************************************************/
    //MARK:- show/hide Global ProgressHUD
    /*************************************************************/
    
    @discardableResult public class func showLoadingSpinner(_ message: String? = "", sender: UIView? = UIApplication.topViewController()?.view) -> MBProgressHUD {
        if sender == nil {return MBProgressHUD()}
        let hud = MBProgressHUD.showAdded(to: sender!, animated: true)
        hud.tintColor = .black
        hud.show(animated: true)
        UIApplication.topViewController()?.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        return hud
    }
    
    public class func dismissLoadingSpinner(_ sender: UIView? = UIApplication.topViewController()?.view) -> Void {
        UIApplication.topViewController()?.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        if sender == nil {return}
        MBProgressHUD.hide(for:sender!, animated: true)
    }
    
    
    /*************************************************************/
    //MARK:- Clear All UserDefaults Values
    /*************************************************************/
    
    public class func clearAllAppUserDefaults() {
        
        for key in UserDefaults.standard.dictionaryRepresentation().keys {
            if key != "USERPASS" && key != "USEREMAIL" && key != "ISREMEMBER" && key != "FCMTOKEN" && key != "POLICYSCREEN" && key != "isNotFirstTime" {
                Constants.kUserDefaults.removeObject(forKey: key)
            }
        }
        UserDefaults.standard.synchronize()
    }
    
    
    public class func jsonToNSData(json: AnyObject) -> NSData?{
        return try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) as NSData
    }
}
