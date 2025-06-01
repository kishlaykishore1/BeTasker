//
//  QRScannerVC.swift
//  BeTasker
//
//  Created by kishlay kishore on 06/04/25.
//

import UIKit
import AVFoundation

protocol QRScannerDelegate: AnyObject {
    func didScan(result: String)
}

class QRScannerVC: BaseViewController {

    // MARK: - Outlets
    @IBOutlet weak var frameView: UIView!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var lblInvite: UILabel!
    @IBOutlet weak var viewWithObjects: UIView!
    
    // MARK: - Variables
    var captureSession: AVCaptureSession!
    var scanFrameView: UIView!
    weak var delegate: QRScannerDelegate?
    override var prefersStatusBarHidden: Bool { true }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        self.setupTheAVSession()
        self.setupOverlay()
        let tapLabel = UITapGestureRecognizer(target: self, action: #selector(tapLabel(tap:)))
        lblInvite.addGestureRecognizer(tapLabel)
        lblInvite.isUserInteractionEnabled = true
        self.setupContactShareText()
    }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.setNavigationBarImage(for: nil, color: .clear, txtcolor: .clear, requireShadowLine: false, isTans: true)
        setBackButton(isImage: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.stopSession()
    }
    
    override func backBtnTapAction() {
        Global.setVibration()
        self.dismiss(animated: true)
    }
    
    // MARK: - Helper Function
    func setupTheAVSession() {
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            print("No camera available")
            return
        }
        
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            print("Can't create video input")
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            print("Could not add input")
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            print("Could not add metadata output")
            return
        }
        
        DispatchQueue.main.async {
            let cameraLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
            cameraLayer.layoutIfNeeded()
            cameraLayer.frame = self.cameraView.bounds
            cameraLayer.videoGravity = .resizeAspectFill
            self.cameraView.layer.addSublayer(cameraLayer)
            self.cameraView.layoutIfNeeded()
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }
    
    func stopSession() {
        if captureSession.isRunning {
            DispatchQueue.global().async {
                self.captureSession.stopRunning()
            }
        }
    }
    
    private func setupOverlay() {
        let frame = CGRect(x: frameView.frame.origin.x, y: frameView.frame.origin.y + 40, width: frameView.frame.width, height: frameView.frame.height)
        let overlay = ScannerOverlayView(frame: view.bounds, scanFrame: frame)
        view.addSubview(overlay)
        view.bringSubviewToFront(viewWithObjects)
    }
    
    func setupContactShareText() {
        let clr = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        lblInvite.numberOfLines = 0
        lblInvite.textColor = clr
        let txtYourContact = NSMutableAttributedString(string: "Votre contact n’est pas encore sur BeTasker ? \n".localized, attributes: [NSAttributedString.Key.foregroundColor: clr, NSAttributedString.Key.font: UIFont(name: Constants.KGraphikRegular, size: lblInvite.font.pointSize) ?? UIFont.systemFont(ofSize: lblInvite.font.pointSize, weight: .regular)])
        let txtDownload = NSMutableAttributedString(string: "Invitez-le à télécharger l’app ".localized, attributes: [NSAttributedString.Key.foregroundColor: clr, NSAttributedString.Key.font: UIFont(name: Constants.KGraphikMedium, size: lblInvite.font.pointSize) ?? UIFont.systemFont(ofSize: lblInvite.font.pointSize, weight: .medium)])
        let finalString = NSMutableAttributedString()
        finalString.append(txtYourContact)
        finalString.append(txtDownload)
        lblInvite.attributedText = finalString
    }
    
    @objc func tapLabel(tap: UITapGestureRecognizer) {
        Global.setVibration()
        let textToShare = Global.shareToConnect()
        let activityVC = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
        activityVC.setValue("Découvre l'app BeTasker".localized, forKey: "Subject")
        self.present(activityVC, animated: true, completion: nil)
    }
    
    func detectQRCode(in image: UIImage) -> String? {
        guard let ciImage = CIImage(image: image) else { return nil }
        
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        let features = detector?.features(in: ciImage) ?? []
        
        for feature in features {
            if let qrFeature = feature as? CIQRCodeFeature {
                return qrFeature.messageString
            }
        }
        return nil
    }
    
    // MARK: - Button Action Methods
    @IBAction func btnImport_Action(_ sender: UIButton) {
        Global.setVibration()
        self.checkPhotoLibraryPermission()
    }
    

}

// MARK: - Delegate methods
extension QRScannerVC : AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
                  let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            debugPrint("Scanned value: \(stringValue)")
            delegate?.didScan(result: stringValue)
        }
        self.dismiss(animated: true)
    }
}

// MARK: - Gallery Methods Function
extension QRScannerVC {
    
    override func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let originalImage = info[.originalImage] as? UIImage {
            if let qrString = detectQRCode(in: originalImage) {
                print("QR Code Data: \(qrString)")
                delegate?.didScan(result: qrString)
            } else {
                Common.showAlertMessage(message: "No QR code found.!".localized, alertType: .success, isPreferLightStyle: false)
            }
        }
        picker.dismiss(animated: true)
        self.dismiss(animated: true)
    }
}
