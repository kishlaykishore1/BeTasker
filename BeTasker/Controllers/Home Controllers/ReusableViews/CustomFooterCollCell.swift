//
//  CustomFooterCollCell.swift
//  BeTasker
//
//  Created by kishlay kishore on 18/04/25.
//

import UIKit

class CustomFooterCollCell: UICollectionReusableView {
    // MARK: - Outlets
    @IBOutlet weak var switchSchedule: UISwitch!
    
    // MARK: - Variables
    static let reuseIdentifier = "CustomFooterCollCell"
    var updateButtonClosure: ((Bool)->())?
    
    func configure(with value: Bool) {
        if value {
            switchSchedule.isOn = true
        } else {
            switchSchedule.isOn = false
        }
    }
    
    // MARK: - Button Action Methods
    @IBAction func switch_Action(_ sender: UISwitch) {
        Global.setVibration()
        updateButtonClosure?(sender.isOn)
    }
    
}
