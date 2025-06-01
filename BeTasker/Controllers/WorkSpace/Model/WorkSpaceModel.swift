//
//  WorkSpaceModel.swift
//  teamAlerts
//
//  Created by MAC on 28/01/25.
//

//struct WorkSpaceDataModel1: Codable {
//    var id: Int? //8,
//    var user_id: Int? //23,
//    var member_user_id: Int?
//    var created: String? //"2023-06-13T08:17:15+00:00",
//    var workspace_name: String? //"Test",
//    var workspace_pic: String? //"https://easyac.55.agency/demo/images/users/6d94070e-13d7-42b4-86d2-1c4dd5c970e8.jpg",
//    var member_count: Int?
//    var isSelected: Bool = false
//    var pendingTasksCount: Int?
//    
//}
//struct WorkSpaceViewDataModel {
//    
//    var workSpaceArray = [WorkSpaceDataModel1]()
//    
//    mutating func createDummyWorkSpaceData()
//    {
//        let w1 = WorkSpaceDataModel1(workspace_name: "WorkSpace 1", workspace_pic: nil, member_count: 3,isSelected: true,pendingTasksCount: 23)
//        let w2 = WorkSpaceDataModel1(workspace_name: "WorkSpace 2", workspace_pic: nil, member_count: 1,isSelected: false,pendingTasksCount: 4)
//        let w3 = WorkSpaceDataModel1(workspace_name: "WorkSpace 3", workspace_pic: nil, member_count: 3,isSelected: false,pendingTasksCount: 0)
//        let w4 = WorkSpaceDataModel1(workspace_name: "WorkSpace 4", workspace_pic: nil, member_count: 1,isSelected: false,pendingTasksCount: 0)
//        workSpaceArray = [w1,w2,w3,w4]
//    }
//    
//}


struct WorkSpaceModel: Codable {
    var total_task_count: Int?
    var data: [WorkSpaceDataModel]?
}

struct WorkSpaceDataModel: Codable {
    var id: Int? //8,
    var title: String? //"nee@gmail.com",
    var file_name: String?
    var is_premium: Bool?
    var is_display_link: Bool?
    var user_id: Int? //23, // Creator ID
    var received_task_count: Int?
    var send_task_count: Int?
    var nb_of_member: Int?
    var created: String? //"2023-06-13T08:17:15+00:00",
    var isSelected: Bool?
    var random_id: String?
    var taskCount: Int?
    var administrators_ids: [String]?
    var member_ids: [String]?
    var isAddType: Bool?
    var is_admin: Bool?
}

