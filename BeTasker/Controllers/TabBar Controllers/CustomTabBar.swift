//
//  CustomTabBar.swift
//  teamAlerts
//
//  Created by B2Cvertical A++ on 22/11/24.
//

import UIKit

class CustomTabBar: UITabBar {
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
            var newSize = super.sizeThatFits(size)
            newSize.height = 116 // Set your desired height
            return newSize
        }
    
    // MARK: - View Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground() // Removes top line
        appearance.shadowImage = UIImage()
        appearance.shadowColor = .clear
        appearance.backgroundColor = .clear
        self.standardAppearance = appearance
        
        if #available(iOS 15.0, *) {
            self.scrollEdgeAppearance = appearance
        }
    }
    
}
