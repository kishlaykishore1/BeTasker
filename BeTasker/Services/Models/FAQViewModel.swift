//
//  FAQViewModel.swift
//  Chrono Green
//
//  Created by MACMINI on 03/06/21.
//

import UIKit

struct FAQDataModel: Codable {
    var faq: [FAQModel]?
}

struct FAQModel: Codable {
    var title: String?
    var faq_list: [FAQAnswers]?
}

struct FAQAnswers: Codable {
    var id: Int?
    var question: String?
    var answer: String?
    var isExpendable: Bool? = false
}

final class FAQAnswersViewModel {
    private var faqData = FAQAnswers()
    init(data: FAQAnswers) {
        self.faqData = data
    }
    var id: Int {
        return faqData.id ?? 0
    }
    
    var answer: String {
        return faqData.answer ?? ""
    }
    
//    var answerAttributed: NSAttributedString { //converting html to attr string with font
//        let finalAttr = NSMutableAttributedString()
//        let myAttrString = "".toAttrString(fontName: "SpartanMB-Regular", fontSize: 12, fontColor: UIColor.black)
//
//        finalAttr.append(myAttrString)
//
//        if let notice = faqData.answer {
//            if let htmlString = notice.htmlToAttributedString {
//                finalAttr.append(htmlString)
//            }
//        }
//        return finalAttr
//    }
    
    var question: String {
        return faqData.question ?? ""
    }
    
    var isExpendable: Bool {
        get {
            return faqData.isExpendable ?? false
        }
        set {
            faqData.isExpendable = newValue
        }
    }
}

final class FAQViewModel {
    private var faqData = FAQModel()
    
    init(data: FAQModel) {
        self.faqData = data
    }
    
    var title: String {
        return (faqData.title ?? "").uppercased()
    }
    
    var list: [FAQAnswers] { //It is used to make changes in Answers list
        get {
            let dataList = faqData.faq_list //?.map({return FAQAnswersViewModel(data: $0)})
            return dataList ?? []
        }
        set {
            faqData.faq_list = newValue
        }
    }
    
    var listViewModel: [FAQAnswersViewModel] {
        let arr = list.map({return FAQAnswersViewModel(data: $0)})
        return arr
    }
    
  static func FaqList(completion: @escaping(_ arrData: [FAQViewModel])->()) {
        let params: [String: Any] = [
            "lc": Constants.lc,
            "app_id": 1
        ]
        DispatchQueue.main.async {
            Global.showLoadingSpinner()
        }
        HpAPI.FAQLIST.DataAPI(params: params, shouldShowError: false, shouldShowSuccess: false, key: "data") { (response: Result<FAQDataModel, Error>) in
            DispatchQueue.main.async {
                Global.dismissLoadingSpinner()
                switch response {
                case .failure(let error):
                    if let err = error as? ErrorTypesAPP {
                        switch err {
                        default:
                            completion([])
                            break
                        }
                    }
                case .success(let data):
                    if let faq = data.faq {
                        let arrFaq = faq.map{return FAQViewModel(data: $0)}
                        completion(arrFaq)
                    } else {
                        completion([])
                    }
                }
            }
        }
    }
}
