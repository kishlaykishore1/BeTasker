//
//  ScannerOverlayView.swift
//  BeTasker
//
//  Created by kishlay kishore on 08/04/25.
//

import Foundation

class ScannerOverlayView: UIView {
    
    var scannerFrame: CGRect = .zero
    private let cornerRadius: CGFloat = 27
    private let borderColor: UIColor = .colorFFD01E
    private let borderWidth: CGFloat = 9

    // Custom initializer
    init(frame: CGRect, scanFrame: CGRect) {
        scannerFrame = scanFrame
        super.init(frame: frame)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        let path = UIBezierPath(rect: self.bounds)
        
        // Clear "scanner frame" in the center
        let clearRect = scannerFrame
        let clearPath = UIBezierPath(roundedRect: clearRect, cornerRadius: cornerRadius)
        
        path.append(clearPath)
        path.usesEvenOddFillRule = true
        
        // Overlay Fill Layer (with transparent hole)
        let fillLayer = CAShapeLayer()
        fillLayer.path = path.cgPath
        fillLayer.fillRule = .evenOdd
        fillLayer.fillColor = UIColor.black.withAlphaComponent(0.6).cgColor
        layer.addSublayer(fillLayer)
        
        // Border Layer
        let borderPath = UIBezierPath(roundedRect: clearRect, cornerRadius: cornerRadius)
        let borderLayer = CAShapeLayer()
        borderLayer.path = borderPath.cgPath
        borderLayer.strokeColor = borderColor.cgColor
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.lineWidth = borderWidth
        layer.addSublayer(borderLayer)
    }
}
