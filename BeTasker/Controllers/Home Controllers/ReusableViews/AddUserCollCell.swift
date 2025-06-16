//
//  AddUserCollCell.swift
//  BeTasker
//
//  Created by kishlay kishore on 16/06/25.
//

import UIKit

class AddUserCollCell: UICollectionViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var bkgBorderView: UIView!
    @IBOutlet weak var imgUser: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViewShadow()
    }
    
    // MARK: - Helper Methods
    
    private func setupViewShadow() {
        DispatchQueue.main.async { [self] in
            bkgBorderView.layer.cornerRadius = bkgBorderView.frame.height / 2
            imgUser.layer.cornerRadius = imgUser.frame.height / 2
            
            //bkgBorderView.applyShadow(radius: 3, opacity: 0.1, offset: CGSize(width: 0.0, height: 3.0))
        }
    }
}
