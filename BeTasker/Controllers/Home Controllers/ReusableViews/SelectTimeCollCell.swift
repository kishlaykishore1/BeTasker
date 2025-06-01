//
//  SelectTimeCollCell.swift
//  BeTasker
//
//  Created by kishlay kishore on 31/03/25.
//

import UIKit

class SelectTimeCollCell: UICollectionViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var bkgView: UIView!
    @IBOutlet weak var dtPicker: UIDatePicker!
    @IBOutlet weak var btnDate: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    
    // MARK: - Variables
    lazy var dtFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.medium
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.locale = Locale(identifier: Constants.lc)
        return dateFormatter
    }()
    var removeActionClosure: (()->())?
    var updateTimeClosure: ((String)->())?
    
    // MARK: - View Life Cycle
    override func awakeFromNib() {
        DispatchQueue.main.async {
            self.bkgView.layer.cornerRadius = 8
        }
    }
    
    
    // MARK: - Helper Methods
    
    func configure(with time: String) {
        var receivedTime = ""
        if time != "" {
            receivedTime = time
        } else {
            receivedTime = dtFormatter.string(from: Date())
        }
        dtPicker.minuteInterval = 5
        btnDate.setTitle(receivedTime, for: .normal)
        dtPicker.addTarget(self, action: #selector(dateChangedInDate(sender:)), for: .valueChanged)
    }
    
    @objc func dateChangedInDate(sender:UIDatePicker) {
        let time = dtFormatter.string(from: sender.date)
        HpGlobal.shared.programTemplateCreationData.alarmHour = time
        btnDate.setTitle(time, for: .normal)
        updateTimeClosure?(time)
     }
    
    // MARK: - Button Action Methods
    @IBAction func showDatePicker(_ sender: UIButton) {
        Global.setVibration()
        dtPicker.sendActions(for: .allTouchEvents)
    }
    
    @IBAction func removeItem(_ sender: UIButton) {
        Global.setVibration()
        removeActionClosure?()
    }
}
