//
//  RoomViewModel.swift
//  EasyAC
//
//  Created by 55 agency on 07/06/23.
//

import UIKit
import SDWebImage
import SDWebImageSVGKitPlugin

struct RoomModel: Codable {
    var room_data: [RoomDataModel]?
    var room_with_out_equipment: [RoomDataModel]?
    var room_settings: RoomDataModel?
    var system_settings: RoomDataModel?
}

struct RoomDataModel: Codable {
    var id: Int? // 9,
    var user_id: Int? // 21,
    var icon_id: Int? // 4,
    var color_id: Int? // 2,
    var room_icon: String? // "https://easyac.55.agency/demo/images/icons/57defa4d-7405-4290-b937-e5ab616c08ce.svg",
    var room_name: String? // "Salon",
    var room_color: String? // "D093FF",
    var equipments: [EquipmentsDataModel]?
    var temperature_mode: String? //"Hot"
    
    var comfort_cold_mode, comfort_hot_mode: Int?
    var night_cold_mode, night_hot_mode: Int?
    var is_economy_cold_mode, is_economy_hot_mode: Bool?
    var min_temp_cold_mode, min_temp_hot_mode: Int?
    var max_temp_cold_mode, max_temp_hot_mode: Int?
    
    var created: String? //"2023-05-09T12:34:30+00:00",
    var modified: String? //"2023-05-09T12:34:30+00:00",
    var is_power: Bool? //true,
    var fan_power: Int? //3,
    var is_heating: Bool? //false,
    var device_mode: String? //"Night",
    var cooling_mode: String? //"AirConditioner",
    var is_ventilation: Bool? //false,
    var is_automatic_mode: Bool? //false,
    var is_air_conditioner: Bool? //true,
    var is_temperature_mode: Bool? //false,
    var is_dehumidification: Bool? //false
    var temperature: Int?
    
    var isSelected: Bool?
}

struct RoomDataViewModel {
    private var data = RoomDataModel()
    init(data: RoomDataModel) {
        self.data = data
    }
    var id: Int {
        get {
        return data.id ?? 0
        }
        set {
            data.id = newValue
        }
    }
    var userId: Int {
        return data.user_id ?? 0
    }
    var iconId: Int {
        return data.icon_id ?? 0
    }
    var colorId: Int {
        return data.color_id ?? 0
    }
    var roomIconURL: URL? {
        return data.room_icon?.makeUrl()
    }
    
    var roomName: String {
        return data.room_name ?? ""
    }
    var roomColor: UIColor {
        return UIColor(hexString: data.room_color ?? "")
    }
    var equipments: [EquipmentsDataViewModel] {
        if let arr = data.equipments {
            return arr.map({EquipmentsDataViewModel(data: $0)})
        }
        return []
    }
   
    var temperatureMode: String {
        return data.temperature_mode ?? "Cold"
    }
    
    var comfortColdMode: Int {
        return data.comfort_cold_mode ?? 0
    }
    var comfortHotMode: Int {
        return data.comfort_hot_mode ?? 0
    }
    var nightColdMode: Int {
        return data.night_cold_mode ?? 0
    }
    var nightHotMode: Int {
        return data.night_hot_mode ?? 0
    }
    var isEconomyColdMode: Bool {
        return data.is_economy_cold_mode ?? false
    }
    var isEconomyHotMode: Bool {
        return data.is_economy_hot_mode ?? false
    }
    var minTempColdMode: Int {
        return data.min_temp_cold_mode ?? 0
    }
    var minTempHotMode: Int {
        return data.min_temp_hot_mode ?? 0
    }
    var maxTempColdMode: Int {
        return data.max_temp_cold_mode ?? 0
    }
    var maxTempHotMode: Int {
        return data.max_temp_hot_mode ?? 0
    }
    
    //Room_settings
    var isPower: Bool {
        get {
            return data.is_power ?? false
        }
        set {
            data.is_power = newValue
        }
    }
    var fanPower: Int {
        get {
            return data.fan_power ?? 0
        }
        set {
            data.fan_power = newValue
        }
    }
    var isHeating: Bool {
        get {
            return data.is_heating ?? false
        }
        set {
            data.is_heating = newValue
        }
    }
    var deviceMode: String {
        get {
            return data.device_mode ?? ""
        }
        set {
            data.device_mode = newValue
        }
    }
    var coolingMode: String {
        get {
            return data.cooling_mode ?? ""
        }
        set {
            data.cooling_mode = newValue
        }
    }
    var isVentilation: Bool {
        get {
            return data.is_ventilation ?? false
        }
        set {
            data.is_ventilation = newValue
        }
    }
    var isAutomaticMode: Bool {
        get {
            return data.is_automatic_mode ?? false
        }
        set {
            data.is_automatic_mode = newValue
        }
    }
    var isAirConditioner: Bool {
        get {
            return data.is_air_conditioner ?? false
        }
        set {
            data.is_air_conditioner = newValue
        }
    }
    var isTemperature_mode: Bool {
        get {
            return data.is_temperature_mode ?? false
        }
        set {
            data.is_temperature_mode = newValue
        }
    }
    var isDehumidification: Bool {
        get {
            return data.is_dehumidification ?? false
        }
        set {
            data.is_dehumidification = newValue
        }
    }
    var temperature: Int {
        get {
            return data.temperature ?? 0
        }
        set {
            data.temperature = newValue
        }
    }
    //
    
