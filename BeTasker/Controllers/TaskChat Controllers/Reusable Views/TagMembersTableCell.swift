//
//  TagMembersTableCell.swift
//  R.TYX
//
//  Created by Apple on 05/07/24.
//

import UIKit
import SDWebImage

class TagMembersTableCell: UITableViewCell {

    @IBOutlet weak var viewWithImage: UIView!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblRandomId: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureMember(member: Mention) {
        lblName.text = member.displayName
        lblRandomId.text = member.randomId
        imgProfile.sd_imageIndicator = SDWebImageActivityIndicator.gray
        imgProfile.sd_imageTransition = SDWebImageTransition.fade
        imgProfile.sd_setImage(with: member.profileImage, placeholderImage: UIImage(named: "no-user"))
    }

}
