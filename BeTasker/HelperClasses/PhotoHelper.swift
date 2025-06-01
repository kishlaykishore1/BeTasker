//
//  PhotoHelper.swift
//  teamAlerts
//
//  Created by B2Cvertical A++ on 07/05/24.
//

//
//  PhotoHelper.swift
//  missing
//
//  Created by 55 agency on 01/08/23.
//

import UIKit
import Photos
import MobileCoreServices

protocol PrPhoto {
    func setPhotoData(image: UIImage?)
    func setDocumentData(image: UIImage?, data: Data?, fileType: FileType)
}

extension PrPhoto {
    func setDocumentData(image: UIImage?, data: Data?, fileType: FileType) {}
}

let imageCache = NSCache<NSString, AnyObject>()

class PhotoHelper: NSObject {
    
    static var shared = PhotoHelper()
    var imagePicker = UIImagePickerController()
    var delegate: PrPhoto?
    var viewController: UIViewController?
    
    func openCameraOnly(vc: UIViewController, allowsEditing: Bool, delegate: PrPhoto?, cameraDevice: UIImagePickerController.CameraDevice) {
        self.delegate = delegate
        self.viewController = vc
        self.checkCameraPermission(vc: vc, allowsEditing: allowsEditing, cameraDevice: cameraDevice)
    }
    
    func showActionSheet(vc: UIViewController, allowsEditing: Bool, delegate: PrPhoto?, cameraDevice: UIImagePickerController.CameraDevice, pdf: Bool = false) {
        self.delegate = delegate
        self.viewController = vc
        let alertVC: UIAlertController = UIAlertController(title: Messages.photoMassage, message: nil, preferredStyle: .actionSheet)
        let cameraActionButton: UIAlertAction = UIAlertAction(title: Messages.txtCamera.localized, style: .default) { void in
            Global.setVibration()
            self.checkCameraPermission(vc: vc, allowsEditing: allowsEditing, cameraDevice: cameraDevice)
        }
        alertVC.addAction(cameraActionButton)
        
        let photoLibraryActionButton: UIAlertAction = UIAlertAction(title: Messages.txtGallery.localized, style: .default) { void in
            Global.setVibration()
            self.checkPhotoLibraryPermission(vc: vc, allowsEditing: allowsEditing)
        }
        alertVC.addAction(photoLibraryActionButton)
        
        if pdf {
            let pdfAction = UIAlertAction(title: "PDF", style: .default) { _ in
                Global.setVibration()
                self.showPDFPicker(vc: vc)
            }
            alertVC.addAction(pdfAction)
        }
        
        let cancelActionButton: UIAlertAction = UIAlertAction(title: Messages.txtCancel.localized, style: .cancel) { void in
            Global.setVibration()
        }
        alertVC.addAction(cancelActionButton)
        //alertVC.overrideUserInterfaceStyle = .dark
        vc.present(alertVC, animated: true, completion: nil)
    }
    
