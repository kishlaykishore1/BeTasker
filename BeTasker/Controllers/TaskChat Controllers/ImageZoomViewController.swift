//
//  ImageZoomViewController.swift
//  teamAlerts
//
//  Created by MAC on 07/02/25.
//

import UIKit
import Photos

class ImageZoomViewController: UIViewController {

    // MARK: - Outlet
    @IBOutlet weak var imageZoomView: ZoomImageView!
    
    // MARK: - Variables
    open var imageURL: URL?
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageZoomView.imageURL = self.imageURL
        self.imageZoomView.showImage()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.setNavigationBarImage(for: nil, color: UIColor.colorFFFFFF000000, txtcolor: UIColor.color191919, requireShadowLine: true, isTans: true)

        let backImage = UIImage(named: "down-arrow")!
        setBackButton(isImage: true,image: backImage)
        self.imageZoomView.imageURL = self.imageURL
        self.setTwoRightNavigationButtons()
    }
    
    override func backBtnTapAction() {
        Global.setVibration()
        self.dismiss(animated: true)
    }
}

// MARK: - Navigation Bar Buttons functions
extension ImageZoomViewController {
    
    func setTwoRightNavigationButtons() {
        let btnShare = UIButton(type: .custom)
        btnShare.setImage(UIImage(named: "ic_Share"), for: .normal)
        btnShare.tintColor = .colorFFD200
        btnShare.imageView?.contentMode = .scaleAspectFit
        btnShare.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        btnShare.addTarget(self, action: #selector(btnShare_action), for: .touchUpInside)
        let item1 = UIBarButtonItem(customView: btnShare)
        
//        let spacer:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
//        spacer.width = 8
        
        let btnDownload = UIButton(type: .system)
        btnDownload.setImage(UIImage(systemName: "arrow.down.circle.fill"), for: .normal)
        btnDownload.tintColor = .colorFFD200
        btnDownload.imageView?.contentMode = .scaleAspectFit
        btnDownload.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        btnDownload.addTarget(self, action: #selector(btnDownload_Action), for: .touchUpInside)
        let item2 = UIBarButtonItem(customView: btnDownload)
        self.navigationItem.setRightBarButtonItems([item2,item1], animated: true)
    }
    
    @objc func btnShare_action(_ sender: UIButton) {
        Global.setVibration()
        guard let imageURL = imageURL else { return }
        if let image = self.imageZoomView.image {
            let activity = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            self.present(activity, animated: true, completion: nil)
        } else {
            let activity = UIActivityViewController(activityItems: [imageURL], applicationActivities: nil)
            self.present(activity, animated: true, completion: nil)
        }
    }
    
    @objc func btnDownload_Action(sender: UIButton) {
        Global.setVibration()
        self.downloadAndSaveImage(from: imageURL)
    }
}

// MARK: - Download Image and Save function
extension ImageZoomViewController {
    func downloadAndSaveImage(from imageUrl: URL?) {
        guard let url = imageUrl else {
            print("Invalid URL")
            return
        }
        Global.showLoadingSpinner(sender: self.view)
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Download Error: \(error.localizedDescription)")
                return
            }

            guard let data = data, let image = UIImage(data: data) else {
                print("Failed to convert data to image")
                return
            }

            // Save to Photos Library
            DispatchQueue.main.async {
                Global.dismissLoadingSpinner(self.view)
                PHPhotoLibrary.requestAuthorization { status in
                    if status == .authorized {
                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                        Common.showAlertMessage(message: "Image enregistrée dans Photos !".localized, alertType: .success, isPreferLightStyle: false)
                    } else {
                        print("Permission denied for saving to Photos")
                    }
                }
            }
        }.resume()
    }
}
