//
//  StatusArchiveCell.swift
//  BeTasker
//
//  Created by kishlay kishore on 21/03/25.
//

import UIKit

class StatusArchiveCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var lblStatusDate: UILabel!
    @IBOutlet weak var lblArchive: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
