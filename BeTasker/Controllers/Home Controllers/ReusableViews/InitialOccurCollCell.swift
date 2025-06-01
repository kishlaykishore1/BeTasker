//
//  InitialOccurCollCell.swift
//  BeTasker
//
//  Created by kishlay kishore on 31/03/25.
//

import UIKit

protocol SelectedDateTimeDelegate: AnyObject {
    func sendSelectedDate(date: String)
}

class InitialOccurCollCell: UICollectionViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var bkgView: UIView!
    @IBOutlet weak var dtPicker: UIDatePicker!
    @IBOutlet weak var btnDate: UIButton!
    @IBOutlet weak var btnWidth: NSLayoutConstraint!
    
    // MARK: - Variables
    lazy var dtFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.medium
        dateFormatter.dateFormat = "dd MMM yyyy'     'HH:mm"
        dateFormatter.locale = Locale(identifier: Constants.lc)
        return dateFormatter
    }()
    weak var delegate: SelectedDateTimeDelegate?
    
    // MARK: - View Life Cycle
    override func awakeFromNib() {
        
        dtPicker.minuteInterval = 5
        dtPicker.addTarget(self, action: #selector(dateChangedInDate(sender:)), for: .valueChanged)
        //dtPicker.addTarget(self, action: #selector(pickerTapped), for: .allTouchEvents)
        DispatchQueue.main.async {
            self.bkgView.layer.cornerRadius = 8
            self.btnWidth.constant = self.bounds.width
            debugPrint(self.btnDate.frame)
            debugPrint(self.dtPicker.frame)
        }
    }
    
    func configure(with receivedDate: String?) {
        if receivedDate != nil {
            btnDate.setTitle(receivedDate, for: .normal)
        } else {
            let time = dtFormatter.string(from: Date())
            btnDate.setTitle(time, for: .normal)
        }
    }
    
    // MARK: - Helper Methods
    @objc func dateChangedInDate(sender:UIDatePicker) {
        dtFormatter.dateFormat = "dd MMM yyyy'     'HH:mm"
        let time = dtFormatter.string(from: sender.date)
//        HpGlobal.shared.programTemplateCreationData.alarmHour = time
        btnDate.setTitle(time, for: .normal)
        
        let newTime = Global.GetFormattedDate(date: sender.date, outputFormate: "yyyy-MM-dd HH:mm:ss", isInputUTC: false, isOutputUTC: true).dateString ?? ""
        self.delegate?.sendSelectedDate(date: newTime)
    }
    
//    @objc func pickerTapped() {
//        self.dtPicker.preferredDatePickerStyle = .wheels
//        self.dtPicker.preferredDatePickerStyle = .automatic
//    }
    
    // MARK: - Button Action Methods
    @IBAction func showDatePicker(_ sender: UIButton) {
        Global.setVibration()
        dtPicker.sendActions(for: .allTouchEvents)
    }
}
