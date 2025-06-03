//
//  AddStatusVC.swift
//  teamAlerts
//
//  Created by B2Cvertical A++ on 24/01/25.
//

import UIKit
import BottomPopup
import Photos
import PhotosUI

protocol PrTaskStatus {
    func setTaskStatus(files: [[String: Any]], status: TaskStatusViewModel)
}

class AddStatusVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var vwContainer: UIView!
    @IBOutlet weak var clnPhotoes: UICollectionView!
    @IBOutlet weak var vwSliderContainerView: SlideToSendContainerView!
    @IBOutlet weak var statusTitleLabel: UILabel!
    
    // MARK: - Variables
    var taskId: Int?
    var statusData: TaskStatusViewModel?
    var arrImages = [ImageModel?]()
    var deletedImageIds = [String]()
    var selectedIndex = 0
    var delegateStatus: PrTaskStatus?
    var imagePicker = UIImagePickerController()
    private var containerHeight: CGFloat = Constants.kScreenHeight // Variable to store vwContainer height
    var isLayoutDone = false
    var isPhotoEnabled = false
    
    // MARK: - View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if PremiumManager.shared.isPremium {
            arrImages = [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]
        } else {
            arrImages = [nil, nil, nil, nil, nil]
        }
        self.vwSliderContainerView.applyShadow(radius: 3, opacity: 0.1, offset: CGSize(width: 0.0, height: 3.0))
        self.vwSliderContainerView.delegate = self
        setBackgroundOfSlider()
        if let statusData {
            self.statusTitleLabel.text = statusData.title
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.vwSliderContainerView.startAnimating()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
        self.vwSliderContainerView.stopAnimating()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !isLayoutDone {
            isLayoutDone = true
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.vwContainer.roundCorners([.topLeft, .topRight], radius: 38)
            }
        }
    }
    
    // MARK: - Helper Methods
    func firstEmptyIndex() -> Int? {
        return arrImages.firstIndex(where: { $0 == nil })
    }
    
    func setBackgroundOfSlider() {
        self.vwSliderContainerView.containerBackGroundColor = statusData?.colorValue ?? UIColor.color62DD3C
        let imageName = "double-arrow-green"
        self.vwSliderContainerView.arrowImage = UIImage(named: imageName)
    }
    
    func undoSlider() {
        self.vwSliderContainerView.resetSliderView()
    }
    
    private func triggerSendAction() {
        // Perform the "send" action
        print("Action triggered: Sending...")
        //self.undoSlider()
        taskCompletion {[weak self] done in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.undoSlider()
                if done { self.dismiss(animated: true) }
            }
        }
    }
}

extension AddStatusVC: SlideToSendDelegate {
    
    func slideToSendDelegateDidFinish(_ sender: SlideToSendContainerView) {
        self.triggerSendAction()
    }
}

// MARK: - Collection View Delegate and Datasource Methods
extension AddStatusVC: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionCell", for: indexPath) as! PhotoCollectionCell
        
        cell.imgPhoto.image = arrImages[indexPath.row]?.img
        cell.imgCamera.isHidden = arrImages[indexPath.row] != nil
        cell.vwRemovePhoto.isHidden = arrImages[indexPath.row] == nil
        
        if arrImages[indexPath.row]?.img != nil {
            if arrImages[indexPath.row]?.data == nil {
                cell.imgPhoto.alpha = 0.2
                cell.vwLoader.startAnimating()
                cell.vwRemovePhoto.isHidden = true
            } else {
                cell.imgPhoto.alpha = 1.0
                cell.vwLoader.stopAnimating()
                cell.vwRemovePhoto.isHidden = false
            }
        } else {
            cell.imgPhoto.alpha = 1.0
            cell.vwLoader.stopAnimating()
            cell.vwRemovePhoto.isHidden = true
        }
        
        cell.removePhotoClosure = { [weak self] in
            self?.RemovePhoto(idx: indexPath.row)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        self.showFileSelectionSheet()
    }
    
    func RemovePhoto(idx: Int) {
        if let id = arrImages[idx]?.data?.id {
            deletedImageIds.append("\(id)")
        }
        arrImages[idx] = nil
        clnPhotoes.reloadData()
    }
}

extension AddStatusVC {
    func taskCompletion(completion: @escaping(_ done: Bool)->()) {
        guard let id = taskId else { return }
        let imageNames = arrImages.compactMap({$0?.data?.imageName}).joined(separator: ",")
        
        if statusData?.id == 4 && isPhotoEnabled && imageNames == "" {
            Common.showAlertMessage(message: "Veuillez ajouter au moins une photo.".localized, alertType: .error, isPreferLightStyle: false)
            undoSlider()
            return
        }
        
        var params: [String: Any] = [
            "task_id": id,
            "task_status_id": statusData?.id ?? 0,
            "client_secret": Constants.kClientSecret
        ]
        if imageNames != "" {
            params["file_name"] = imageNames
        }
        
        Global.showLoadingSpinner(sender: self.view)
        TaskStatusViewModel.updateTaskStatus(params: params) { arrFiles in
            DispatchQueue.main.async {
                Global.dismissLoadingSpinner(self.view)
                self.dismiss(animated: true) {
                    if let statusData = self.statusData {
                        self.delegateStatus?.setTaskStatus(files: arrFiles, status: statusData)
                    }
                }
            }
        }
    }
}
// MARK: - Camera Picker
extension AddStatusVC {
    // MARK: - Image Selection Sheet
    func showFileSelectionSheet(isPresented: Bool = true) {
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
            imagePicker.mediaTypes = ["public.image"]
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func openGallary() {
        var config = PHPickerConfiguration()
        config.selectionLimit = PremiumManager.shared.isPremium ? 10 : 5
        config.filter = .any(of: [.images, .videos]) // Allow both images and videos
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
}

// MARK: - ImagePicker Delegate Methods
extension AddStatusVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImage: UIImage?
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImage = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
        }
        picker.dismiss(animated: true) { [self] in
            let imgData = selectedImage?.jpegData(compressionQuality: 0.5)
            var obj = ImageModel()
            obj.img = selectedImage
            //obj.data = imageRes
            self.arrImages[self.selectedIndex] = obj
            self.clnPhotoes.reloadData()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if (self.selectedIndex + 1) < 5 {
                    let nextIdx = IndexPath(row: (self.selectedIndex + 1), section: 0)
                    self.clnPhotoes.scrollToItem(at: nextIdx, at: .centeredHorizontally, animated: true)
                }
            }
            
