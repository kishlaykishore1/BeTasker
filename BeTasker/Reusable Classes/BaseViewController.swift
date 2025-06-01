//
//  BaseViewController.swift
//  BeTasker
//
//  Created on 11/03/25.
//

import Foundation
import UIKit
import Photos
import MessageUI

public class BaseViewController: UIViewController {
    
    // MARK: - Variables
    var imagePicker = UIImagePickerController()
    var isUsingFrontCamera = false
    var isFlashOn = false
    
    // MARK: - View Life Cycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    // MARK: - Image Selection Sheet
    public func showFileSelectionSheet(isPresented: Bool = true) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: Messages.photoMassage, message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title:  Messages.txtCamera, style: .default, handler: { _ in
                self.checkCameraPermission()
            }))
            alert.addAction(UIAlertAction(title: Messages.txtGallery, style: .default, handler: { _ in
                self.checkPhotoLibraryPermission()
            }))
            alert.addAction(UIAlertAction.init(title: Messages.txtCancel, style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    
}

// MARK: - Camera Function
extension BaseViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    func checkCameraPermission() {
        let mediaType = AVMediaType.video
        switch AVCaptureDevice.authorizationStatus(for: mediaType) {
            
        case .authorized:
            self.openCamera()
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: mediaType) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.openCamera()
                    } else {
                        self.showCameraPermissionAlert()
                    }
                }
            }
            
        case .restricted, .denied:
            self.showCameraPermissionAlert()
            
        @unknown default:
            assertionFailure("Unknown authorization status".localized)
            self.showCameraPermissionAlert()
        }
    }
    
    func showCameraPermissionAlert(isPresented: Bool = true) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: Constants.kAppDisplayName, message: Messages.txtCameraPermission, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: Messages.txtCancel, style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: Messages.txtSetting, style: .cancel, handler: { (error) in
                let url = URL(string: UIApplication.openSettingsURLString)
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url!, options: [:], completionHandler: { (error) in
                    })
                } else {
                    UIApplication.shared.openURL(url!)
                }
            }))
            if isPresented {
                self.present(alert, animated: true, completion: nil)
            } else {
                Constants.kAppDelegate.window?.rootViewController?.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization({status in
                if status == .authorized {
                    self.openGallary()
                }
            })
        } else if status == .denied {
            self.showPhotoLibraryPermissionAlert()
        } else if status == .authorized {
            self.openGallary()
        }
    }
    
    func showPhotoLibraryPermissionAlert(isPresented: Bool = true) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: Constants.kAppDisplayName, message: Messages.txtLibraryPermission, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: Messages.txtCancel, style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: Messages.txtSetting, style: .default, handler: { (error) in
                let url = URL(string: UIApplication.openSettingsURLString)
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url!, options: [:], completionHandler: { (error) in
                    })
                } else {
                    UIApplication.shared.openURL(url!)
                }
            }))
            if isPresented {
                self.present(alert, animated: true, completion: nil)
            } else {
                Constants.kAppDelegate.window?.rootViewController?.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func openCamera() {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)) {
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = false
            imagePicker.cameraCaptureMode = .photo
            imagePicker.cameraDevice = isUsingFrontCamera ? .front : .rear
            imagePicker.mediaTypes = ["public.image"]
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func openGallary() {
        DispatchQueue.main.async {
            self.imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            self.imagePicker.allowsEditing = false
            self.imagePicker.delegate = self
            self.present(self.imagePicker, animated: true, completion: nil)
        }
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //code
    }
}

// MARK: - PopUp Details
extension BaseViewController {
    
    public func showConfirmationPopUp(title: String? = nil, message: String, confirmTitle: String? = "Confirmer", clickAction: Selector? = nil, isFromPresentedScreen: Bool = false) {
        DispatchQueue.main.async {
            Constants.kAppDelegate.window?.endEditing(true)
            let normalAlert = UIAlertController(title: title?.localized, message: message, preferredStyle: .alert)
            if clickAction == nil {
                normalAlert.addAction(UIAlertAction(title: confirmTitle, style: .default, handler: nil))
            } else {
                normalAlert.addAction(UIAlertAction(title: confirmTitle, style: .default, handler: { action in
                    self.perform(clickAction)
                }))
            }
            
            normalAlert.addAction(UIAlertAction(title: Messages.txtCancel, style: .cancel, handler: nil))
            
            if isFromPresentedScreen == true {
                self.present(normalAlert, animated: true, completion: nil)
            }else {
                let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) ?? UIApplication.shared.windows.first
                let topController = keyWindow?.rootViewController
                topController?.present(normalAlert, animated: true, completion: nil)
            }
        }
    }
    
    public func showDeletePopUp(title: String? = nil, message: String, deleteTitle: String? = "Confirmer", clickAction: Selector? = nil, isFromPresentedScreen: Bool = false) {
        DispatchQueue.main.async {
            Constants.kAppDelegate.window?.endEditing(true)
            let normalAlert = UIAlertController(title: title?.localized, message: message, preferredStyle: .alert)
            if clickAction == nil {
                normalAlert.addAction(UIAlertAction(title: deleteTitle , style: .destructive, handler: nil))
            } else {
                normalAlert.addAction(UIAlertAction(title: deleteTitle, style: .destructive, handler: { action in
                    self.perform(clickAction)
                }))
            }
            
            normalAlert.addAction(UIAlertAction(title: Messages.txtCancel, style: .cancel, handler: nil))
            
            if isFromPresentedScreen == true {
                self.present(normalAlert, animated: true, completion: nil)
            }else {
                let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) ?? UIApplication.shared.windows.first
                let topController = keyWindow?.rootViewController
                topController?.present(normalAlert, animated: true, completion: nil)
            }
        }
    }
}

