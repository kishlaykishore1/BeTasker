//
//  GroupDataModel.swift
//  teamAlerts
//
//  Created by B2Cvertical A++ on 09/05/24.
//

import UIKit

struct GroupModel: Codable {
    var data: GroupResponseModel?
    var total_count: Int?
}

struct GroupResponseModel: Codable {
    var group_list: [GroupDataModel]?
}

struct GroupResponseViewModel {
    private var data = GroupResponseModel()
    init(data: GroupResponseModel) {
        self.data = data
    }
    var arrGroups: [GroupViewModel] {
        if let arr = data.group_list {
            return arr.map({GroupViewModel(data: $0)})
        }
        return []
    }
    
    static func getGroupList(sender: UIViewController, showLoader: Bool, page: Int, limit: Int, completion: @escaping(_ arrGroups: [GroupViewModel], _ total: Int)->()) {
        let params: [String: Any] = [
            "lc": Constants.lc,
            "page": page,
            "limit": limit
        ]
        DispatchQueue.main.async {
            if showLoader {
                Global.showLoadingSpinner(sender: sender.view)
            }
        }
        HpAPI.getGroupList.DataAPI(params: params, shouldShowError: false, shouldShowSuccess: false, key: nil) { (response: Result<GroupModel, Error>) in
            DispatchQueue.main.async {
                Global.dismissLoadingSpinner(sender.view)
                switch response {
                case .success(let res):
                    if let data = res.data {
                        let responseData = GroupResponseViewModel(data: data)
                        completion(responseData.arrGroups, res.total_count ?? 0)
                    } else {
                        completion([], 0)
                    }
                case .failure(_):
                    completion([], 0)
                }
            }
        }
    }
    
    static func addEditGroup(sender: UIViewController, title: String, colorId: Int, image: Data?, groupId: Int?, completion: @escaping(_ done: Bool)->()) {
        var params: [String: Any] = [
            "lc": Constants.lc,
            "title": title,
            "color_id": colorId
        ]
        if let groupId = groupId {
            params["group_id"] = groupId
        }
        DispatchQueue.main.async {
            Global.showLoadingSpinner(sender: sender.view)
        }
        HpAPI.addEditGroup.requestUploadProgress(params: params, files: ["image": image], mimeType: .image, shouldShowError: true, shouldShowSuccess: true, key: nil) { (response: Result<GeneralModel, Error>) in
            DispatchQueue.main.async {
                Global.dismissLoadingSpinner(sender.view)
                switch response {
                case .success(_):
                    completion(true)
                case .failure(_):
                    completion(false)
                }
            }
        }
    }
    
    static func deleteGroup(sender: UIViewController, id: Int, completion: @escaping(_ done: Bool)->()) {
        let params: [String: Any] = [
            "lc": Constants.lc,
            "group_id": id
        ]
        DispatchQueue.main.async {
            Global.showLoadingSpinner(sender: sender.view)
        }
        HpAPI.deleteGroup.DataAPI(params: params, shouldShowError: true, shouldShowSuccess: true, key: nil) { (response: Result<GeneralModel, Error>) in
            DispatchQueue.main.async {
                Global.dismissLoadingSpinner(sender.view)
                switch response {
                case .success(_):
                    completion(true)
                case .failure(_):
                    completion(false)
                }
            }
        }
    }
    
}

struct GroupDataModel: Codable {
    var id: Int? //1,
    var user_id: Int? //23,
    var title: String? //"test",
    var image: String? //"",
    var color_id: Int? //2,
    var color_code: String? //"D093FF",
    var created: String? //"2024-05-09T12:49:55+00:00"
    var pending_report: Int?
    var is_owner: Bool?
    var manage_members: Bool?
    var request_status: Bool?
    var isSelected: Bool?
}

struct GroupViewModel {
    var data = GroupDataModel()
    init(data: GroupDataModel = GroupDataModel()) {
        self.data = data
    }
    var id: Int {
        return data.id ?? 0
    }
    var requestStatus: Bool {
        return data.request_status ?? false
    }
    var canManageMembers: Bool {
        return data.manage_members ?? false
    }
    var isOwner: Bool {
        return data.is_owner ?? false
    }
    var isSelected: Bool {
        get {
            return data.isSelected ?? false
        }
        set {
            data.isSelected = newValue
        }
    }
    
    var userId: Int {
        return data.user_id ?? 0
    }
    var pendingReportCount: Int {
        return data.pending_report ?? 0
    }
    var title: String {
        return id == -1 ? "Toutes les équipes".localized : data.title ?? ""
    }
    var image: URL? {
        return data.image?.makeUrl()
    }
    var colorId: Int {
        return data.color_id ?? 0
    }
    var colorCode: String {
        return data.color_code ?? ""
    }
    var colorValue: UIColor {
        return UIColor(hexString: colorCode)
    }
    var created: String {
        return (data.created ?? "").replacingOccurrences(of: "T", with: " ").replacingOccurrences(of: "+00:00", with: "")
    }
    var date: String {
        return Global.GetFormattedDate(dateString: created, currentFormate: "yyyy-MM-dd HH:mm:ss", outputFormate: "dd MMM yyyy HH:mm", isInputUTC: true, isOutputUTC: false).dateString ?? ""
    }
}

struct GroupDataCache {
    static let key = "groupData"
    static func save(_ value: GroupDataModel) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(value) {
            Constants.kUserDefaults.set(encoded, forKey: key)
        }
    }
    static func get() -> GroupViewModel {
        var obj = GroupDataModel()
        obj.id = -1
        let noData = GroupViewModel(data: obj)
        if let savedData = UserDefaults.standard.object(forKey: key) as? Data {
            let decoder = JSONDecoder()
            if let dataRes = try? decoder.decode(GroupDataModel.self, from: savedData) {
                return GroupViewModel(data: dataRes)
            } else {
                return noData
            }
        } else {
            return noData
        }
    }
    static func remove() {
        Constants.kUserDefaults.removeObject(forKey: key)
    }
}
