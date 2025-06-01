//
//  WorkSpaceMemberModel.swift
//  teamAlerts
//
//  Created by MAC on 30/01/25.
//

//
//  MembersViewModel.swift
//  EasyAC
//
//  Created by 55 agency on 13/06/23.
//

import UIKit

struct WorkSpaceMembersModel: Codable {
    var data: [WorkSpaceMembersDataModel]?
}

struct WorkSpaceMembersDataModel: Codable {
    var id: Int? //8,
    var email: String? //"nee@gmail.com",
    var user_id: Int? //23,
    var member_user_id: Int?
    var created: String? //"2023-06-13T08:17:15+00:00",
    var last_name: String? //"Nee",
    var first_name: String? //"Test",
    var access_type: String? //"Limited",
    var profile_pic: String? //"https://easyac.55.agency/demo/images/users/6d94070e-13d7-42b4-86d2-1c4dd5c970e8.jpg",
    var allowed_room: String? //"4,2,3",
    var manage_members: Bool? //false,
    var request_status: Bool? //false
    var country_code: String?
    var mobile: String?
    var type : String?
    var isSelected: Bool?
    var random_id: String?
    var isAddType: Bool?
}

struct WorkSpaceMembersDataViewModel {
    private var data = WorkSpaceMembersDataModel()
    init(data: WorkSpaceMembersDataModel) {
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
    
    var randomId: (withHash: String, plain: String) {
        let random = data.random_id ?? ""
        return ("#\(random)", random)
    }
    
    var email: String {
        return data.email ?? ""
    }
    var type: String {
        return data.type ?? ""
    }
    var hiddenEmail: String {
        let emailParts = email.split(separator: "@")
        if emailParts.count == 2 {
            let emailIdFirstLetter = emailParts[0].prefix(1)
            let emailIdLastLetter = emailParts[0].suffix(1)
            let emailId = "\(emailIdFirstLetter)****\(emailIdLastLetter)@"
            let emailDomainParts = emailParts[1].split(separator: ".")
            if emailDomainParts.count >= 2 {
                let emailDomainFirstLetter = emailDomainParts[0].prefix(1)
                let emailDomainLastLetter = emailDomainParts[0].suffix(1)
                var lastPart = ""
                for i in 1..<emailDomainParts.count {
                    lastPart += emailDomainParts[i]
                }
                let emailDomain = "\(emailDomainFirstLetter)***\(emailDomainLastLetter).\(lastPart)"
                return "\(emailId)\(emailDomain)"
            }
        }
        return ""
    }
    
    var hiddenMobileNumber: String {
        return "\(countryPhoneCode)• • • • • •\(mobileNumber.suffix(4))"
    }
    
    var hiddenMobileWithEmail: String {
        return "\(hiddenMobileNumber) • \(hiddenEmail)"
    }
    
    var countryPhoneCode: String {
        return data.country_code ?? ""
    }
    var mobileNumber: String {
        return (data.mobile ?? "").replacingOccurrences(of: " ", with: "")
    }
    var mobileNumberWithCountryCode: String {
        return "\(countryPhoneCode) \(mobileNumber.formattedPhoneNumber())"
    }
    var emailWithMobile: String {
        if mobileNumber != "" {
            return "\(mobileNumberWithCountryCode) • \(email)"
        }
        return email
    }
    var userId: Int {
        get {
        return data.user_id ?? 0
        }
        set {
            data.user_id = newValue
        }
    }
    var memberUserId: Int {
        get {
        return data.member_user_id ?? 0
        }
        set {
            data.member_user_id = newValue
        }
    }
    var isMe: Bool {
        let profileData = HpGlobal.shared.userInfo
        return memberUserId == profileData?.userId
    }
    var isIamOwner: Bool {
        let profileData = HpGlobal.shared.userInfo
        return userId == profileData?.userId
    }
    var isCreator: Bool {
        return userId == memberUserId
    }
    var accessType: AccessType {
        return AccessType(rawValue: data.access_type ?? "") ?? .Completed
    }
    var accessTypeText: String {
        switch accessType {
        case .Completed:
            return "Accès complet".localized
        case .Limited:
            return "\("Accès".localized) \(allowedRoomIds.count) \("pièce(s)".localized)"
        }
    }
    var allowedRoomIds: [Int] {
        return (data.allowed_room ?? "").split(separator: ",").map({Int("\($0)") ?? 0})
    }
    var canManageMembers: Bool {
        return data.manage_members ?? false
    }
    var requestStatus: Bool {
        return data.request_status ?? false
    }
    var invitedOn: String {
        return "\("Invitation envoyée le".localized) \(createdOn)"
    }
    var firstName: String {
        get {
            return data.first_name?.trim() ?? ""
        }
        set {
            data.first_name = newValue.trim()
        }
    }
    var lastName: String {
        get {
            return data.last_name?.trim() ?? ""
        }
        set {
            data.last_name = newValue.trim()
        }
    }
    var fullName: String {
        return "\(firstName) \(lastName)".trim()
    }
    var fullNameFormatted: String {
        return "\(firstName) \(lastName.prefix(1))."
    }
    var createdOn: String {
        if let cretd = data.created {
            let result = Global.GetFormattedDate(dateString: cretd, currentFormate: "yyyy-MM-dd'T'HH:mm:ssZZZZ", outputFormate: "dd MMM yyyy", isInputUTC: true, isOutputUTC: false)
            return result.dateString?.lowercased() ?? ""
        }
        return ""
    }
    
    var profilePicURL: URL? {
        return data.profile_pic?.makeUrl()
    }
    
    var isSelected: Bool {
        get {
            return data.isSelected ?? false
        }
        set {
            data.isSelected = newValue
        }
    }
    
    var isAddType: Bool {
        get {
            return data.isAddType ?? false
        }
        set {
            data.isAddType = newValue
        }
    }
}

struct WorkSpaceMembersViewModel {
    private var data = WorkSpaceMembersModel()
    init(data: WorkSpaceMembersModel) {
        self.data = data
    }
    var arrMembers: [WorkSpaceMembersDataViewModel] {
        if let arr = data.data {
            return arr.map({WorkSpaceMembersDataViewModel(data: $0)})
        }
        return []
    }
    
