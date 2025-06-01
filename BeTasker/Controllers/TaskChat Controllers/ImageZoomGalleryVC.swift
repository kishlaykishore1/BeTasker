//
//  ImageZoomGalleryVC.swift
//  BeTasker
//
//  Created by kishlay kishore on 19/04/25.
//

import UIKit
import Photos
import AVKit
import SDWebImage

class ImageZoomGalleryVC: UIViewController {
    
    // MARK: - UI
    private var pageViewController: UIPageViewController!
    private let btnNext = UIButton()
    private let btnPrev = UIButton()
    
    // MARK: - Variables
    var mediaURLs: [URL] = []
    var currentIndex: Int = 0 {
        didSet {
            updateUI()
        }
    }
    var onEditedImageReceive: ((UIImage) -> Void)?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .colorF4F4F4
        setupPageViewController()
        setupButtons()
        setupNavigation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.setNavigationBarImage(for: nil, color: UIColor.colorFFFFFF000000, txtcolor: UIColor.color191919, requireShadowLine: true, isTans: true)
        setBackButton(isImage: true, image: UIImage(named: "down-arrow") ?? UIImage())
        updateUI()
    }
    
    override func backBtnTapAction() {
        Global.setVibration()
        self.dismiss(animated: true)
    }
    
    // MARK: - Setup
    private func setupPageViewController() {
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        if let startVC = viewController(at: currentIndex) {
            pageViewController.setViewControllers([startVC], direction: .forward, animated: true)
        }
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.view.frame = view.bounds
        pageViewController.didMove(toParent: self)
    }
    
    private func setupButtons() {
        let size: CGFloat = 50
        let sideMargin: CGFloat = 4
        
        let config = UIImage.SymbolConfiguration(pointSize: 32, weight: .bold)
        btnPrev.setImage(UIImage(systemName: "chevron.left.circle.fill", withConfiguration: config), for: .normal)
        btnPrev.tintColor = .colorFFD200
        btnPrev.frame = CGRect(x: sideMargin, y: view.bounds.height / 2 - size / 2, width: size, height: size)
        btnPrev.addTarget(self, action: #selector(prevTapped), for: .touchUpInside)
        view.addSubview(btnPrev)
        
        btnNext.setImage(UIImage(systemName: "chevron.right.circle.fill", withConfiguration: config), for: .normal)
        btnNext.tintColor = .colorFFD200
        btnNext.frame = CGRect(x: view.bounds.width - size - sideMargin, y: view.bounds.height / 2 - size / 2, width: size, height: size)
        btnNext.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        view.addSubview(btnNext)
    }
    
    private func setupNavigation() {
        self.title = "\(currentIndex + 1) / \(mediaURLs.count)"
    }
    
    private func updateUI() {
        setupNavigation()
        btnNext.isHidden = mediaURLs.count <= 1 || currentIndex >= mediaURLs.count - 1
        btnPrev.isHidden = mediaURLs.count <= 1 || currentIndex <= 0
        
        // Determine if current media is image or video
        let currentURL = mediaURLs[currentIndex]
        let isImage = !currentURL.isVideoURL
        setTwoRightNavigationButtons(showEdit: isImage)
    }
    
    // MARK: - Actions
    @objc private func nextTapped() {
        Global.setVibration()
        guard currentIndex < mediaURLs.count - 1 else { return }
        currentIndex += 1
        if let vc = viewController(at: currentIndex) {
            pageViewController.setViewControllers([vc], direction: .forward, animated: true)
        }
    }
    
    @objc private func prevTapped() {
        Global.setVibration()
        guard currentIndex > 0 else { return }
        currentIndex -= 1
        if let vc = viewController(at: currentIndex) {
            pageViewController.setViewControllers([vc], direction: .reverse, animated: true)
        }
    }
    
    private func setTwoRightNavigationButtons(showEdit: Bool) {
        let btnShare = UIButton(type: .custom)
        btnShare.setImage(UIImage(named: "ic_Share"), for: .normal)
        btnShare.tintColor = .colorFFD200
        btnShare.imageView?.contentMode = .scaleAspectFit
        btnShare.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        btnShare.addTarget(self, action: #selector(shareImage), for: .touchUpInside)
        let item1 = UIBarButtonItem(customView: btnShare)
        
        let btnDownload = UIButton(type: .system)
        btnDownload.setImage(UIImage(systemName: "arrow.down.circle.fill"), for: .normal)
        btnDownload.tintColor = .colorFFD200
        btnDownload.imageView?.contentMode = .scaleAspectFit
        btnDownload.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        btnDownload.addTarget(self, action: #selector(downloadMedia), for: .touchUpInside)
        let item2 = UIBarButtonItem(customView: btnDownload)
        
        var rightItems = [item2, item1]

        if showEdit {
            let btnEditSend = UIButton(type: .system)
            btnEditSend.setImage(UIImage(systemName: "paintbrush.pointed.fill"), for: .normal)
            btnEditSend.tintColor = .colorFFD200
            btnEditSend.imageView?.contentMode = .scaleAspectFit
            btnEditSend.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
            btnEditSend.addTarget(self, action: #selector(btnSendEditedImage), for: .touchUpInside)
            let item3 = UIBarButtonItem(customView: btnEditSend)
            rightItems.append(item3)
            //insert(item3, at: 0)
        }
        
        self.navigationItem.setRightBarButtonItems(rightItems, animated: true)
    }
    
    private func openDrawingOn(image: UIImage, onDoneAction: ((UIImage) -> Void)?) {
        DispatchQueue.main.async {
            let drawingVC = DrawingVC(image: image, onDoneAction: onDoneAction)
            let navController = UINavigationController(rootViewController: drawingVC)
            navController.modalPresentationStyle = .fullScreen
            self.present(navController, animated: true)
        }
    }

    private func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        SDWebImageManager.shared.loadImage(with: url, options: .highPriority, progress: nil, completed: { [weak self] (image, data, error, cacheType, finished, url) in
            guard let self = self else { return }
            
            guard error == nil else {
                print("❌ Download error:", error!.localizedDescription)
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            guard let imgImage = image else {
                print("❌ Invalid image")
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            DispatchQueue.main.async {
                completion(imgImage)
            }
        })
    }

    @objc private func shareImage() {
        Global.setVibration()
        guard viewController(at: currentIndex) is MediaContentVC else { return }
        let mediaURL = mediaURLs[currentIndex]
        let activityVC = UIActivityViewController(activityItems: [mediaURL], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        self.present(activityVC, animated: true)
    }
    
    @objc private func downloadMedia() {
        Global.setVibration()
        let url = mediaURLs[currentIndex]
        Global.showLoadingSpinner(sender: view)
        URLSession.shared.downloadTask(with: url) { tempURL, _, error in
            DispatchQueue.main.async {
                Global.dismissLoadingSpinner(self.view)
            }
            
            guard let tempURL = tempURL, error == nil else {
                DispatchQueue.main.async {
                    Common.showAlertMessage(message: "Le téléchargement a échoué".localized, alertType: .error, isPreferLightStyle: false)
                }
                return
            }
            
            let originalExtension = url.pathExtension.lowercased()
                    
            if originalExtension == "pdf" || url.isVideoURL {
                // Rename temp file to have correct extension
                let fileName = "media_\(UUID().uuidString).\(originalExtension)"
                let tempDir = FileManager.default.temporaryDirectory
                let correctedURL = tempDir.appendingPathComponent(fileName)
                
                do {
                    try FileManager.default.moveItem(at: tempURL, to: correctedURL)
                    DispatchQueue.main.async {
                        let activityVC = UIActivityViewController(activityItems: [correctedURL], applicationActivities: nil)
                        activityVC.popoverPresentationController?.sourceView = self.view
                        self.present(activityVC, animated: true, completion: nil)
                    }
                } catch {
                    DispatchQueue.main.async {
                        Common.showAlertMessage(message: "Impossible de préparer le fichier à partager".localized, alertType: .error, isPreferLightStyle: false)
                    }
                }
                return
            }
            
            PHPhotoLibrary.requestAuthorization { status in
                if status == .authorized || status == .limited {
                    if let data = try? Data(contentsOf: tempURL),
                       let image = UIImage(data: data) {
                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                        DispatchQueue.main.async {
                            Common.showAlertMessage(message: "Image enregistrée dans Photos !".localized, alertType: .success, isPreferLightStyle: false)
                        }
                    } else {
                        DispatchQueue.main.async {
                            Common.showAlertMessage(message: "Le téléchargement de l’image a échoué".localized, alertType: .error, isPreferLightStyle: false)
                        }
                    }
                }
            }
        }.resume()
    }
    
    @objc private func btnSendEditedImage() {
        Global.setVibration()
        let currentURL = mediaURLs[currentIndex]
        downloadImage(from: currentURL) { [weak self] image in
            guard let self = self else { return }
            if let image = image {
                self.openDrawingOn(image: image) { [weak self] image in
                    self?.onEditedImageReceive?(image)
                }
                print("✅ Got image with size: \(image.size)")
            } else {
                print("❌ Failed to get UIImage")
            }

        }
    }
}

// MARK: - PageConroller Functions
extension ImageZoomGalleryVC: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    // MARK: - Page View Helpers
    func viewController(at index: Int) -> UIViewController? {
        guard index >= 0 && index < mediaURLs.count else { return nil }
        let vc = MediaContentVC()
        vc.mediaURL = mediaURLs[index]
        vc.index = index
        return vc
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? MediaContentVC else { return nil }
        return self.viewController(at: vc.index - 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? MediaContentVC else { return nil }
        return self.viewController(at: vc.index + 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed, let vc = pageViewController.viewControllers?.first as? MediaContentVC {
            currentIndex = vc.index
        }
    }
}

class MediaContentVC: UIViewController {
    var mediaURL: URL?
    var index: Int = 0
    let imageZoomView = ZoomImageView()
    var playerVC: AVPlayerViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let url = mediaURL else { return }

        if url.isVideoURL {
            let player = AVPlayer(url: url)
            let playerController = AVPlayerViewController()
            playerController.player = player
            playerController.view.frame = view.bounds
            playerController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            addChild(playerController)
            view.addSubview(playerController.view)
            playerController.didMove(toParent: self)
            self.playerVC = playerController
        } else {
            imageZoomView.frame = view.bounds
            imageZoomView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.addSubview(imageZoomView)
            imageZoomView.imageURL = url
            imageZoomView.showImage()
        }
    }
}

extension URL {
    var isVideoURL: Bool {
        let videoExtensions = ["mp4", "mov", "m4v"]
        return videoExtensions.contains(self.pathExtension.lowercased())
    }
}
