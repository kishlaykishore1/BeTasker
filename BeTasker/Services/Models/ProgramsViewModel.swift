//
//  ProgramsViewModel.swift
//  EasyAC
//
//  Created by 55 agency on 08/06/23.
//

import UIKit

struct ProgramsModel: Codable {
    var program_data: [ProgramsDataModel]?
}

struct ProgramsDataModel: Codable {
    var id: Int? //1,
    var user_id: Int? //23,
    var created: String? //"2023-06-08T11:25:03+00:00",
    var alarm_hour: String? //"09:30:00",
    var room_ids: String?
    var recurrence_days: String?
    var program_name: String? //"Dimanche Zen"
    var program_schedules: [programScheduleDataModel]?
}

struct programScheduleDataModel: Codable {
    var id: Int? //10,
    var program_id: Int? //7,
    var temperature: Int? //"18",
    var ventilation: Int? //"60",
    var program_schedule_select_type: Int? //1
    var program_schedule_name: String?
}

struct programScheduleViewModel {
    private var data = programScheduleDataModel()
    init(data: programScheduleDataModel) {
        self.data = data
    }
    var id: Int {
        return data.id ?? 0
    }
    var programId: Int {
        return data.program_id ?? 0
    }
    var temperature: Int {
        return data.temperature ?? 0
    }
    var ventilation: Int {
        return data.ventilation ?? 0
    }
    var programScheduleSelectType: Int {
        return data.program_schedule_select_type ?? 0
    }
    
    var programScheduleName: ProgramScheduleTypesViewModel {
        switch programScheduleSelectType {
        case 1:
            return ProgramScheduleTypesViewModel(data: ProgramScheduleTypesModel(program_schedule_select_type: 1, program_schedule_name: "Confort".localized, temperature: temperature, ventilation: ventilation))
        case 2:
            return ProgramScheduleTypesViewModel(data: ProgramScheduleTypesModel(program_schedule_select_type: 2, program_schedule_name: "Mode nuit".localized, temperature: temperature, ventilation: ventilation))
        default:
            return ProgramScheduleTypesViewModel(data: ProgramScheduleTypesModel(program_schedule_select_type: 3, program_schedule_name: "Mode prog.".localized, temperature: temperature, ventilation: ventilation))
        }
    }
}

struct ProgramsDataViewModel {
    private var data = ProgramsDataModel()
    init(data: ProgramsDataModel) {
        self.data = data
    }
    var id: Int {
        return data.id ?? 0
    }
    var userId: Int {
        return data.user_id ?? 0
    }
    var created: String {
        return data.created ?? ""
    }
    var alarmHour: String {
        let dt = Global.GetFormattedDate(dateString: data.alarm_hour ?? "", currentFormate: "HH:mm:ss", outputFormate: "HH'h'mm", isInputUTC: true, isOutputUTC: true).dateString
        return dt ?? ""
    }
    var alarmHourForEdit: String {
        let dt = Global.GetFormattedDate(dateString: data.alarm_hour ?? "", currentFormate: "HH:mm:ss", outputFormate: "HH:mm", isInputUTC: true, isOutputUTC: true).dateString
        return dt ?? ""
    }
    var programName: String {
        return data.program_name ?? ""
    }
    var roomIds: String {
        return data.room_ids ?? ""
    }
    var arrRoomIds: [Int] {
        return (data.room_ids ?? "").split(separator: ",").map({Int("\($0)") ?? 0})
    }
    var recurrenceDays: String {
        return data.recurrence_days ?? ""
    }
    var arrRecurrenceDays: [String] {
        return (data.recurrence_days ?? "").split(separator: ",").map({"\($0)"})
    }
    var arrRecurrenceDaysInteger: [Int] {
        return recurrenceDays.split(separator: ",").map({Int("\($0)") ?? 0})
    }
    
    var recurrenceDaysFormated: String {
        /*
         "Lundi"
         "Mardi"
         "Mercredi"
         "Jeudi"
         "Vendredi"
         "Samedi"
         "Dimanche"
         If only 1 day, then full day. Ex “Lundi”, "Mardi", "Mercredi"

         If 2 to 6 day, then each letter. Ex “L,M,J,V”

         If all days then “Tous les jours”

         If saturday/sunday only “Week-end”

         If all week-day“En semaine”
         */
        if arrRecurrenceDaysInteger.count == 7 {
            return "Tous les jours".localized
        }
        var arrDayName = WeekDaysViewModel.GetWeekDays()
            for i in 0..<arrRecurrenceDays.count {
                if let idx = arrDayName.firstIndex(where: {$0.weekDayPosition == arrRecurrenceDaysInteger[i]}) {
                    arrDayName[idx].isSelected = true
                }
            }
        let arrWeekDays = arrDayName.filter({$0.isSelected == true})
        if arrWeekDays.count == 1 {
            if arrRecurrenceDaysInteger[0] == 6 || arrRecurrenceDaysInteger[0] == 7 {
                return "Week-end"
            }
            return arrWeekDays[0].weekDayName
        } else {
            if arrWeekDays.count == 2 {
                if arrRecurrenceDaysInteger[0] == 6 && arrRecurrenceDaysInteger[1] == 7 {
                    return "Week-end"
                }
            } else if arrWeekDays.count == 5 && arrRecurrenceDaysInteger.contains(6) == false && arrRecurrenceDaysInteger.contains(7) == false {
                return "En semaine".localized
            }
            return arrWeekDays.map({$0.weekDayName.prefix(3)}).joined(separator: ", ")
        }
    }
    
    var arrProgramSchedules: [programScheduleViewModel] {
        if let arr = data.program_schedules {
            return arr.map({programScheduleViewModel(data: $0)})
        }
        return []
    }
    var arrProgramSchedulesData: [programScheduleDataModel] {
        if let arr = data.program_schedules {
            return arr
        }
        return []
    }
}

struct ProgramsViewModel {
private var data = ProgramsModel()
    init(data: ProgramsModel) {
        self.data = data
    }
    var arrPrograms: [ProgramsDataViewModel] {
        if let arr = data.program_data {
            return arr.map({ProgramsDataViewModel(data: $0)})
        }
        return []
    }
    static func GetProgramList(shouldShowLoader: Bool, sender: UIViewController, completion: @escaping(_ arrPrograms: [ProgramsDataViewModel])->()) {
        DispatchQueue.main.async {
            if shouldShowLoader {
            Global.showLoadingSpinner(sender: sender.view)
            }
        }
        HpAPI.myPrograms.DataAPI(params: [:], shouldShowError: false, shouldShowSuccess: false, key: "data") { (response: Result<ProgramsModel, Error>) in
            DispatchQueue.main.async {
                Global.dismissLoadingSpinner(sender.view)
                switch response {
                case .success(let res):
                    let data = ProgramsViewModel(data: res).arrPrograms
                    completion(data)
                    break
                case .failure(_):
                    completion([])
                    break
                }
            }
        }
    }
}