    static func GetWorkSpaceMembersList(workSpaceId: Int, page: Int, limit: Int, sender: UIViewController, shouldShowLoader: Bool, completion: @escaping(_ arrMembers: [WorkSpaceMembersDataViewModel])->()) {
        var params: [String: Any] = [
            "lc": Constants.lc,
            "page": page,
            "limit": limit,
            "client_secret": Constants.kClientSecret
        ]
        if workSpaceId > 0 {
            params["workspace_id"] = workSpaceId
        } else {
            params["group_id"] = ""
        }
        DispatchQueue.main.async {
            if shouldShowLoader {
            Global.showLoadingSpinner(sender: sender.view)
            }
        }
        HpAPI.workSpacemembersList.DataAPI(params: params, shouldShowError: false, shouldShowSuccess: false, key: nil) { (response: Result<WorkSpaceMembersModel, Error>) in
            DispatchQueue.main.async {
                Global.dismissLoadingSpinner(sender.view)
                switch response {
                case .success(let res):
                    let data = WorkSpaceMembersViewModel(data: res)
                    completion(data.arrMembers)
                    break
                case .failure(_):
                    completion([])
                    break
                }
            }
        }
    }
    
    static func DeleteMember(sender: UIViewController, id: Int, groupId: Int, completion: @escaping(_ done: Bool)->()) {
        let params: [String: Any] = [
            "lc": Constants.lc,
            "id": id,
            "group_id": groupId
        ]
        HpAPI.membersDelete.DataAPI(params: params, shouldShowError: true, shouldShowSuccess: true, key: nil) { (response: Result<GeneralModel, Error>) in
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
