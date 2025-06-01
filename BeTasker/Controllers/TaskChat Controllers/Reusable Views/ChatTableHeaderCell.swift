//
//  ChatTableHeaderCell.swift
//  BeTasker
//
//  Created by kishlay kishore on 14/03/25.
//

import UIKit

class ChatTableHeaderCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var backView: UIView!
    
    // MARK: - View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        DispatchQueue.main.async {
            self.backView.layer.cornerRadius = self.backView.frame.height / 2
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
