//
//  StatusCollectionCell.swift
//  BeTasker
//
//  Created by kishlay kishore on 03/03/25.
//

import UIKit

class StatusCollectionCell: UICollectionViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var lblStatusText: UILabel!
    
    func configureCell(with dataModel: TaskStatusViewModel) {
        lblStatusText.text = dataModel.title
        lblStatusText.textColor = UIColor.color00000071
        if dataModel.isSelected {
            backView.backgroundColor = dataModel.colorValue.withAlphaComponent(1.0)
        } else {
            backView.backgroundColor = dataModel.colorValue.withAlphaComponent(0.4)
        }
    }
}