struct WorkSpaceDataViewModel {
    private var data = WorkSpaceDataModel()
    init(data: WorkSpaceDataModel) {
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
    
   
    var userId: Int { // Creator ID
        get {
        return data.user_id ?? 0
        }
        set {
            data.user_id = newValue
        }
    }
    var workSpaceName: String {
        get {
            return data.title ?? ""
        }
        set {
            data.title = newValue
        }
    }
    
    var isPremium: Bool {
        get {
            return data.is_premium ?? false
        }
        set {
            data.is_premium = newValue
        }
    }
    
    var isDisplayLink: Bool {
        get {
            return data.is_display_link ?? false
        }
        set {
            data.is_display_link = newValue
        }
    }
    
    var receivedTaskCount: Int {
        get {
            return data.received_task_count ?? 0
        }
        set {
            data.received_task_count = newValue
        }
    }
    
    var sentTaskCount: Int {
        get {
            return data.send_task_count ?? 0
        }
        set {
            data.send_task_count = newValue
        }
    }
    
    var numberOfmembers: Int {
        get {
            return data.nb_of_member ?? 0
        }
        set {
            data.nb_of_member = newValue
        }
    }
    var numberOfUrgentTasks: Int {
        get {
            return data.taskCount ?? 0
        }
        set {
            data.taskCount = newValue
        }
    }
    
    var createdOn: String {
        if let cretd = data.created {
            let result = Global.GetFormattedDate(dateString: cretd, currentFormate: "yyyy-MM-dd'T'HH:mm:ssZZZZ", outputFormate: "dd MMM yyyy", isInputUTC: true, isOutputUTC: false)
            return result.dateString?.lowercased() ?? ""
        }
        return ""
    }
    
    var workSpaceLogoURL: URL? {
        return data.file_name?.makeUrl()
    }
    var workSpaceFileName: String {
        return data.file_name ?? ""
    }
    var isSelected: Bool {
        get {
            return data.isSelected ?? false
        }
        set {
            data.isSelected = newValue
        }
    }
    
    var administrators_ids: [Int] {
        if let array = data.administrators_ids
        {
            return array.compactMap { Int($0) }
        }
        return  [Int]()
    }
    var member_ids: [Int] {
        if let array = data.member_ids
        {
            return array.compactMap { Int($0) }
        }
        return  [Int]()
    }
    
    var isAddType: Bool {
        get {
            return data.isAddType ?? false
        }
        set {
            data.isAddType = newValue
        }
    }
    
    var isWorkspaceCreator: Bool {
        let profileData = HpGlobal.shared.userInfo
        if userId == (profileData?.userId ?? 0) {
            return true
        } else {
            return false
        }
    }
    
    var isAdmin: Bool {
        return data.is_admin ?? false
    }
}

struct WorkSpaceViewModel {
    private var data = WorkSpaceModel()
    init(data: WorkSpaceModel) {
        self.data = data
    }
    var arrworkSpaces: [WorkSpaceDataViewModel] {
        if let arr = data.data {
            return arr.map({WorkSpaceDataViewModel(data: $0)})
        }
        return []
    }
    static func SearchMembersList(groupId: Int, searchKeyword: String, sender: UIViewController, completion: @escaping(_ arrMembers: [MembersDataViewModel])->()) {
        let params: [String: Any] = [
            "lc": Constants.lc,
            "search_keyword": searchKeyword,
            "group_id": groupId
        ]
        DispatchQueue.main.async {
            Global.showLoadingSpinner(sender: sender.view)
        }
        HpAPI.membersSearch.DataAPI(params: params, shouldShowError: false, shouldShowSuccess: false, key: "data") { (response: Result<MembersModel, Error>) in
            DispatchQueue.main.async {
                Global.dismissLoadingSpinner(sender.view)
                switch response {
                case .success(let res):
                    let data = MembersViewModel(data: res)
                    completion(data.arrMembers)
                    break
                case .failure(_):
                    completion([])
                    break
                }
            }
        }
    }
    static func GetWorkSpaceList(page: Int, limit: Int, sender: UIViewController, shouldShowLoader: Bool, completion: @escaping(_ arrWorkspaces: [WorkSpaceDataViewModel], _ totaltask: Int)->()) {
        let params: [String: Any] = [
            "page": page,
            "limit": limit,
            "client_secret": Constants.kClientSecret
        ]
        
        DispatchQueue.main.async {
            if shouldShowLoader {
            Global.showLoadingSpinner(sender: sender.view)
            }
        }
        HpAPI.workSpaceList.DataAPI(params: params, shouldShowError: false, shouldShowSuccess: false, key: nil) { (response: Result<WorkSpaceModel, Error>) in
            DispatchQueue.main.async {
                if shouldShowLoader {
                    Global.dismissLoadingSpinner(sender.view)
                }
                switch response {
                case .success(let res):
                    let resCount = res.total_task_count ?? 0
                    let data = WorkSpaceViewModel(data: res)
                    completion(data.arrworkSpaces,resCount)
                    break
                case .failure(_):
                    completion([],0)
                    break
                }
            }
        }
    }
    
    static func GetMyWorkSpaceList(page: Int, limit: Int, sender: UIViewController, shouldShowLoader: Bool, completion: @escaping(_ arrMembers: [WorkSpaceDataViewModel], _ totaltask: Int)->()) {
        let params: [String: Any] = [
            "page": page,
            "limit": limit,
            "client_secret": Constants.kClientSecret
        ]
        
        DispatchQueue.main.async {
            if shouldShowLoader {
            Global.showLoadingSpinner(sender: sender.view)
            }
        }
        HpAPI.workSpaceList.DataAPI(params: params, shouldShowError: false, shouldShowSuccess: false, key: nil) { (response: Result<WorkSpaceModel, Error>) in
            DispatchQueue.main.async {
                Global.dismissLoadingSpinner(sender.view)
                switch response {
                case .success(let res):
                    let resCount = res.total_task_count ?? 0
                    let data = WorkSpaceViewModel(data: res)
                    completion(data.arrworkSpaces,resCount)
                    break
                case .failure(_):
                    completion([],0)
                    break
                }
            }
        }
    }
    
    static func DeleteWorkSpace(sender: UIViewController, id: Int, groupId: Int, completion: @escaping(_ done: Bool)->()) {
        let params: [String: Any] = [
            "id": id,
            "client_secret": Constants.kClientSecret
        ]
        HpAPI.workSpaceDelete.DataAPI(params: params, shouldShowError: true, shouldShowSuccess: true, key: nil) { (response: Result<GeneralModel, Error>) in
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
    static func getWorkSpaceDetails(id: Int, completion: @escaping(_ workSpaceData: WorkSpaceDataViewModel?)->()) {
        let params: [String: Any] = [
            "id": id,
            "client_secret": Constants.kClientSecret
        ]
        HpAPI.workSpaceDetails.DataAPI(params: params, shouldShowError: false, shouldShowSuccess: false, key: "data") { (response: Result<WorkSpaceDataModel, Error>) in
            DispatchQueue.main.async {
                switch response {
                case .success(let res):
                    let data = WorkSpaceDataViewModel(data: res)
                    completion(data)
                    break
                case .failure(_):
                    completion(nil)
                    break
                }
            }
        }
    }
}
