//
//  FilterDataModel.swift
//  teamAlerts
//
//  Created by B2Cvertical A++ on 07/12/24.
//

import UIKit

struct FilterDataModel: Codable {
    var startDate: String?
    var endDate: String?
    var statusIds: [Int]?
    var userIds: [Int]?
    var isFilterApplied: Bool = false
}

struct FilterDataViewModel {
    var data = FilterDataModel()
    init(data: FilterDataModel = FilterDataModel()) {
        self.data = data
    }
    var isFilterApplied: Bool {
        get {
            return data.isFilterApplied
        }
        set {
            data.isFilterApplied = newValue
        }
    }
    
    var startDate: String {
        get {
            return data.startDate ?? ""
        }
        set {
            data.startDate = newValue
        }
    }
    
    var endDate: String {
        get {
            return data.endDate ?? ""
        }
        set {
            data.endDate = newValue
        }
    }
    
    var statusIds: [Int] {
        get {
            return data.statusIds ?? []
        }
        set {
            data.statusIds = newValue
        }
    }
    
    var userIds: [Int] {
        get {
            return data.userIds ?? []
        }
        set {
            data.userIds = newValue
        }
    }
    
    var isEmpty: Bool {
        return statusIds.isEmpty &&
        userIds.isEmpty &&
        endDate.isEmpty &&
        startDate.isEmpty
    }
}

struct FilterDataCache {
    static let key = "filterData"
    static func save(_ value: FilterDataModel) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(value) {
            Constants.kUserDefaults.set(encoded, forKey: key)
        }
    }
    static func get() -> FilterDataViewModel {
        let obj = FilterDataModel()
        let noData = FilterDataViewModel(data: obj)
        if let savedData = UserDefaults.standard.object(forKey: key) as? Data {
            let decoder = JSONDecoder()
            if let dataRes = try? decoder.decode(FilterDataModel.self, from: savedData) {
                return FilterDataViewModel(data: dataRes)
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