// MARK: - Custom Camera Functions
extension BaseViewController {
    
    func presentCustomCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("Camera not available")
            return
        }
        
        imagePicker.sourceType = .camera
        imagePicker.showsCameraControls = false
        imagePicker.delegate = self
        imagePicker.cameraDevice = isUsingFrontCamera ? .front : .rear
        imagePicker.cameraCaptureMode = .photo
        imagePicker.modalPresentationStyle = .fullScreen
        
        if !isUsingFrontCamera {
            imagePicker.cameraFlashMode = isFlashOn ? .on : .off
        } else {
            imagePicker.cameraFlashMode = .off
        }
        
        // Custom overlay
        let overlay = UIView(frame: UIScreen.main.bounds)
        overlay.backgroundColor = .clear
        
        // Shutter Button
        let shutterButton = UIButton(type: .system)
        shutterButton.frame = CGRect(x: (overlay.bounds.width - 70) / 2, y: overlay.bounds.height - 100, width: 70, height: 70)
        shutterButton.layer.cornerRadius = 35
        shutterButton.backgroundColor = .white
        shutterButton.layer.borderColor = UIColor.black.cgColor
        shutterButton.layer.borderWidth = 2
        shutterButton.addTarget(self, action: #selector(shutterTapped), for: .touchUpInside)
        overlay.addSubview(shutterButton)
        
        // Cancel Button (top right)
        let cancelButton = UIButton(type: .system)
        cancelButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        cancelButton.tintColor = .white
        cancelButton.frame = CGRect(x: overlay.bounds.width - 60, y: 40, width: 40, height: 40)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        overlay.addSubview(cancelButton)
        
        // Flip Camera Button (top center)
        let flipButton = UIButton(type: .system)
        flipButton.setImage(UIImage(systemName: "camera.rotate.fill"), for: .normal)
        flipButton.tintColor = .white
        flipButton.frame = CGRect(x: (overlay.bounds.width - 40) / 2, y: 40, width: 40, height: 40)
        flipButton.addTarget(self, action: #selector(flipCameraTapped), for: .touchUpInside)
        overlay.addSubview(flipButton)
        
        // Flash Toggle Button (top left)
        let flashButton = UIButton(type: .system)
        flashButton.setImage(UIImage(systemName: isFlashOn ? "bolt.fill" : "bolt.slash.fill"), for: .normal)
        flashButton.tintColor = .white
        flashButton.frame = CGRect(x: 20, y: 40, width: 40, height: 40)
        flashButton.addTarget(self, action: #selector(flashTapped), for: .touchUpInside)
        overlay.addSubview(flashButton)
        
        imagePicker.cameraOverlayView = overlay
        self.present(imagePicker, animated: true)
    }
    
    @objc func shutterTapped() {
        imagePicker.takePicture()
    }
    
    @objc func cancelTapped() {
        imagePicker.dismiss(animated: true)
    }
    
    @objc func flipCameraTapped() {
        isUsingFrontCamera.toggle()
        imagePicker.dismiss(animated: false) {
            self.presentCustomCamera()
        }
    }
    
    @objc func flashTapped() {
        isFlashOn.toggle()
        imagePicker.dismiss(animated: false) {
            self.presentCustomCamera()
        }
    }
}

// MARK: - Send Mail
extension BaseViewController: MFMailComposeViewControllerDelegate {
    public func sendMail(email: String) {
        if !MFMailComposeViewController.canSendMail() {
            Common.showAlertMessage(message: Messages.mailNotFound, alertType: .warning)
            return
        }
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        composeVC.setToRecipients([email])
        composeVC.setSubject("Demande de contact".localized)
        composeVC.setMessageBody("", isHTML: false)
        self.present(composeVC, animated: true, completion: nil)
    }
    
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
