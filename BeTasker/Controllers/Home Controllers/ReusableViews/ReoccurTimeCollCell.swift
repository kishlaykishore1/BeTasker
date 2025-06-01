//
//  ReoccurTimeCollCell.swift
//  BeTasker
//
//  Created by kishlay kishore on 31/03/25.
//

import UIKit
import IQKeyboardManagerSwift

protocol SelectedDurationDelegate: AnyObject {
    func sendSelectedDuration(duration: Int)
}

class ReoccurTimeCollCell: UICollectionViewCell {
   
    // MARK: - Outlets
    @IBOutlet weak var bkgView: UIView!
    @IBOutlet weak var txtOccuranceDuration: UITextField!
    
    // MARK: - Variables
    let pickerView = UIPickerView()
    let pickerData = ["Tous les 1 mois".localized, "Tous les 2 mois".localized, "Tous les 3 mois".localized, "Tous les 4 mois".localized, "Tous les 6 mois".localized, "Tous les 12 mois".localized]
    weak var delegate: SelectedDurationDelegate?
    
    // MARK: - View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        IQKeyboardManager.shared.enableAutoToolbar = true
        txtOccuranceDuration.delegate = self
        
    }
    
    func configure(with selectedDuration: String?) {
        if selectedDuration != nil {
            self.txtOccuranceDuration.text = pickerData[getpickerDataIndex(selectedDuration: selectedDuration ?? "1")]
        } else {
            self.txtOccuranceDuration.text = pickerData[0]
        }
    }
    
    // MARK: - Helper methods
    func getDuration(selectedIndex: Int) -> Int {
        switch selectedIndex {
        case 0:
            return 1
        case 1:
            return 2
        case 2:
            return 3
        case 3:
            return 4
        case 4:
            return 6
        case 5:
            return 12
        default:
            return 0
        }
    }
    
    func getpickerDataIndex(selectedDuration: String) -> Int {
        switch selectedDuration {
        case "1":
            return 0
        case "2":
            return 1
        case "3":
            return 2
        case "4":
            return 3
        case "6":
            return 4
        case "12":
            return 5
        default:
            return 0
        }
    }
}

// MARK: - TextFiels Delegate Methods
extension ReoccurTimeCollCell: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == txtOccuranceDuration {
            Global.setVibration()
            pickerView.dataSource = self
            pickerView.delegate = self
            txtOccuranceDuration.inputView = pickerView
        }
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField == txtOccuranceDuration {
            let dataIndex: Int = self.pickerView.selectedRow(inComponent: 0)
            self.txtOccuranceDuration.text = pickerData[dataIndex]
            self.delegate?.sendSelectedDuration(duration: getDuration(selectedIndex: dataIndex))
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}

// MARK: - PickerView Delegate And Datasource functions
extension ReoccurTimeCollCell: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.txtOccuranceDuration.text = pickerData[row]
        self.delegate?.sendSelectedDuration(duration: getDuration(selectedIndex: row))
    }
}
