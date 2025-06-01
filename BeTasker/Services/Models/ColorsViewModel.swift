//
//  ColorsViewModel.swift
//  EasyAC
//
//  Created by 55 agency on 05/06/23.
//

import UIKit

struct ColorsModel: Codable {
    var color_data: [ColorsDataModel]?
}

struct ColorsDataModel: Codable {
    var id: Int?
    var color_code: String?
}

struct ColorsDataViewModel {
    private var data = ColorsDataModel()
    init(data: ColorsDataModel) {
        self.data = data
    }
    var id: Int {
        return data.id ?? 0
    }
    var colorCode: String {
        return data.color_code ?? ""
    }
    var colorValue: UIColor {
        return UIColor(hexString: colorCode)
    }
}

struct ColorsViewModel {
    private var data = ColorsModel()
    init(data: ColorsModel) {
        self.data = data
    }
    var arrColors: [ColorsDataViewModel] {
        if let colors = data.color_data {
            return colors.map({ColorsDataViewModel(data: $0)})
        }
        return []
    }
    
    static func GetColors(completion: @escaping(_ colors: [ColorsDataViewModel])->()) {
        let params: [String: Any] = [
            "lc": Constants.lc
        ]
        HpAPI.colorList.DataAPI(params: params, shouldShowError: false, shouldShowSuccess: false, key: "data") { (response: Result<ColorsModel, Error>) in
            DispatchQueue.main.async {
                Global.dismissLoadingSpinner()
                switch response {
                case .success(let res):
                    let data = ColorsViewModel(data: res)
                    completion(data.arrColors)
                    break
                case .failure(_):
                    completion([])
                    break
                }
            }
        }
    }
    
}
