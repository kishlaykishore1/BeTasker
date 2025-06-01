//
//  RoomRegistrationViewModel.swift
//  EasyAC
//
//  Created by 55 agency on 05/06/23.
//

import UIKit

struct RoomRegistrationModel {
    var roomId: Int?
    var iconId: Int?
    var roomName: String?
    var colorId: Int?
    var arrEquipmentIds: [Int]?
    var equipmentIds: String?
    
    var comfortColdMode: Int?
    var comfortHotMode: Int?
    
    var nightColdMode: Int?
    var nightHotMode: Int?
    
    var isEconomyColdMode: Bool? //1/0
    var isEconomyHotMode: Bool? //1/0
    
    var temperatureMode: String? //(Cold, Hot)
    
    var minTempColdMode: Int?
    var minTempHotMode: Int?
    
    var maxTempColdMode: Int?
    var maxTempHotMode: Int?
}

struct RoomRegistrationViewModel {
    private var data = RoomRegistrationModel()
    init(data: RoomRegistrationModel) {
        self.data = data
    }
    var roomId: Int {
        get {
        return data.roomId ?? 0
        }
        set {
            data.roomId = newValue
        }
    }
    var iconId: Int {
        get {
        return data.iconId ?? 0
        }
        set {
            data.iconId = newValue
        }
    }
    var roomName: String {
        get {
        return data.roomName ?? ""
        }
        set {
            data.roomName = newValue
        }
    }
    var colorId: Int {
        get {
        return data.colorId ?? 0
        }
        set {
            data.colorId = newValue
        }
    }
    var equipmentIds: String {
        get {
            return data.equipmentIds ?? ""
        }
        set {
            data.equipmentIds = newValue
        }
    }
    var arrEquipmentIds: [Int] {
        get {
            return data.arrEquipmentIds ?? []
        }
        set {
            data.arrEquipmentIds = newValue
        }
    }
    var comfortColdMode: Int {
        get {
        return data.comfortColdMode ?? 0
        }
        set {
            data.comfortColdMode = newValue
        }
    }
    var confortColdModeTempretureFormated: String {
        return "\(comfortColdMode)°"
    }
    var nightColdMode: Int {
        get {
        return data.nightColdMode ?? 0
        }
        set {
            data.nightColdMode = newValue
        }
    }
    var nightColdModeTempretureFormated: String {
        return "\(nightColdMode)°"
    }
    var isEconomyColdMode: Bool {
        get {
        return data.isEconomyColdMode ?? false
        }
        set {
            data.isEconomyColdMode = newValue
        }
    } //1/0
    var temperatureMode: String {
        get {
        return data.temperatureMode ?? ""
        }
        set {
            data.temperatureMode = newValue
        }
    } //(Cold, Hot)
    var minTempColdMode: Int {
        get {
        return data.minTempColdMode ?? 0
        }
        set {
            data.minTempColdMode = newValue
        }
    }
    var minTempColdModeFormated: String {
        return "\(minTempColdMode)°"
    }
    var maxTempColdMode: Int {
        get {
            return data.maxTempColdMode ?? 0
        }
        set {
            return data.maxTempColdMode = newValue
        }
    }
    var maxTempColdModeFormated: String {
        return "\(maxTempColdMode)°"
    }
    
    var comfortHotMode: Int {
        get {
        return data.comfortHotMode ?? 0
        }
        set {
            data.comfortHotMode = newValue
        }
    }
    var confortHotModeTempretureFormated: String {
        return "\(comfortHotMode)°"
    }
    var nightHotMode: Int {
        get {
        return data.nightHotMode ?? 0
        }
        set {
            data.nightHotMode = newValue
        }
    }
    var nightHotModeTempretureFormated: String {
        return "\(nightHotMode)°"
    }
    var isEconomyHotMode: Bool {
        get {
        return data.isEconomyHotMode ?? false
        }
        set {
            data.isEconomyHotMode = newValue
        }
    } //1/0
    
    var minTempHotMode: Int {
        get {
        return data.minTempHotMode ?? 0
        }
        set {
            data.minTempHotMode = newValue
        }
    }
    var minTempHotModeFormated: String {
        return "\(minTempHotMode)°"
    }
    var maxTempHotMode: Int {
        get {
            return data.maxTempHotMode ?? 0
        }
        set {
            return data.maxTempHotMode = newValue
        }
    }
    var maxTempHotModeFormated: String {
        return "\(maxTempHotMode)°"
    }
    
    static func SetDataForEdit(data: RoomDataViewModel) {
        HpGlobal.shared.roomCreationData = RoomRegistrationViewModel(data: RoomRegistrationModel())
        HpGlobal.shared.roomCreationData.roomId = data.id
        HpGlobal.shared.roomCreationData.iconId = data.iconId
        HpGlobal.shared.roomCreationData.roomName = data.roomName
        HpGlobal.shared.roomCreationData.colorId = data.colorId
        HpGlobal.shared.roomCreationData.arrEquipmentIds = data.equipments.map({$0.id})
        HpGlobal.shared.roomCreationData.equipmentIds = data.equipments.map({"\($0.id)"}).joined(separator: ",")
        HpGlobal.shared.roomCreationData.temperatureMode = data.temperatureMode
        
        HpGlobal.shared.roomCreationData.comfortColdMode = data.comfortColdMode
        HpGlobal.shared.roomCreationData.comfortHotMode = data.comfortHotMode
        HpGlobal.shared.roomCreationData.nightColdMode = data.nightColdMode
        HpGlobal.shared.roomCreationData.nightHotMode = data.nightHotMode
        HpGlobal.shared.roomCreationData.isEconomyColdMode = data.isEconomyColdMode
        HpGlobal.shared.roomCreationData.isEconomyHotMode = data.isEconomyHotMode
        HpGlobal.shared.roomCreationData.minTempColdMode = data.minTempColdMode
        HpGlobal.shared.roomCreationData.minTempHotMode = data.minTempHotMode
        HpGlobal.shared.roomCreationData.maxTempColdMode = data.maxTempColdMode
        HpGlobal.shared.roomCreationData.maxTempHotMode = data.maxTempHotMode
        
    }
}


