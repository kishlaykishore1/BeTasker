//
//  ProgramScheduleTypesViewModel.swift
//  EasyAC
//
//  Created by 55 agency on 08/06/23.
//

import UIKit

struct ProgramScheduleTypesModel: Codable {
    var program_schedule_select_type: Int?
    var program_schedule_name: String?
    var temperature: Int?
    var ventilation: Int?
}

struct ProgramScheduleTypesViewModel {
    private var data = ProgramScheduleTypesModel()
    init(data: ProgramScheduleTypesModel) {
        self.data = data
    }
    
    var programScheduleId: Int{
        get {
            return data.program_schedule_select_type ?? 0
        }
        set {
            data.program_schedule_select_type = newValue
        }
    }
    var programScheduleName: String {
        get {
            return data.program_schedule_name ?? ""
        }
        set {
            data.program_schedule_name = newValue
        }
    }
    var temperature: Int{
        get {
            return data.temperature ?? 0
        }
        set {
            data.temperature = newValue
        }
    }
    var temperatureFormated: String {
        return "\(temperature)°"
    }
    var ventilation: Int{
        get {
            return data.ventilation ?? 0
        }
        set {
            data.ventilation = newValue
        }
    }
    var ventilationFormatted: String {
        return "\(ventilation)%"
    }
    
    static func GetProgramScheduleTypes() -> [ProgramScheduleTypesViewModel] {
        return [
            ProgramScheduleTypesViewModel(data: ProgramScheduleTypesModel(program_schedule_select_type: 1, program_schedule_name: "Confort".localized, temperature: 23, ventilation: 70)),
            ProgramScheduleTypesViewModel(data: ProgramScheduleTypesModel(program_schedule_select_type: 2, program_schedule_name: "Mode nuit".localized, temperature: 23, ventilation: 70)),
            ProgramScheduleTypesViewModel(data: ProgramScheduleTypesModel(program_schedule_select_type: 3, program_schedule_name: "Mode prog.".localized, temperature: 23, ventilation: 70))
        ]
    }
    
    static func getJsonString(arrActions: [ActionModel]) -> String {
        var arrSchedules = [ProgramScheduleTypesModel]()
        for i in 0..<arrActions.count {
            var obj = ProgramScheduleTypesModel()
            obj.program_schedule_name = arrActions[i].actionName
            obj.program_schedule_select_type = arrActions[i].actionId
            obj.temperature = arrActions[i].temperature
            obj.ventilation = arrActions[i].ventilation
            arrSchedules.append(obj)
        }
        return Global.encodedDataToJSONString(data: arrSchedules)
    }
    
}

struct ActionModel {
    var actionId: Int?
    var actionName: String?
    var actionImg: UIImage?
    var tempVal: String?
    var ventVal: String?
    var temperature: Int?
    var ventilation: Int?
}
