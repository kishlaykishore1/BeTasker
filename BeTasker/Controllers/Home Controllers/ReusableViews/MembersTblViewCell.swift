//
//  MembersTblViewCell.swift
//  BeTasker
//
//  Created by kishlay kishore on 19/03/25.
//

import UIKit

class MembersTblViewCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblAccessType: UILabel!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var lblInvitedDate: UILabel!
    
    var moreMenuClosure: ((_ sender: UIButton)->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func btnMoreTapAction(_ sender: UIButton) {
        Global.setVibration()
        moreMenuClosure?(sender)
    }

}
