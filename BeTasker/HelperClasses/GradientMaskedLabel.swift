//
//  GradientMaskedLabel.swift
//  teamAlerts
//
//  Created by B2Cvertical A++ on 25/11/24.
//
import UIKit

class GradientMaskedLabel: UILabel {
    
    private let gradientLayer = CAGradientLayer()
    private let textMaskLayer = CATextLayer()
    private var isAnimationAdded = false // Track if animation is already added
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //setupGradientLayer()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        //setupGradientLayer()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //updateGradientFrame()
    }
    
    private func setupGradientLayer() {
       
        // Configure Gradient Layer
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        
        let lightColor1 = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.75).cgColor
        let lightColor2 = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.5).cgColor
        let lightColor3 = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.2485996272).cgColor
        
        gradientLayer.colors = [
            UIColor.white.cgColor,
            lightColor1,
            lightColor2,
            lightColor3
        ]
        gradientLayer.frame = bounds
        layer.addSublayer(gradientLayer)
        
        // Configure Text Mask Layer
        textMaskLayer.contentsScale = UIScreen.main.scale
        textMaskLayer.alignmentMode = .center
        gradientLayer.mask = textMaskLayer
        
        
            // Start Gradient Animation
            let animation = CABasicAnimation(keyPath: "colors")
            
//            animation.fromValue = [
//                UIColor.white.cgColor,
//                UIColor.white.cgColor,
//                lightColor2,
//                lightColor3
//            ]
//            animation.toValue = [
//                lightColor3,
//                lightColor2,
//                UIColor.white.cgColor,
//                UIColor.white.cgColor
//            ]
        
        animation.fromValue = [
            UIColor.white.cgColor,
            lightColor1,
            lightColor2,
            lightColor3
        ]
        animation.toValue = [
            lightColor3,
            lightColor2,
            lightColor1,
            UIColor.white.cgColor
        ]
            animation.duration = 5
            animation.autoreverses = true
            animation.repeatCount = .infinity
            gradientLayer.add(animation, forKey: nil)
        
        // Hide Original Text
        textColor = .clear
    }
    
    private func updateGradientFrame() {
        // Update Gradient and Mask Frame
        gradientLayer.frame = bounds
        textMaskLayer.frame = bounds
        
        // Sync Text Mask Layer with UILabel Properties
        textMaskLayer.string = text
        textMaskLayer.font = font
        textMaskLayer.fontSize = font.pointSize
        textMaskLayer.foregroundColor = UIColor.black.cgColor
        
        // Set Text Alignment
        switch textAlignment {
        case .center:
            textMaskLayer.alignmentMode = .center
        case .left:
            textMaskLayer.alignmentMode = .left
        case .right:
            textMaskLayer.alignmentMode = .right
        default:
            textMaskLayer.alignmentMode = .center
        }
        
        gradientLayer.removeAllAnimations()
        
        // Start Gradient Animation
        let animation = CABasicAnimation(keyPath: "colors")
        let lightColor1 = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.75).cgColor
        let lightColor2 = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.5).cgColor
        let lightColor3 = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.2485996272).cgColor
        animation.fromValue = [
            UIColor.white.cgColor,
            UIColor.white.cgColor,
            lightColor2,
            lightColor3
        ]
        animation.toValue = [
            lightColor3,
            lightColor2,
            UIColor.white.cgColor,
            UIColor.white.cgColor
        ]
        animation.duration = 1
        animation.autoreverses = true
        animation.repeatCount = .infinity
        gradientLayer.add(animation, forKey: nil)
        
    }
}




class GradientMaskedView: UIView {
    
    private let gradientLayer = CAGradientLayer()
    private var isAnimationAdded = false // Track if animation is already added
//    private var maskedView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradientLayer()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradientLayer()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateGradientFrame()
    }
    
    private func setupGradientLayer() {
       
        self.clipsToBounds = true
        // Configure Gradient Layer
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        
        let lightColor1 = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.75).cgColor
        let lightColor2 = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.5).cgColor
        let lightColor3 = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.2485996272).cgColor
        
        gradientLayer.colors = [
            UIColor.white.cgColor,
            lightColor1,
            lightColor2,
            lightColor3
        ]
        gradientLayer.frame = bounds
        layer.addSublayer(gradientLayer)
        
        // Configure Text Mask Layer
//        textMaskLayer.contentsScale = UIScreen.main.scale
//        textMaskLayer.alignmentMode = .center
//        gradientLayer.mask = textMaskLayer
        
        
            // Start Gradient Animation
            let animation = CABasicAnimation(keyPath: "colors")
            
//            animation.fromValue = [
//                UIColor.white.cgColor,
//                UIColor.white.cgColor,
//                lightColor2,
//                lightColor3
//            ]
//            animation.toValue = [
//                lightColor3,
//                lightColor2,
//                UIColor.white.cgColor,
//                UIColor.white.cgColor
//            ]
        
        animation.fromValue = [
            UIColor.white.cgColor,
            lightColor1,
            lightColor2,
            lightColor3
        ]
        animation.toValue = [
            lightColor3,
            lightColor2,
            lightColor1,
            UIColor.white.cgColor
        ]
            animation.duration = 5
            animation.autoreverses = true
            animation.repeatCount = .infinity
            gradientLayer.add(animation, forKey: nil)
        
        // Hide Original Text
        //textColor = .clear
    }
    
    private func updateGradientFrame() {
        // Update Gradient and Mask Frame
        gradientLayer.frame = bounds
//        textMaskLayer.frame = bounds
//        
//        // Sync Text Mask Layer with UILabel Properties
//        textMaskLayer.string = text
//        textMaskLayer.font = font
//        textMaskLayer.fontSize = font.pointSize
//        textMaskLayer.foregroundColor = UIColor.black.cgColor
//        
//        // Set Text Alignment
//        switch textAlignment {
//        case .center:
//            textMaskLayer.alignmentMode = .center
//        case .left:
//            textMaskLayer.alignmentMode = .left
//        case .right:
//            textMaskLayer.alignmentMode = .right
//        default:
//            textMaskLayer.alignmentMode = .center
//        }
        
        gradientLayer.removeAllAnimations()
        
        // Start Gradient Animation
        let animation = CABasicAnimation(keyPath: "colors")
        let lightColor1 = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.75).cgColor
        let lightColor2 = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.5).cgColor
        let lightColor3 = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.2485996272).cgColor
        animation.fromValue = [
            UIColor.white.cgColor,
            lightColor1,
            lightColor2,
            lightColor3
        ]
        animation.toValue = [
            lightColor3,
            lightColor2,
            lightColor1,
            UIColor.white.cgColor
        ]
        animation.duration = 5
        animation.autoreverses = true
        animation.repeatCount = .infinity
        gradientLayer.add(animation, forKey: nil)
        
    }
}
