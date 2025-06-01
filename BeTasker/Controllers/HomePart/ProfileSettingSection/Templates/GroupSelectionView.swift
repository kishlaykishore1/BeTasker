//
//  GroupSelectionView.swift
//  teamAlerts
//
//  Created by B2Cvertical A++ on 29/05/24.
//

import UIKit

class GroupSelectionView: UIView {

    @IBOutlet weak var imgCheck: UIImageView!
    @IBOutlet weak var lblGroupName: UILabel!
    
    var itemSelectedClouser: (()->())?
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "GroupSelectionView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    
    func setData(item: GroupViewModel) {
        imgCheck.isHighlighted = item.isSelected
        lblGroupName.text = item.title
    }

    @IBAction func itemSelected(_ sender: UIButton) {
        Global.setVibration()
        itemSelectedClouser?()
    }
}
