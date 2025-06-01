//
//  HomeStatusCollCell.swift
//  BeTasker
//
//  Created by kishlay kishore on 25/05/25.
//

import UIKit

class HomeStatusCollCell: UICollectionViewCell {
    // MARK: - Outlets
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var lblStatusText: UILabel!
    @IBOutlet weak var countView: UIView!
    @IBOutlet weak var lblCount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.countView.layer.cornerRadius = self.countView.frame.height / 2
    }
    
    func configureCell(with dataModel: TaskStatusViewModel) {
        lblStatusText.text = dataModel.title
        lblStatusText.textColor = UIColor.color00000071
        countView.isHidden = dataModel.taskCount == 0
        lblCount.text = "\(dataModel.taskCount)"
        if dataModel.isSelected {
            backView.backgroundColor = dataModel.colorValue.withAlphaComponent(1.0)
        } else {
            backView.backgroundColor = dataModel.colorValue.withAlphaComponent(0.4)
        }
    }
}
