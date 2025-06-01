//
//  IconsViewModel.swift
//  EasyAC
//
//  Created by 55 agency on 05/06/23.
//

import UIKit

struct IconsModel: Codable {
    var icons_data: [IconsDataModel]?
}

struct IconsDataModel: Codable {
    var id: Int?
    var name: String?
    var file_name: String?
}

struct IconsDataViewModel {
    private var data = IconsDataModel()
    init(data: IconsDataModel) {
        self.data = data
    }
    
    var id: Int {
        return data.id ?? 0
    }
    var iconName: String {
        return data.name ?? ""
    }
    var fileURL: URL? {
        return data.file_name?.makeUrl()
    }
}

struct IconsViewModel {
private var data = IconsModel()
    init(data: IconsModel) {
        self.data = data
    }
    var arrIcons: [IconsDataViewModel] {
        if let icons = data.icons_data {
            return icons.map({IconsDataViewModel(data: $0)})
        }
        return []
    }
    
    static func GetIcons(completion: @escaping(_ arrIcons: [IconsDataViewModel])->()) {
        let params: [String: Any] = [
            "lc": Constants.lc
        ]
        HpAPI.iconList.DataAPI(params: params, shouldShowError: false, shouldShowSuccess: false, key: "data") { (response: Result<IconsModel, Error>) in
            DispatchQueue.main.async {
                Global.dismissLoadingSpinner()
                switch response {
                case .success(let res):
                    let data = IconsViewModel(data: res)
                    completion(data.arrIcons)
                    break
                case .failure(_):
                    completion([])
                    break
                }
            }
        }
    }
    
}
