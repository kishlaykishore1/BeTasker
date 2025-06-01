//
//  ViewUser.swift
//  teamAlerts
//
//  Created by B2Cvertical A++ on 06/12/24.
//

import UIKit

class ViewUser: UIView {

    @IBOutlet weak var imgUser: UIImageView!
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "ViewUser", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ViewUser
    }

}
