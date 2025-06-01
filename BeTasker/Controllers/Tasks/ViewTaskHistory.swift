//
//  ViewTaskHistory.swift
//  teamAlerts
//
//  Created by B2Cvertical A++ on 28/11/24.
//

import UIKit

class ViewTaskHistory: UIView {

    @IBOutlet weak var lblTitle: UILabel!
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "ViewTaskHistory", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ViewTaskHistory
    }

}
