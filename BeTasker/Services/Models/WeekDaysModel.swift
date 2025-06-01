//
//  WeekDaysModel.swift
//  EasyAC
//
//  Created by 55 agency on 08/06/23.
//

import UIKit

struct WeekDaysModel {
    var weekDayPosition: Int?
    var weekDayName: String?
    var isSelected: Bool?
}

struct WeekDaysViewModel {
    private var data = WeekDaysModel()
    init(data: WeekDaysModel) {
        self.data = data
    }
    var weekDayPosition: Int {
        return data.weekDayPosition ?? 0
    }
    var weekDayName: String {
        return data.weekDayName ?? ""
    }
    var isSelected: Bool {
        get {
            return data.isSelected ?? false
        }
        set {
            data.isSelected = newValue
        }
    }
    static func GetWeekDays() -> [WeekDaysViewModel] {
        return [
            WeekDaysViewModel(data: WeekDaysModel(weekDayPosition: 1, weekDayName: "Lundi".localized, isSelected: false)),
            WeekDaysViewModel(data: WeekDaysModel(weekDayPosition: 2, weekDayName: "Mardi".localized, isSelected: false)),
            WeekDaysViewModel(data: WeekDaysModel(weekDayPosition: 3, weekDayName: "Mercredi".localized, isSelected: false)),
            WeekDaysViewModel(data: WeekDaysModel(weekDayPosition: 4, weekDayName: "Jeudi".localized, isSelected: false)),
            WeekDaysViewModel(data: WeekDaysModel(weekDayPosition: 5, weekDayName: "Vendredi".localized, isSelected: false)),
            WeekDaysViewModel(data: WeekDaysModel(weekDayPosition: 6, weekDayName: "Samedi".localized, isSelected: false)),
            WeekDaysViewModel(data: WeekDaysModel(weekDayPosition: 7, weekDayName: "Dimanche".localized, isSelected: false))
        ]
    }
}