    func showPDFPicker(vc: UIViewController) {
        if #available(iOS 14.0, *) {
            let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.pdf], asCopy: true)
            documentPicker.delegate = self
            documentPicker.modalPresentationStyle = .formSheet
            vc.present(documentPicker, animated: true, completion: nil)
        } else {
            let types: [String] = [kUTTypePDF as String]
            let documentPicker = UIDocumentPickerViewController(documentTypes: types, in: .import)
            documentPicker.delegate = self
            documentPicker.modalPresentationStyle = .formSheet
            vc.present(documentPicker, animated: true, completion: nil)
        }
        
    }
    
    func checkCameraPermission(vc: UIViewController, allowsEditing: Bool, cameraDevice: UIImagePickerController.CameraDevice) {
        let mediaType = AVMediaType.video
        switch AVCaptureDevice.authorizationStatus(for: mediaType) {
            
        case .authorized:
            self.openCamera(vc: vc, allowsEditing: allowsEditing, cameraDevice: cameraDevice)
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: mediaType) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.openCamera(vc: vc, allowsEditing: allowsEditing, cameraDevice: cameraDevice)
                    } else {
                        self.showCameraPermissionAlert(vc: vc)
                    }
                }
            }
            
        case .restricted, .denied:
            self.showCameraPermissionAlert(vc: vc)
            
        @unknown default:
            assertionFailure("Unknown authorization status".localized)
            self.showCameraPermissionAlert(vc: vc)
        }
    }
    
    func showCameraPermissionAlert(vc: UIViewController) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: Messages.cameraPermissionTitle, message: Messages.txtCameraPermission, preferredStyle: .alert)
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
            vc.present(alert, animated: true, completion: nil)
        }
    }
    
    func checkPhotoLibraryPermission(vc: UIViewController, allowsEditing: Bool) {
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization({status in
                if status == .authorized {
                    self.openGallary(vc: vc, allowsEditing: allowsEditing)
                }
            })
        } else if status == .denied {
            self.showPhotoLibraryPermissionAlert(vc: vc)
        } else if status == .authorized {
            self.openGallary(vc: vc, allowsEditing: allowsEditing)
        }
    }
    
    func showPhotoLibraryPermissionAlert(vc: UIViewController) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: Messages.photoLibraryPermissionTitle, message: Messages.txtLibraryPermission.localized, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: Messages.txtCancel.localized, style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: Messages.txtSetting.localized, style: .default, handler: { (error) in
                let url = URL(string: UIApplication.openSettingsURLString)
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url!, options: [:], completionHandler: { (error) in
                    })
                } else {
                    UIApplication.shared.openURL(url!)
                }
            }))
            vc.present(alert, animated: true, completion: nil)
        }
    }
    
    func openCamera(vc: UIViewController, allowsEditing: Bool, cameraDevice: UIImagePickerController.CameraDevice) {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)) {
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.cameraDevice = cameraDevice
            imagePicker.allowsEditing = allowsEditing
            imagePicker.mediaTypes = ["public.image"]
            imagePicker.delegate = self
            vc.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func openGallary(vc: UIViewController, allowsEditing: Bool) {
        DispatchQueue.main.async {
            self.imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            self.imagePicker.allowsEditing = allowsEditing
            self.imagePicker.delegate = self
            vc.present(self.imagePicker, animated: true, completion: nil)
        }
    }
    
    func PDFtoImage(url: URL, completion: @escaping ((_ image: UIImage?, _ url: URL?)->Void)) {
        DispatchQueue.global().async {
            
            if let cachedImage = imageCache.object(forKey: url.absoluteString as NSString) as? UIImage {
                completion(cachedImage, url)
                return
            }
            guard let document = CGPDFDocument(url as CFURL) else {
                DispatchQueue.main.async {
                    completion(nil, url)
                }
                return
            }
            if document.numberOfPages >= 1 {
                guard let page = document.page(at: 1) else {
                    DispatchQueue.main.async {
                        completion(nil, url)
                    }
                    return
                }
                let pageRect = page.getBoxRect(.mediaBox)
                let renderer = UIGraphicsImageRenderer(size: pageRect.size)
                let img = renderer.image { ctx in
                    UIColor.white.set()
                    ctx.fill(pageRect)
                    ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
                    ctx.cgContext.scaleBy(x: 1.0, y: -1.0)
                    ctx.cgContext.drawPDFPage(page)
                }
                DispatchQueue.main.async {
                    imageCache.setObject(img, forKey: url.absoluteString as NSString)
                    completion(img, url)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil, url)
                }
            }
        }
    }
    
}

extension PhotoHelper: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        if let editedImage = info[.editedImage] as? UIImage {
            delegate?.setPhotoData(image: editedImage)
            picker.dismiss(animated: true, completion: nil)
        } else if let originalImage = info[.originalImage] as? UIImage {
            delegate?.setPhotoData(image: originalImage)
            picker.dismiss(animated: true, completion: nil)
        }
    }
}

extension PhotoHelper: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let myURL = urls.first else {
            return
        }
        print("import result : \(myURL)")
        do {
            let data = try Data(contentsOf: myURL)
            PDFtoImage(url: myURL, completion: { (img, imgURL) in
                DispatchQueue.main.async {
                  self.delegate?.setDocumentData(image: img, data: data, fileType: .PDF)
                }
            })
        } catch (let err) {
            print(err.localizedDescription)
        }
    }
    
    func documentMenu(_ documentMenu:UIDocumentPickerViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        self.viewController?.present(documentPicker, animated: true, completion: nil)
    }
    
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("view was cancelled")
        //dismiss(animated: true, completion: nil)
    }
}

