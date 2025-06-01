//
//  DisplayScannerVC.swift
//  BeTasker
//
//  Created by kishlay kishore on 10/04/25.
//

import UIKit
import BottomPopup
import SDWebImage

class DisplayScannerVC: BottomPopupViewController {

    // MARK: - Outlets
    @IBOutlet weak var backViewContainer: UIView!
    @IBOutlet weak var imgQRCode: UIImageView!
    @IBOutlet weak var lblRandomId: UILabel!
    @IBOutlet weak var qrBorderView: UIView!
    
    // MARK: - Variables
    private var containerHeight: CGFloat = Constants.kScreenHeight
    override var popupHeight: CGFloat {
        return containerHeight // Use the updated container height
    }
    override var popupTopCornerRadius: CGFloat {
        return 38
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        backViewContainer.layer.cornerRadius = 24
        backViewContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        qrBorderView.layer.borderWidth = 2.0
        qrBorderView.layer.borderColor = UIColor.white.cgColor
        NotificationCenter.default.addObserver(self, selector: #selector(setQRData), name: .updateProfile, object: nil)
        setQRData()
    }
    
    // MARK: - Helper Methods
    @objc func setQRData() {
         if let data = HpGlobal.shared.userInfo {
             lblRandomId.text = data.randomId.withHash
             let img = #imageLiteral(resourceName: "profile")
             imgQRCode.sd_imageIndicator = SDWebImageActivityIndicator.white
             imgQRCode.sd_imageTransition = SDWebImageTransition.fade
             imgQRCode.sd_setImage(with: data.qrCodeURL, placeholderImage: img)
         }
     }
    
    // MARK: - Button Action Methods
    @IBAction func btnCopyRandomId_Action(_ sender: Any) {
        Global.setVibration()
        UIPasteboard.general.string = lblRandomId.text
        Common.showAlertMessage(message: "ID BeTasker copié !".localized, alertType: .success, isPreferLightStyle: false)
    }
    
    @IBAction func btnShareID(_ sender: UIButton) {
        Global.setVibration()
        let textToShare = Global.shareToConnect()
        let activityVC = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
        activityVC.setValue("Découvre l'app BeTasker".localized, forKey: "Subject")
        self.present(activityVC, animated: true, completion: nil)
    }
}
