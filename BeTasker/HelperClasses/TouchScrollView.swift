//
//  TouchScrollView.swift
//  EasyAC
//
//  Created by MAC3 on 25/05/23.
//

import Foundation
import UIKit

protocol PassTouchesScrollViewDelegate {
    func scrollViewTouchBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    func scrollViewTouchMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    func scrollViewTouchEnded(_ touches: Set<UITouch>, with event: UIEvent?)
}


class PassTouchesScrollView: UIScrollView {
    
    var delegatePass : PassTouchesScrollViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        for gesture in self.gestureRecognizers ?? [] {
            gesture.cancelsTouchesInView = false
            gesture.delaysTouchesBegan = false
            gesture.delaysTouchesEnded = false
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegatePass?.scrollViewTouchBegan(touches, with: event)
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegatePass?.scrollViewTouchMoved(touches, with: event)
        super.touchesMoved(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegatePass?.scrollViewTouchEnded(touches, with: event)
        super.touchesEnded(touches, with: event)
    }
}
