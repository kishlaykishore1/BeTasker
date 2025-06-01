//
//  TemplateRegistrationViewModel.swift
//  teamAlerts
//
//  Created by B2Cvertical A++ on 16/05/24.
//

import Foundation
import UIKit

struct TemplateRegistrationModel {
    var program_schedules: String?
    var arrProgramSchedules: [programScheduleDataModel]?
    var id: Int? //1,
    var sort_order: Int? //1,
    var user_id: Int? //23,
    var title: String? //"Salon",
    var color_id: Int? //4,
    var color_code: String? //"47A3FF",
    var icon_id: Int? //23,
    var icon_file: String? //"https://easyac.55.agency/demo/images/icons/620fafc3-da07-4841-b8d5-bf2c129a7dc1.svg",
    var created: String? //"2024-05-09T13:20:46+00:00",
    var modified: String? //"2024-05-09T13:20:46+00:00"
    var description: String? //"Model 1",
    var is_photos: Bool? //true,
    var is_message: Bool? //true,
    var is_critical: Bool? //rue,
    var alarm_hour: String?
    var recurrence_days: String?
    var program_name: String?
    var program_members: String?
}

struct TemplateRegistrationViewModel {
private var data = TemplateRegistrationModel()
    init(data: TemplateRegistrationModel = TemplateRegistrationModel()) {
        self.data = data
    }
    
    var title: String {
        get {
            return data.title ?? ""
        }
        set {
            data.title = newValue
        }
    }
    var description: String {
        get {
            return data.description ?? ""
        }
        set {
            data.description = newValue
        }
    }
    var isPhotos: Bool {
        get {
            return data.is_photos ?? false
        }
        set {
            data.is_photos = newValue
        }
    }
    var isMessage: Bool {
        get {
            return data.is_message ?? false
        }
        set {
            data.is_message = newValue
        }
    }
    var isCritical: Bool {
        get {
            return data.is_critical ?? false
        }
        set {
            data.is_critical = newValue
        }
    }
    
    var programName: String {
        get {
            return data.program_name ?? ""
        }
        set {
            data.program_name = newValue
        }
    }
    var membserIds: String {
        get {
            return data.program_members ?? ""
        }
        set {
            data.program_members = newValue
        }
    }
    var arrMemberIds: [Int] {
        return (data.program_members ?? "").split(separator: ",").map({Int("\($0)") ?? 0})
    }
    var alarmHour: String {
        get {
            return data.alarm_hour ?? ""
        }
        set {
            data.alarm_hour = newValue
        }
    }
    var templateId: Int {
        get {
            return data.id ?? 0
        }
        set {
            data.id = newValue
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
    
    static func SetDataForEdit(data: TemplateViewModel) {
        HpGlobal.shared.programTemplateCreationData = TemplateRegistrationViewModel()
        HpGlobal.shared.programTemplateCreationData.templateId = data.id
        HpGlobal.shared.programTemplateCreationData.programName = data.programName
        HpGlobal.shared.programTemplateCreationData.alarmHour = data.alarmHourForEdit
        HpGlobal.shared.programTemplateCreationData.membserIds = data.memberIds
        HpGlobal.shared.programTemplateCreationData.recurrenceDays = data.recurrenceDays
        HpGlobal.shared.programTemplateCreationData.title = data.title
        HpGlobal.shared.programTemplateCreationData.description = data.description
        HpGlobal.shared.programTemplateCreationData.isPhotos = data.isPhotos
        HpGlobal.shared.programTemplateCreationData.isMessage = data.isMessage
        HpGlobal.shared.programTemplateCreationData.isCritical = data.isCritical
    }
}
