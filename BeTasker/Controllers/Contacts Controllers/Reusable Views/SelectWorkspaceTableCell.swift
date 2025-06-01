//
//  SelectWorkspaceTableCell.swift
//  BeTasker
//
//  Created by kishlay kishore on 22/03/25.
//

import UIKit

class SelectWorkspaceTableCell: UITableViewCell {

    // MARK: - outlets
    @IBOutlet weak var lblWSName: UILabel!
    @IBOutlet weak var lblWSMember: UILabel!
    @IBOutlet weak var imgCheck: UIImageView!
    @IBOutlet weak var imgWorkSpace: UIImageView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var notificationCountContainer: UIView!
    @IBOutlet weak var bottomLine: UILabel!
    
    // MARK: - Outlets
    override func awakeFromNib() {
        super.awakeFromNib()
        notificationCountContainer.layer.cornerRadius = 12
        notificationCountContainer.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
