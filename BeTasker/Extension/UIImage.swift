//
//  UIImage.swift
//  EasyAC
//
//  Created by MAC3 on 27/04/23.
//

import Foundation
import UIKit

extension UIImage {
    func imageWithColor(color: UIColor) -> UIImage? {
        var image = withRenderingMode(.alwaysTemplate)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        color.set()
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
//    func imageOrientation(_ src:UIImage)->UIImage
//    {
//        if src.imageOrientation == UIImage.Orientation.up {
//            return src
//        }
//        var transform: CGAffineTransform = CGAffineTransform.identity
//        switch src.imageOrientation {
//        case UIImage.Orientation.down, UIImage.Orientation.downMirrored:
//            transform = transform.translatedBy(x: src.size.width, y: src.size.height)
//            transform = transform.rotated(by: CGFloat(Double.pi))
//            break
//        case UIImage.Orientation.left, UIImage.Orientation.leftMirrored:
//            transform = transform.translatedBy(x: src.size.width, y: 0)
//            transform = transform.rotated(by: CGFloat(Double.pi/2))
//            break
//        case UIImage.Orientation.right, UIImage.Orientation.rightMirrored:
//            transform = transform.translatedBy(x: 0, y: src.size.height)
//            transform = transform.rotated(by: CGFloat(-Double.pi/2))
//            break
//        case UIImage.Orientation.up, UIImage.Orientation.upMirrored:
//            break
//        @unknown default:
//            fatalError("No Image")
//        }
//        
//        switch src.imageOrientation {
//        case UIImage.Orientation.upMirrored, UIImage.Orientation.downMirrored:
//            transform.translatedBy(x: src.size.width, y: 0)
//            transform.scaledBy(x: -1, y: 1)
//            break
//        case UIImage.Orientation.leftMirrored, UIImage.Orientation.rightMirrored:
//            transform.translatedBy(x: src.size.height, y: 0)
//            transform.scaledBy(x: -1, y: 1)
//        case UIImage.Orientation.up, UIImage.Orientation.down, UIImage.Orientation.left, UIImage.Orientation.right:
//            break
//        @unknown default:
//            fatalError("No Image")
//        }
//        
//        let ctx:CGContext = CGContext(data: nil, width: Int(src.size.width), height: Int(src.size.height), bitsPerComponent: (src.cgImage)!.bitsPerComponent, bytesPerRow: 0, space: (src.cgImage)!.colorSpace!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
//        
//        ctx.concatenate(transform)
//        
//        switch src.imageOrientation {
//        case UIImage.Orientation.left, UIImage.Orientation.leftMirrored, UIImage.Orientation.right, UIImage.Orientation.rightMirrored:
//            ctx.draw(src.cgImage!, in: CGRect(x: 0, y: 0, width: src.size.height, height: src.size.width))
//            break
//        default:
//            ctx.draw(src.cgImage!, in: CGRect(x: 0, y: 0, width: src.size.width, height: src.size.height))
//            break
//        }
//        
//        let cgimg:CGImage = ctx.makeImage()!
//        let img:UIImage = UIImage(cgImage: cgimg)
//        
//        return img
//    }
    
}

extension UIImage {
    
    func resize(targetSize: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size:targetSize).image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
    
    var roundedImage: UIImage {
        let rect = CGRect(origin:CGPoint(x: 0, y: 0), size: self.size)
        UIGraphicsBeginImageContextWithOptions(self.size, false, 1)
        defer {
            // End context after returning to avoid memory leak
            UIGraphicsEndImageContext()
        }
        
        UIBezierPath(
            roundedRect: rect,
            cornerRadius: self.size.height
        ).addClip()
        self.draw(in: rect)
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
    
    var roundedImageBordered: UIImage {
        let rect = CGRect(origin:CGPoint(x: 3, y: 3), size: CGSize(width: 19, height: 19))
        UIGraphicsBeginImageContextWithOptions(self.size, false, 1)
        defer {
            // End context after returning to avoid memory leak
            UIGraphicsEndImageContext()
        }
        let path = UIBezierPath(
            roundedRect: rect,
            cornerRadius: 19/2 //self.size.height
        )
        path.lineWidth = 3
        #colorLiteral(red: 0.5393124223, green: 0.5981895328, blue: 0.6821180582, alpha: 1).setStroke()
        //UIColor.white.setStroke()
        path.stroke()
        path.addClip()
        self.draw(in: rect)
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
}
