//
//  TemplatesResponseModel.swift
//  teamAlerts
//
//  Created by B2Cvertical A++ on 10/05/24.
//

import UIKit

struct TemplatesResponseModel: Codable {
    var template_list: [TemplateDataModel]?
}

struct TemplatesResponseViewModel {
    private var data = TemplatesResponseModel()
    init(data: TemplatesResponseModel = TemplatesResponseModel()) {
        self.data = data
    }
    var arrTemplates: [TemplateViewModel] {
        if let arr = data.template_list {
            return arr.map({TemplateViewModel(data: $0)})
        }
        return []
    }
}

struct TemplateDataModel: Codable {
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
    var is_active: Bool?
    var group_ids: String?
    var isSelected: Bool?
}

struct TemplateViewModel {
    private var data = TemplateDataModel()
    init(data: TemplateDataModel = TemplateDataModel()) {
        self.data = data
    }
    var id: Int {
        return data.id ?? 0
    }
    var arrGropIds: [Int] {
        return (data.group_ids ?? "").split(separator: ",").map({Int("\($0)") ?? 0})
    }
    var sortOrder: Int {
        return data.sort_order ?? 0
    }
    var userId: Int {
        return data.user_id ?? 0
    }
    var isActive: Bool {
        get {
            return data.is_active ?? false
        }
        set {
            data.is_active = newValue
        }
    }
    var title: String {
        get {
            return data.title ?? ""
        }
        set {
            data.title = newValue
        }
    }
    var colorId: Int {
        get {
            return data.color_id ?? 0
        }
        set {
            data.color_id = newValue
        }
    }
    var colorCode: String {
        get {
            return data.color_code ?? ""
        }
        set {
            data.color_code = newValue
        }
    }
    var colorValue: UIColor {
        return UIColor(hexString: colorCode)
    }
    var iconId: Int {
        get {
            return data.icon_id ?? 0
        }
        set {
            data.icon_id = newValue
        }
    }
    var iconURL: URL? {
        return data.icon_file?.makeUrl()
    }
    var created: String {
        return data.created ?? ""
    }
    var modified: String {
        return data.modified ?? ""
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
    var isSelected: Bool {
        get {
            return data.isSelected ?? false
        }
        set {
            data.isSelected = newValue
        }
    }
    
    var alarmHour: String {
        let dt = Global.GetFormattedDate(dateString: data.alarm_hour ?? "", currentFormate: "HH:mm:ss", outputFormate: "HH'h'mm", isInputUTC: true, isOutputUTC: false).dateString
        return dt ?? ""
    }
    var alarmHourForEdit: String {
        let dt = Global.GetFormattedDate(dateString: data.alarm_hour ?? "", currentFormate: "HH:mm:ss", outputFormate: "HH:mm", isInputUTC: true, isOutputUTC: false).dateString
        return dt ?? ""
    }
    var programName: String {
        return data.program_name ?? ""
    }
    
    var memberIds: String {
        return data.program_members ?? ""
    }
    
    var arrMemberIds: [Int] {
        return memberIds.split(separator: ",").map({Int("\($0)") ?? 0})
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
    
    static func getAllTemplates(sender: UIViewController, showLoader: Bool, completion: @escaping(_ arrTemplates: [TemplateViewModel])->()) {
        let params: [String: Any] = [
            "lc": Constants.lc
        ]
        DispatchQueue.main.async {
            if showLoader {
                Global.showLoadingSpinner(sender: sender.view)
            }
        }
        HpAPI.allTemplates.DataAPI(params: params, shouldShowError: false, shouldShowSuccess: false, key: "data") { (response: Result<TemplatesResponseModel, Error>) in
            DispatchQueue.main.async {
                Global.dismissLoadingSpinner(sender.view)
                switch response {
                case .success(let res):
                    let arr = TemplatesResponseViewModel(data: res).arrTemplates
                    completion(arr)
                    break
                case .failure(_):
                    completion([])
                    break
                }
            }
        }
    }
    
    static func getMyTemplates(sender: UIViewController, showLoader: Bool, completion: @escaping(_ arrTemplates: [TemplateViewModel])->()) {
        let params: [String: Any] = [
            "lc": Constants.lc
        ]
        DispatchQueue.main.async {
            if showLoader {
                Global.showLoadingSpinner(sender: sender.view)
            }
        }
        HpAPI.myTemplates.DataAPI(params: params, shouldShowError: false, shouldShowSuccess: false, key: "data") { (response: Result<TemplatesResponseModel, Error>) in
            DispatchQueue.main.async {
                Global.dismissLoadingSpinner(sender.view)
                switch response {
                case .success(let res):
                    let arr = TemplatesResponseViewModel(data: res).arrTemplates
                    completion(arr)
                    break
                case .failure(_):
                    completion([])
                    break
                }
            }
        }
    }
    
    static func getMyProgramTemplates(sender: UIViewController, showLoader: Bool, completion: @escaping(_ arrTemplates: [TemplateViewModel])->()) {
        let params: [String: Any] = [
            "lc": Constants.lc
        ]
        DispatchQueue.main.async {
            if showLoader {
                Global.showLoadingSpinner(sender: sender.view)
            }
        }
        HpAPI.myProgramTemplates.DataAPI(params: params, shouldShowError: false, shouldShowSuccess: false, key: "data") { (response: Result<TemplatesResponseModel, Error>) in
            DispatchQueue.main.async {
                Global.dismissLoadingSpinner(sender.view)
                switch response {
                case .success(let res):
                    let arr = TemplatesResponseViewModel(data: res).arrTemplates
                    completion(arr)
                    break
                case .failure(_):
                    completion([])
                    break
                }
            }
        }
    }
    
    static func addEditTemplate(params: [String: Any], sender: UIViewController, showLoader: Bool, completion: @escaping(_ done: Bool)->()) {
        DispatchQueue.main.async {
            if showLoader {
                Global.showLoadingSpinner(sender: sender.view)
            }
        }
        HpAPI.addEditTemplate.DataAPI(params: params, shouldShowError: false, shouldShowSuccess: false, key: nil) { (response: Result<GeneralModel, Error>) in
            DispatchQueue.main.async {
                Global.dismissLoadingSpinner(sender.view)
                switch response {
                case .success(_):
                    completion(true)
                    break
                case .failure(_):
                    completion(false)
                    break
                }
            }
        }
    }
    
    static func deleteTemplate(templateId: Int, sender: UIViewController, showLoader: Bool, completion: @escaping(_ done: Bool)->()) {
        let params: [String: Any] = [
            "lc": Constants.lc,
            "template_id": templateId
        ]
        DispatchQueue.main.async {
            if showLoader {
                Global.showLoadingSpinner(sender: sender.view)
            }
        }
        HpAPI.deleteTemplate.DataAPI(params: params, shouldShowError: false, shouldShowSuccess: false, key: nil) { (response: Result<GeneralModel, Error>) in
            DispatchQueue.main.async {
                Global.dismissLoadingSpinner(sender.view)
                switch response {
                case .success(_):
                    completion(true)
                    break
                case .failure(_):
                    completion(false)
                    break
                }
            }
        }
    }
    
    static func reorderTemplates(templateIds: String, sender: UIViewController, showLoader: Bool, completion: @escaping(_ done: Bool)->()) {
        let params: [String: Any] = [
            "lc": Constants.lc,
            "template_ids": templateIds
        ]
        DispatchQueue.main.async {
            if showLoader {
                Global.showLoadingSpinner(sender: sender.view)
            }
        }
        HpAPI.templateSortOrder.DataAPI(params: params, shouldShowError: false, shouldShowSuccess: false, key: nil) { (response: Result<GeneralModel, Error>) in
            DispatchQueue.main.async {
                Global.dismissLoadingSpinner(sender.view)
                switch response {
                case .success(_):
                    completion(true)
                    break
                case .failure(_):
                    completion(false)
                    break
                }
            }
        }
    }
    
    static func templateProgramIsActive(templateId: Int, isActive: Bool, sender: UIViewController, showLoader: Bool, completion: @escaping(_ done: Bool)->()) {
        let params: [String: Any] = [
            "lc": Constants.lc,
            "template_id": templateId,
            "is_active": isActive ? 1 : 0
        ]
        DispatchQueue.main.async {
            if showLoader {
                Global.showLoadingSpinner(sender: sender.view)
            }
        }
        HpAPI.templateProgramIsActive.DataAPI(params: params, shouldShowError: false, shouldShowSuccess: false, key: nil) { (response: Result<GeneralModel, Error>) in
            DispatchQueue.main.async {
                Global.dismissLoadingSpinner(sender.view)
                switch response {
                case .success(_):
                    completion(true)
                    break
                case .failure(_):
                    completion(false)
                    break
                }
            }
        }
    }
    
}

