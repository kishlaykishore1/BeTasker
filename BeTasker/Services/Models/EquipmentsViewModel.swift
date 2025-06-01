//
//  EquipmentsViewModel.swift
//  EasyAC
//
//  Created by 55 agency on 07/06/23.
//

import UIKit
struct EquipmentsModel: Codable {
    var equipment_data: [EquipmentsDataModel]?
}

struct EquipmentsDataModel: Codable {
    var id: Int?
    var detect_type: String?
    var device_uuid: String?
    var short_uuid: String?
    var device_name: String?
    var user_id: Int? //19,
    var created: String? //"2023-06-07T10:00:11+00:00",
    
    var room_id: Int?//1
    var temperature: Int?//10
    var equipment_id: Int?//13
    var file_name: String?//file
    
    var room_icon: String?
    var room_name: String?
    var room_color: String?
    
    var isSelected: Bool?
}

struct EquipmentsDataViewModel {
    var data = EquipmentsDataModel()
    init(data: EquipmentsDataModel) {
        self.data = data
    }
    var id: Int {
        return data.id ?? 0
    }
    var detectType: String {
        return data.detect_type ?? ""
    }
    var deviceUUID: String {
        return data.device_uuid ?? ""
    }
    var shortUUID: String {
        return data.short_uuid ?? ""
    }
    var deviceName: String {
        return data.device_name ?? ""
    }
    var userId: Int {
        return data.user_id ?? 0
    }
    var roomId: Int {
        return data.room_id ?? 0
    }
    var temperature: Int {
        return data.temperature ?? 0
    }
    var temperatureFormated: String {
        return temperature > 0 ? "+\(temperature)°" : "\(temperature)°"
    }
    var equipment_id: Int {
        return data.equipment_id ?? 0
    }
    var fileURL: URL? {
        return data.file_name?.makeUrl()
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
    var isSelected: Bool {
        get {
            return data.isSelected ?? false
        }
        set {
            data.isSelected = newValue
        }
    }
}

class EquipmentsViewModel: NSObject {
 private var data = EquipmentsModel()
    init(data: EquipmentsModel) {
        self.data = data
    }
    var arrEquipments: [EquipmentsDataViewModel] {
        if let arr = data.equipment_data {
            return arr.map({EquipmentsDataViewModel(data: $0)})
        }
        return []
    }
    
    
    static func GetEquipmentsList(sender: UIViewController, shouldShowLoader: Bool, completion: @escaping(_ arrEquipments: [EquipmentsDataViewModel])->()) {
        let params: [String: Any] = [
            "lc": Constants.lc
        ]
        DispatchQueue.main.async {
            if shouldShowLoader {
            Global.showLoadingSpinner(sender: sender.view)
            }
        }
        HpAPI.myEquipments.DataAPI(params: params, shouldShowError: false, shouldShowSuccess: false, key: "data") { (response: Result<EquipmentsModel, Error>) in
            DispatchQueue.main.async {
                Global.dismissLoadingSpinner(sender.view)
                switch response {
                case .success(let res):
                    let data = EquipmentsViewModel(data: res)
                    completion(data.arrEquipments)
                    break
                case .failure(_):
                    completion([])
                    break
                }
            }
        }
    }
    
    static func SaveEquipments(sender: UIViewController, data: String, completion: @escaping(_ done: Bool)->()) {
        let params: [String: Any] = [
            "lc": Constants.lc,
            "device_data": data
        ]
        DispatchQueue.main.async {
            Global.showLoadingSpinner(sender: sender.view)
        }
        HpAPI.equipmentsCreate.DataAPI(params: params, shouldShowError: true, shouldShowSuccess: false, key: nil) { (response: Result<GeneralModel, Error>) in
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
    
    static func DeleteEquipment(sender: UIViewController, id: Int, completion: @escaping(_ done: Bool)->()) {
        let params: [String: Any] = [
            "lc": Constants.lc,
            "equipment_id": id
        ]
        DispatchQueue.main.async {
            Global.showLoadingSpinner(sender: sender.view)
        }
        HpAPI.equipmentsDelete.DataAPI(params: params, shouldShowError: true, shouldShowSuccess: true, key: nil) { (response: Result<GeneralModel, Error>) in
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
    
}
