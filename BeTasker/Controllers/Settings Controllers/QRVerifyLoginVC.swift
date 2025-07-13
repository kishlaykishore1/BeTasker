//
//  QRVerifyLoginVC.swift
//  BeTasker
//
//  Created by kishlay kishore on 01/07/25.
//

import UIKit
import AVFoundation

struct QRPayload: Decodable {
    let action: String
    let token: String
    let app: String
    let url: String
}

class QRVerifyLoginVC: BaseViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var frameView: UIView!
    @IBOutlet weak var cameraView: UIView!
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
        self.navigationController?.popViewController(animated: true)
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
        let frame = CGRect(x: frameView.frame.origin.x, y: frameView.frame.origin.y + 80, width: frameView.frame.width, height: frameView.frame.height)
        let overlay = ScannerOverlayView(frame: view.bounds, scanFrame: frame)
        view.addSubview(overlay)
        view.bringSubviewToFront(viewWithObjects)
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

}

// MARK: - Delegate methods
extension QRVerifyLoginVC : AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
                  let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            debugPrint("Scanned value: \(stringValue)")
            guard let token = self.extractTokenFromString(receivedString: stringValue) else {
                Common.showAlertMessage(message: "Aucune donnée de connexion trouvée".localized, alertType: .error, isPreferLightStyle: false)
                return }
            self.apiToLinkUserDevice(token: token)
        }
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - Api Calling to Link devices
extension QRVerifyLoginVC {
    
    func extractTokenFromString(receivedString scannedValue: String) -> String? {
        guard let data = scannedValue.data(using: .utf8) else {
            print("Failed to convert string to Data")
            return nil
        }
        // Decode JSON
        do {
            let payload = try JSONDecoder().decode(QRPayload.self, from: data)
            return payload.token
        } catch {
            print("JSON decoding failed:", error)
            return nil
        }
    }
    
    func apiToLinkUserDevice(token: String) {
        guard let currentProfileData = HpGlobal.shared.userInfo else { return }
        
        let params: [String: Any] = [
            "token": token,
            "user_id": currentProfileData.userId,
        ]
        DispatchQueue.main.async {
            Global.showLoadingSpinner()
        }
        HpAPI.QRLOGIN.DataAPI(params: params, shouldShowError: false, shouldShowSuccess: false, key: nil) { (response: Result<[String: String], Error>) in
            DispatchQueue.main.async {
                Global.dismissLoadingSpinner()
                //clearLogoutDataFromApp()
            }
        }
    }
}
