//
//  ReccuringDaysCollCell.swift
//  BeTasker
//
//  Created by kishlay kishore on 31/03/25.
//

import UIKit

class ReccuringDaysCollCell: UICollectionViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var bkgView: UIView!
    @IBOutlet weak var lblTitleName: UILabel!
    
    // MARK: - View Life cycle
    override func awakeFromNib() {
        DispatchQueue.main.async {
            self.bkgView.layer.cornerRadius = 8
        }
    }
}
