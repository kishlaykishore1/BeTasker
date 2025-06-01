//
//  ProgramScheduleRegistrationViewModel.swift
//  EasyAC
//
//  Created by 55 agency on 08/06/23.
//

import UIKit
struct ProgramScheduleRegistrationModel {
    var program_name: String?
    var room_ids: String?
    var alarm_hour: String?
    var program_id: Int?
    var recurrence_days: String?
    var program_schedules: String?
    var arrProgramSchedules: [programScheduleDataModel]?
}

struct ProgramScheduleRegistrationViewModel {
private var data = ProgramScheduleRegistrationModel()
    init(data: ProgramScheduleRegistrationModel) {
        self.data = data
    }
    init() {
        self.data = ProgramScheduleRegistrationModel()
    }
    var programName: String {
        get {
            return data.program_name ?? ""
        }
        set {
            data.program_name = newValue
        }
    }
    var roomIds: String {
        get {
            return data.room_ids ?? ""
        }
        set {
            data.room_ids = newValue
        }
    }
    var arrRoomIds: [Int] {
        return (data.room_ids ?? "").split(separator: ",").map({Int("\($0)") ?? 0})
    }
    var alarmHour: String {
        get {
            return data.alarm_hour ?? ""
        }
        set {
            data.alarm_hour = newValue
        }
    }
    var programId: Int {
        get {
            return data.program_id ?? 0
        }
        set {
            data.program_id = newValue
        }
    }
    var recurrenceDays: String {
        get {
            return data.recurrence_days ?? ""
        }
        set {
            data.recurrence_days = newValue
        }
    }

    var arrRecurrenceDays: [Int] {
        return recurrenceDays.split(separator: ",").map({Int("\($0)") ?? 0})
    }
    var programSchedules: String {
        get {
            return data.program_schedules ?? ""
        }
        set {
            data.program_schedules = newValue
        }
    }
    var arrProgramSchedulesData: [programScheduleDataModel] {
        get {
            return data.arrProgramSchedules ?? []
        }
        set {
            data.arrProgramSchedules = newValue
        }
    }
    var arrProgramSchedules: [programScheduleViewModel] {
        if let arr = data.arrProgramSchedules {
            return arr.map({programScheduleViewModel(data: $0)})
        }
        return []
    }
    
    static func SetDataForEdit(data: ProgramsDataViewModel) {
        HpGlobal.shared.programCreationData = ProgramScheduleRegistrationViewModel()
        HpGlobal.shared.programCreationData.programId = data.id
        HpGlobal.shared.programCreationData.programName = data.programName
        HpGlobal.shared.programCreationData.alarmHour = data.alarmHourForEdit
        HpGlobal.shared.programCreationData.arrProgramSchedulesData = data.arrProgramSchedulesData
        HpGlobal.shared.programCreationData.roomIds = data.roomIds
        HpGlobal.shared.programCreationData.recurrenceDays = data.recurrenceDays
    }
}
