//
//  NewFilterCollCell.swift
//  BeTasker
//
//  Created by kishlay kishore on 25/05/25.
//

import UIKit

class NewFilterCollCell: UICollectionViewCell {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var lblFilterText: UILabel!
    @IBOutlet weak var redDotView: UIView!
    
    override func awakeFromNib() {
        self.backView.layer.borderWidth = 1
        self.backView.layer.borderColor = UIColor(named: "ColorE1E1E1")?.cgColor
    }
    
    func checkForFilterSelection(isSelected: Bool) {
        self.redDotView.isHidden = !isSelected
    }
    
}
