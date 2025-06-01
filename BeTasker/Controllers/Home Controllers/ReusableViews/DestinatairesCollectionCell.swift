//
//  DestinatairesCollectionCell.swift
//  BeTasker
//
//  Created by kishlay kishore on 23/05/25.
//

import UIKit
import SDWebImage

class DestinatairesCollectionCell: UICollectionViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var bkgBorderView: UIView!
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViewShadow()
    }
    
    // MARK: - Helper Methods
    
    private func setupViewShadow() {
        DispatchQueue.main.async { [self] in
            bkgBorderView.layer.cornerRadius = bkgBorderView.frame.height / 2
            imgUser.layer.cornerRadius = imgUser.frame.height / 2
            
            bkgBorderView.applyShadow(radius: 3, opacity: 0.1, offset: CGSize(width: 0.0, height: 3.0))
        }
    }
    
    func configureCell(with dataModel: MembersDataViewModel) {
        lblName.text = dataModel.fullNameFormatted
        let img = #imageLiteral(resourceName: "no-user")
        imgUser.sd_imageIndicator = SDWebImageActivityIndicator.white
        imgUser.sd_imageTransition = SDWebImageTransition.fade
        imgUser.sd_setImage(with: dataModel.profilePicURL, placeholderImage: img)
        if dataModel.isSelected {
            bkgBorderView.backgroundColor = .colorFFD200
            lblName.font = UIFont(name: Constants.KGraphikMedium, size: 14) ?? UIFont.systemFont(ofSize: 14, weight: .medium)
        } else {
            bkgBorderView.backgroundColor = .colorFFFFFF202020
            lblName.font = UIFont(name: Constants.KGraphikRegular, size: 14) ?? UIFont.systemFont(ofSize: 14, weight: .regular)
        }
    }
}
