//
//  TaskStatusModel.swift
//  teamAlerts
//
//  Created by B2Cvertical A++ on 24/01/25.
//

import Foundation

struct TaskStatusResponseModel: Codable {
    var file_list: [String]?
}

struct TaskStatusResponseViewModel {
    private var data = TaskStatusResponseModel()
    init(data: TaskStatusResponseModel = TaskStatusResponseModel()) {
        self.data = data
    }
    var arrFileDict: [[String: Any]] {
        return data.file_list?.compactMap { file in
            var dict: [String: Any] = [:]
            //if let id = file.id {
                dict["id"] = 0
            //}
            //if let image = file.file_name {
                dict["image"] = file
            //}
            return dict
        } ?? []
    }
}

struct TaskStatusModel: Codable {
    var id: Int? //1,
    var title: String? //"En cours",
    var color_code: String? //"80FFE8"
    var total_task:Int?
    var isSelected: Bool?
}

struct TaskStatusViewModel {
    private var data = TaskStatusModel()
    init(data: TaskStatusModel = TaskStatusModel()) {
        self.data = data
    }
    var id: Int {
        return data.id ?? 0
    }
    var title: String {
        return data.title ?? ""
    }
    var colorCode: String {
        return data.color_code ?? ""
    }
    var colorValue: UIColor {
        return UIColor(hexString: colorCode)
    }
    var taskCount: Int {
        return data.total_task ?? 0
    }
    
    var isSelected: Bool {
        get {
            return data.isSelected ?? false
        }
        set {
            data.isSelected = newValue
        }
    }
    
    static func taskStatusList(completion: @escaping(_ list: [TaskStatusViewModel])->()) {
        let params: [String: Any] = [
            "lc": Constants.lc
        ]
        HpAPI.statusList.DataAPI(params: params, shouldShowError: false, shouldShowSuccess: false, key: "data") { (response: Result<[TaskStatusModel], Error>) in
            DispatchQueue.main.async {
                switch response {
                case .success(let res):
                    let arr = res.map({TaskStatusViewModel(data: $0)})
                    completion(arr)
                    break
                case .failure(_):
                    completion([])
                    break
                }
            }
        }
    }
    
    static func homeTaskStatusList(param: [String: Any] = [:], completion: @escaping(_ list: [TaskStatusViewModel])->()) {
        let params: [String: Any] = [
            "lc": Constants.lc
        ]
        HpAPI.homeStatusList.DataAPI(params: params.merging(param) { (_, new) in new }, shouldShowError: false, shouldShowSuccess: false, key: "data") { (response: Result<[TaskStatusModel], Error>) in
            DispatchQueue.main.async {
                switch response {
                case .success(let res):
                    let arr = res.map({TaskStatusViewModel(data: $0)})
                    completion(arr)
                    break
                case .failure(_):
                    completion([])
                    break
                }
            }
        }
    }
    
    static func updateTaskStatus(params: [String: Any], completion: @escaping(_ arrFileDict: [[String: Any]])->()) {
        HpAPI.taskStatusUpdate.DataAPI(params: params, shouldShowError: false, shouldShowSuccess: false, key: nil) { (response: Result<TaskStatusResponseModel, Error>) in
            DispatchQueue.main.async {
                switch response {
                case .success(let res):
                    let data = TaskStatusResponseViewModel(data: res)
                    completion(data.arrFileDict)
                    break
                case .failure(_):
                    completion([])
                    break
                }
            }
        }
    }
}