    var isSelected: Bool {
        get {
            return data.isSelected ?? false
        }
        set {
            data.isSelected = newValue
        }
    }
}

struct RoomViewModel {
private var data = RoomModel()
    init(data: RoomModel) {
        self.data = data
    }
    var arrRooms: [RoomDataViewModel] {
        if let arr = data.room_data {
            return arr.map({RoomDataViewModel(data: $0)})
        }
        return []
    }
    var arrRoomsWithoutEquipments: [RoomDataViewModel] {
        if let arr = data.room_with_out_equipment {
            return arr.map({RoomDataViewModel(data: $0)})
        }
        return []
    }
    var roomSettings: RoomDataViewModel? {
        if let settings = data.room_settings {
            return RoomDataViewModel(data: settings)
        }
        return nil
    }
    var generalSettings: RoomDataViewModel? {
        if let settings = data.system_settings {
            return RoomDataViewModel(data: settings)
        }
        return nil
    }
    
  static func GetRoomList(sender: UIViewController, showLoader: Bool, completion: @escaping(_ arrRooms: [RoomDataViewModel])->()) {
       DispatchQueue.main.async {
           if showLoader {
               Global.showLoadingSpinner(sender: sender.view)
           }
       }
        HpAPI.myRooms.DataAPI(params: [:], shouldShowError: false, shouldShowSuccess: false, key: "data") { (response: Result<RoomModel, Error>) in
            DispatchQueue.main.async {
                Global.dismissLoadingSpinner(sender.view)
                switch response {
                case .success(let res):
                    let arrData = RoomViewModel(data: res).arrRooms
                    completion(arrData)
                    break
                case .failure(_):
                    completion([])
                    break
                }
            }
        }
    }
    
    static func GetRoomListWithoutEquipments(sender: UIViewController, showLoader: Bool, completion: @escaping(_ arrRooms: [RoomDataViewModel])->()) {
         DispatchQueue.main.async {
             if showLoader {
                 Global.showLoadingSpinner(sender: sender.view)
             }
         }
          HpAPI.roomWithoutEquipmentList.DataAPI(params: [:], shouldShowError: false, shouldShowSuccess: false, key: "data") { (response: Result<RoomModel, Error>) in
              DispatchQueue.main.async {
                  Global.dismissLoadingSpinner(sender.view)
                  switch response {
                  case .success(let res):
                      let arrData = RoomViewModel(data: res).arrRoomsWithoutEquipments
                      completion(arrData)
                      break
                  case .failure(_):
                      completion([])
                      break
                  }
              }
          }
      }
    
    static func DeleteRoom(roomId: Int, completion: @escaping(_ done: Bool)->()) {
        let params: [String: Any] = [
            "lc": Constants.lc,
            "room_id": roomId
        ]
        HpAPI.roomsDelete.DataAPI(params: params, shouldShowError: true, shouldShowSuccess: true, key: nil) { (response: Result<GeneralModel, Error>) in
            DispatchQueue.main.async {
                Global.dismissLoadingSpinner()
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
    
    static func GetRoomSettings(sender: UIViewController, id: Int, completion: @escaping(_ roomSettings: RoomDataViewModel?)->()) {
        let params: [String: Any] = [
            "lc": Constants.lc,
            "room_id": id
        ]
        DispatchQueue.main.async {
            Global.showLoadingSpinner(sender: sender.view)
        }
        HpAPI.roomSettings.DataAPI(params: params, shouldShowError: false, shouldShowSuccess: false, key: "data") { (response: Result<RoomModel, Error>) in
            DispatchQueue.main.async {
                Global.dismissLoadingSpinner(sender.view)
                switch response {
                case .success(let res):
                    if let data = res.system_settings {
                        completion(RoomDataViewModel(data: data))
                    } else if let data = res.room_settings {
                        completion(RoomDataViewModel(data: data))
                    } else  {
                        completion(nil)
                    }
                    break
                case .failure(_):
                    completion(nil)
                    break
                }
            }
        }
    }
    
    static func GetSystemSettings(sender: UIViewController, id: Int, completion: @escaping(_ roomSettings: RoomDataViewModel?)->()) {
        let params: [String: Any] = [
            "lc": Constants.lc,
            "room_id": id
        ]
        DispatchQueue.main.async {
            Global.showLoadingSpinner(sender: sender.view)
        }
        HpAPI.getSystemSettings.DataAPI(params: params, shouldShowError: false, shouldShowSuccess: false, key: "data") { (response: Result<RoomModel, Error>) in
            DispatchQueue.main.async {
                Global.dismissLoadingSpinner(sender.view)
                switch response {
                case .success(let res):
                    if let data = res.system_settings {
                        completion(RoomDataViewModel(data: data))
                    } else {
                        completion(nil)
                    }
                    break
                case .failure(_):
                    completion(nil)
                    break
                }
            }
        }
    }
    
    static func reorderPlaces(roomIds: String, sender: UIViewController, showLoader: Bool, completion: @escaping(_ done: Bool)->()) {
        let params: [String: Any] = [
            "lc": Constants.lc,
            "position": roomIds
        ]
        DispatchQueue.main.async {
            if showLoader {
                Global.showLoadingSpinner(sender: sender.view)
            }
        }
        HpAPI.repositionRooms.DataAPI(params: params, shouldShowError: false, shouldShowSuccess: false, key: nil) { (response: Result<GeneralModel, Error>) in
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