            FileViewModel.UploadImage(mediaType: .Image, data: imgData, idx: self.selectedIndex) { (imageRes, idx) in
                DispatchQueue.main.async {
                    Global.dismissLoadingSpinner(self.view)
                    if let imageRes = imageRes {
                        var obj = ImageModel()
                        obj.img = selectedImage
                        obj.data = imageRes
                        self.arrImages[idx] = obj
                        self.clnPhotoes.reloadData()
                    } else {
                        self.arrImages[idx] = nil
                        self.clnPhotoes.reloadData()
                    }
                }
            }
        }
    }
}

// MARK: - PHIController Delegate Methods
extension AddStatusVC: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        picker.dismiss(animated: true) { [self] in
            if results.isEmpty { return }
            
            let emptyIndices = arrImages.enumerated().compactMap { $0.element == nil ? $0.offset : nil }
            let selectionLimit = min(emptyIndices.count, results.count)
            
            for (i, result) in results.prefix(selectionLimit).enumerated() {
                let slotIndex = emptyIndices[i]
                let provider = result.itemProvider
                
                if provider.canLoadObject(ofClass: UIImage.self) {
                    provider.loadObject(ofClass: UIImage.self) { object, error in
                        guard let selectedImage = object as? UIImage else { return }
                        
                        DispatchQueue.main.async {
                            var obj = ImageModel()
                            obj.img = selectedImage
                            self.arrImages[slotIndex] = obj
                            self.clnPhotoes.reloadData()
                            
                            let imgData = selectedImage.jpegData(compressionQuality: 0.5)
                            FileViewModel.UploadImage(mediaType: .Image, data: imgData, idx: slotIndex) { imageRes, idx in
                                DispatchQueue.main.async {
                                    Global.dismissLoadingSpinner(self.view)
                                    if let imageRes = imageRes {
                                        var obj = ImageModel()
                                        obj.img = selectedImage
                                        obj.data = imageRes
                                        self.arrImages[idx] = obj
                                    } else {
                                        self.arrImages[idx] = nil
                                    }
                                    self.clnPhotoes.reloadData()
                                }
                            }
                        }
                    }
                } else if provider.hasItemConformingToTypeIdentifier("public.movie") {
                    provider.loadFileRepresentation(forTypeIdentifier: "public.movie") { url, error in
                        guard let url = url else { return }
                        let fileName = url.lastPathComponent
                        let destinationURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
                        try? FileManager.default.copyItem(at: url, to: destinationURL)
                        let thumbnail = Global.generateThumbnail(url: destinationURL)
                        
                        // Check file size
                        do {
                            let fileSize = try FileManager.default.attributesOfItem(atPath: destinationURL.path)[.size] as? Int64 ?? 0
                            let fileSizeMB = Double(fileSize) / (1024 * 1024)
                            debugPrint("Video size: \(fileSizeMB) MB")
                            
                            if fileSizeMB > 20 {
                                Common.showAlertMessage(message: "La vidéo sélectionnée fait plus de 20 Mo. Veuillez en choisir une plus petite.".localized, alertType: .error)
                            } else {
                                DispatchQueue.main.async {
                                    var obj = ImageModel()
                                    obj.img = thumbnail
                                    self.arrImages[slotIndex] = obj
                                    self.clnPhotoes.reloadData()
                                    
                                    if let videoData = try? Data(contentsOf: destinationURL) {
                                        FileViewModel.UploadImage(mediaType: .Video, data: videoData, idx: slotIndex) { videoRes, idx in
                                            DispatchQueue.main.async {
                                                Global.dismissLoadingSpinner(self.view)
                                                if let videoRes = videoRes {
                                                    var obj = ImageModel()
                                                    obj.img = thumbnail
                                                    obj.data = videoRes
                                                    self.arrImages[idx] = obj
                                                } else {
                                                    self.arrImages[idx] = nil
                                                }
                                                self.clnPhotoes.reloadData()
                                            }
                                        }
                                    }
                                }
                            }
                        } catch {
                            debugPrint("❌ Failed to get file size: \(error)")
                        }
                    }
                }
            }
        }
    }
    
    func generateThumbnail(url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        let time = CMTime(seconds: 1.0, preferredTimescale: 600)
        
        do {
            let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            let thumbnail = UIImage(cgImage: img)
            return thumbnail
        } catch {
            print("Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
    
}
