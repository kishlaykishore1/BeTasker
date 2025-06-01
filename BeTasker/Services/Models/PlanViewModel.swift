//
//  PlanViewModel.swift
//  EasyAC
//
//  Created by 55 agency on 09/06/23.
//

import UIKit

struct PlanModel: Codable {
    var plan_data: PlanDataModel?
}

struct PlanDataModel: Codable {
    var id: Int? //5,
    var user_id: Int? //23,
    var created: String? //"2023-06-09T07:48:01+00:00",
    var modified: String? //"2023-06-09T07:48:01+00:00",
    var file_name: String? //"https://easyac.55.agency/demo/images/plans/c3df9365-feee-49f0-bcc7-d7306cc93f2d.jpg",
    var canvas_width: Float? //0,
    var canvas_height: Float? //0,
    var plan_icons: [PlanIconModel]? //[
}

struct PlanDataViewModel {
    private var data = PlanDataModel()
    init(data: PlanDataModel) {
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
    var modified: String {
        return data.modified ?? ""
    }
    var fileURL: URL? {
        return data.file_name?.makeUrl()
    }
    var canvasWidth: CGFloat {
        return CGFloat(data.canvas_width ?? 0)
    }
    var canvasHeight: CGFloat {
        return CGFloat(data.canvas_height ?? 0)
    }
    var arrPlanIcons: [PlanIconViewModel] {
        if let arr = data.plan_icons {
            return arr.map({PlanIconViewModel(data: $0)})
        }
        return []
    }
}

struct PlanIconModel: Codable {
    var id: Int? //13,
    var user_id: Int? //23,
    var plan_id: Int? //5,
    var room_id: Int? //1,
    var icon_id: Int?
    var room_name: String?
    var room_color: String?
    var icon_name: String? //"check_box",
    var file_name: String? //"https://easyac.55.agency/demo/images/icons/27a1716e-1ea9-4639-b1c0-b360d53e6f48.svg",
    var icon_x_position: Float? //2010,
    var icon_y_position: Float? //2410
}

struct PlanIconViewModel {
    private var data = PlanIconModel()
    init(data: PlanIconModel) {
        self.data = data
    }
    var id: Int {
        return data.id ?? 0
    }
    var userId: Int {
        return data.user_id ?? 0
    }
    var planId: Int {
        return data.plan_id ?? 0
    }
    var roomId: Int {
        return data.room_id ?? 0
    }
    var iconId: Int {
        return data.icon_id ?? 0
    }
    var roomName: String {
        return data.room_name ?? ""
    }
    var roomColor: UIColor {
        return UIColor(hexString: data.room_color ?? "")
    }
    var roomColorName: String {
        return data.room_color ?? ""
    }
    var iconName: String {
        return data.icon_name ?? ""
    }
    var fileURL: URL? {
        return data.file_name?.makeUrl()
    }
    var xPosition: CGFloat {
        return CGFloat(data.icon_x_position ?? 0)
    }
    var yPosition: CGFloat {
        return CGFloat(data.icon_y_position ?? 0)
    }
}

struct PlanViewModel {
private var data = PlanModel()
    init(data: PlanModel) {
        self.data = data
    }
    var planData: PlanDataViewModel {
        if let plan = data.plan_data {
            return PlanDataViewModel(data: plan)
        }
        return PlanDataViewModel(data: PlanDataModel())
    }
    static func GetPlanData(sender: UIViewController, completion: @escaping(_ data: PlanDataViewModel?)->()) {
        let params: [String: Any] = [
            "lc": Constants.lc
        ]
        HpAPI.myPlans.DataAPI(params: params, shouldShowError: false, shouldShowSuccess: false, key: "data") { (response: Result<PlanModel, Error>) in
            DispatchQueue.main.async {
                Global.dismissLoadingSpinner()
                switch response {
                case .success(let res):
                    if let data = res.plan_data {
                        completion(PlanDataViewModel(data: data))
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
}
