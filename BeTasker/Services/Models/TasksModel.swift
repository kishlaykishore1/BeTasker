//
//  TasksModel.swift
//  teamAlerts
//
//  Created by B2Cvertical A++ on 25/11/24.
//

import Foundation

enum EnumTaskListType: String {
    case assignedToMe = "AssignReceived"
    case assignedByMe = "AssignSend"
}

enum EnumTaskUserType: String {
    case assigner
    case completer
    case recaller
}

enum EnumWorkStatus: String {
    case urgent
    case inProgress
    case newStatus
    case infoRequested
    case tobeChecked
    case finished
    
    func getStatus() -> (status: EnumWorkStatus, text: String, color: UIColor) {
        let colorRed = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)
        let colorYellow = #colorLiteral(red: 1, green: 0.7764705882, blue: 0.2, alpha: 1)
        let colorBlue = #colorLiteral(red: 0.2980392157, green: 0.4, blue: 0.9568627451, alpha: 1)
        let colorPurple = #colorLiteral(red: 0.6823529412, green: 0.01960784314, blue: 0.5882352941, alpha: 1)
        let colorCyan = #colorLiteral(red: 0.01960784314, green: 0.6823529412, blue: 0.5921568627, alpha: 1)
        let colorGreen = #colorLiteral(red: 0.1803921569, green: 0.6823529412, blue: 0.01960784314, alpha: 1)
        switch self {
        case .urgent:
            return (status: self, text: "URGENT", color: colorRed)
        case .inProgress:
            return (status: self, text: "EN COURS", color: colorYellow)
        case .newStatus:
            return (status: self, text: "NOUVEAU", color: colorBlue)
        case .infoRequested:
            return (status: self, text: "Infos demandées", color: colorPurple)
        case .tobeChecked:
            return (status: self, text: "À vérifier", colorCyan)
        case .finished:
            return (status: self, text: "Terminé", colorGreen)
        }
    }
}

enum EnumTaskStatus {
    case normalTask
    case urgentTask
    case recalledTask
}

struct TaskHistoryModel: Codable {
    var user_name: String?
    var date: String?
    var recall_message: String?
    var action_type: String?
}

struct TaskHistoryViewModel {
    private var data = TaskHistoryModel()
    init(data: TaskHistoryModel = TaskHistoryModel()) {
        self.data = data
    }
    var userName: String {
        return data.user_name ?? ""
    }
    var date: String {
        return data.date ?? ""
    }
    var dateFormatted: (date: Date, dateString: String) {
        let dt = Global.GetFormattedDate(dateString: date, currentFormate: "yyyy-MM-dd HH:mm", outputFormate: "EEEE dd MMM yyyy", isInputUTC: true, isOutputUTC: false)
        return (date: dt.date ?? Date(), dateString: dt.dateString ?? "")
    }
    var timeFormatted: (date: Date, dateString: String) {
        let dt = Global.GetFormattedDate(dateString: date, currentFormate: "yyyy-MM-dd HH:mm", outputFormate: "HH'h'mm", isInputUTC: true, isOutputUTC: false)
        return (date: dt.date ?? Date(), dateString: dt.dateString ?? "")
    }
    var recallMessage: String {
        return data.recall_message ?? ""
    }
    var taskUserType: EnumTaskUserType {
        return EnumTaskUserType(rawValue: data.action_type ?? "") ?? .assigner
    }
    var historyText: NSMutableAttributedString {
        var msg = "Envoyée par".localized
        switch taskUserType {
        case .assigner:
            msg = "Envoyée par".localized
        case .completer:
            msg = "Terminé par".localized
        case .recaller:
            msg = "Recall par".localized
        }
        return Global.setAttributedText(arrText: [
            ("\(msg) ", FontName.Graphik.regular, 13, UIFont.Weight.regular, UIColor.colorBlack50),
            ("\(userName)", FontName.Graphik.medium, 13, UIFont.Weight.medium, UIColor.colorBlack50),
            (" le ".localized, FontName.Graphik.regular, 13, UIFont.Weight.regular, UIColor.colorBlack50),
            ("\(dateFormatted.dateString)", FontName.Graphik.medium, 13, UIFont.Weight.medium, UIColor.colorBlack50),
            (" à ".localized, FontName.Graphik.regular, 13, UIFont.Weight.regular, UIColor.colorBlack50),
            ("\(timeFormatted.dateString)", FontName.Graphik.medium, 13, UIFont.Weight.medium, UIColor.colorBlack50)
        ])
    }
}

struct TaskListResponseModel: Codable {
    var data: [TaskDateGroupModel]?
    var total_count: Int?
    var total_task: Int?
}

// MARK: - Task Group by Date
struct TaskDateGroupModel: Codable {
    var date: String?
    var tasks: [TasksModel]?
}

struct WorkspaceOnlyTaskModel: Codable {
    var tasks: [TasksModel]?
    var workspcae_id: Int?
    var workspcae_title: String?
}

struct WorkSpaceOnlyTasksViewModel {
    private var data = WorkspaceOnlyTaskModel()
    
    init(data: WorkspaceOnlyTaskModel = WorkspaceOnlyTaskModel()) {
        self.data = data
    }
    
    var workspaceId: Int {
        return data.workspcae_id ?? 0
    }
    
    var workspaceTitle: String {
        return data.workspcae_title ?? "Title"
    }
    
    var arrTasks: [TasksViewModel] {
        if let arr = data.tasks {
            return arr.map({TasksViewModel(data: $0)})
        }
        return []
    }
    
}

struct GroupedTasksViewModel {
    private var data = TaskDateGroupModel()
    var arrTasks: [TasksViewModel] // ✅ make this mutable
    
    init(data: TaskDateGroupModel = TaskDateGroupModel()) {
        self.data = data
        if let arr = data.tasks {
            self.arrTasks = arr.map({ TasksViewModel(data: $0) })
        } else {
            self.arrTasks = []
        }
    }
    
    var taskDate: String {
        return data.date ?? ""
    }
    
    var sectionTitle: String {
        let date = self.taskDate.convertUTCDateStringToDate()
        return date.toFormattedDate(dateFormateString: "EEEE dd MMM yyyy")
    }
    
    var archiveTitle: String {
        let date = self.taskDate.convertUTCDateStringToDate()
        return date.toDateString(dateFormateString: "EEEE dd MMM yyyy")
    }
    
}

struct TasksModel: Codable {
    var task_id: Int? //14,
    var completion_id: Int?
    var workspcae_id: Int?
    var workspcae_title: String?
    var task_assigner_user_id: Int? //55,
    var title: String? //"Check in 3306",
    var description: String?
    var display_link: String?
    var message: String?
    var is_recalled: Bool? //true,
    var is_notification: Bool? //true,
    var is_notification_enable: Bool? //true
    var is_archive: Bool?
    var created: String? //"2024-12-03 10:29"
    var recall_message: String?
    var hour: String?
    var random_id: String?
    var is_photo: Bool? //true,
    var is_message: Bool? //true,
    var recurrence_days: [String]? //false,
    var is_schedule: Bool? //0,
    var is_recurring: Bool? //0
    var task_status: TaskStatusModel?
    var member_ids: [String]?
    var duration_days: String?
    var schedule_type: String?
    var start_date: String?
    var archive_date: String?
    var is_admin: Bool?
    var file_data: [FileModel]?
    var task_history: [TaskHistoryModel]?
    var member_list: [TempProfileModel]?
    var task_creator_user: MembersDataModel?
}


struct TasksViewModel {
    private var data = TasksModel()
    init(data: TasksModel = TasksModel()) {
        self.data = data
    }
    var taskId: Int {
        return data.task_id ?? 0
    }
    var completionId: Int {
        return data.completion_id ?? 0
    }
    
    var workSpaceId: Int {
        return data.workspcae_id ?? 0
    }
    
    var workSpaceTitle: String {
        return data.workspcae_title ?? ""
    }
    
    var taskAssignerUserId: Int {
        return data.task_assigner_user_id ?? 0
    }
    
    var title: String {
        return data.title ?? ""
    }
    
    var isAdmin: Bool {
        return data.is_admin ?? false
    }
    
    var description: String {
        return data.description ?? ""
    }
    
    var displayLink: String {
        return data.display_link ?? ""
    }
    
    var archiveDate: String {
        return data.archive_date ?? ""
    }
    
    var taskStatus: TaskStatusViewModel? {
        if let status = data.task_status {
            return TaskStatusViewModel(data: status)
        }
        return nil
    }
    
    var hour: [String] {
        if let time = data.hour {
            let arrTime = time.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            return arrTime.compactMap { time in
                let currentDateString = Global.GetFormattedDate(date: Date(), outputFormate: "yyyy-MM-dd", isInputUTC: false, isOutputUTC: false).dateString ?? ""
                let currentDateTime = "\(currentDateString) \(time)"
                let dt = Global.GetFormattedDate(dateString: currentDateTime, currentFormate: "yyyy-MM-dd HH:mm", outputFormate: "yyyy-MM-dd HH:mm", isInputUTC: true, isOutputUTC: false).date ?? Date()
                return dt.toLocalString(format: "HH'h'mm")
            }
        }
        return []
    }
    
    var formattedStartDate: String {
        let dt = Global.GetFormattedDate(dateString: startDate, currentFormate: "yyyy-MM-dd hh:mm:ss", outputFormate: "yyyy-MM-dd HH:mm:ss", isInputUTC: true, isOutputUTC: false).date ?? Date()
        return dt.toLocalString(format: "dd MMM yyyy HH:mm")
    }
    
    var hourHHmm: [String] {
        if let time = data.hour {
            let arrTime = time.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            return arrTime.compactMap { time in
                let currentDateString = Global.GetFormattedDate(date: Date(), outputFormate: "yyyy-MM-dd", isInputUTC: false, isOutputUTC: false).dateString ?? ""
                let currentDateTime = "\(currentDateString) \(time)"
                let dt = Global.GetFormattedDate(dateString: currentDateTime, currentFormate: "yyyy-MM-dd HH:mm", outputFormate: "yyyy-MM-dd HH:mm", isInputUTC: true, isOutputUTC: false).date ?? Date()
                return dt.toLocalString(format: "HH:mm")
            }
        }
        return []
    }
    
    var message: String {
        return data.message ?? ""
    }
    var arrUsers: [TempProfileViewModel] {
        if let arr = data.member_list {
            return arr.map({TempProfileViewModel(data: $0)})
        }
        return []
    }
    
    var arrImages: [FileViewModel] {
        if let arr = data.file_data {
            return arr.map({FileViewModel(data: $0)})
        }
        return []
    }
    
    var arrFileDict: [[String: Any]] {
        return data.file_data?.compactMap { file in
            var dict: [String: Any] = [:]
            if let id = file.id {
                dict["id"] = id
            }
            if let image = file.file_name {
                dict["image"] = image
            }
            return dict
        } ?? []
    }
    
    var taskCreator: MembersDataViewModel? {
        if let user = data.task_creator_user {
            return MembersDataViewModel(data: user)
        }
        return nil
    }
    var arrHistory: [TaskHistoryViewModel] {
        if let arr = data.task_history {
            return arr.map({TaskHistoryViewModel(data: $0)})
        }
        return []
    }
    var isRecalled: Bool {
        return data.is_recalled ?? false
    }
    var recallMessage: String {
        return data.recall_message ?? ""
    }
    var isUrgent: Bool {
        return data.is_notification ?? false
    }
    
    var taskNotificationEnabled: Bool {
        get {
            return data.is_notification_enable ?? false
        }
        set {
            data.is_notification_enable = newValue
        }
    }
    
    var isArchivedTask: Bool {
        return data.is_archive ?? false
    }
    
    var isPhotoRequired: Bool {
        return data.is_photo ?? false
    }
    var isMessageRequired: Bool {
        return data.is_message ?? false
    }
    var isScheduled: Bool {
        return data.is_schedule ?? false
    }
    
    var isRecurring: Bool {
        return data.is_recurring ?? false
    }
    
    var durationDays: String {
        return data.duration_days ?? "30"
    }
    
    var scheduleType: String {
        return data.schedule_type ?? "1"
    }
    
    var startDate: String {
        return data.start_date ?? ""
    }
    
    var status: EnumTaskStatus {
        if isUrgent {
            return .urgentTask
        } else if isRecalled {
            return .recalledTask
        } else {
            return .normalTask
        }
    }
    var textColor: UIColor {
        switch status {
        case .normalTask:
            return UIColor.color2D2D2DF8F8F8
        case .urgentTask:
            return UIColor.white
        case .recalledTask:
            return UIColor.color2D2D2DF8F8F8
        }
    }
    var bgColor: UIColor {
        switch status {
        case .normalTask:
            return UIColor.colorFFFFFF000000
        case .urgentTask:
            return UIColor.colorDF1010
        case .recalledTask:
            return UIColor.colorFFFFFF000000
        }
    }
    var created: String {
        return data.created ?? ""
    }
    var dateCreated: (date: Date, dateString: String) {
        let dt = Global.GetFormattedDate(dateString: created, currentFormate: "yyyy-MM-dd HH:mm", outputFormate: "EEEE dd MMM yyyy", isInputUTC: true, isOutputUTC: false)
        return (date: dt.date ?? Date(), dateString: dt.dateString ?? "")
    }
    
    var dateCreatedFormatted: (date: Date, dateString: String) {
        let dt = Global.GetFormattedDate(dateString: created, currentFormate: "yyyy-MM-dd HH:mm", outputFormate: "dd MMM yyyy' · 'HH:mm", isInputUTC: true, isOutputUTC: false)
        return (date: dt.date ?? Date(), dateString: dt.dateString ?? "")
    }
    
    var dateOnly: Date {
        return Global.getDateFromString(dateString: created, formatString: "yyyy-MM-dd HH:mm", outputFormatString: "yyyy-MM-dd")
    }
    
    var randomId: (withHash: String, plain: String) {
        let random = data.random_id ?? ""
        return ("#\(random)", random)
    }
    
    var arrRecurrenceDaysInteger: [Int] {
        let arr = data.recurrence_days ?? []
        return arr.map({Int("\($0)") ?? 0})
    }
    
    var formmatedCreatedDate: String {
        let dt = Global.GetFormattedDate(dateString: created, currentFormate: "yyyy-MM-dd HH:mm", outputFormate: "dd MMM yyyy' at 'HH:mm", isInputUTC: true, isOutputUTC: false)
        return dt.dateString ?? ""
    }
    
    var timestamp: Double {
        guard let timestamp = Global.convertToTimestamp(dateString: created) else { return 0 }
        return Double(timestamp)
    }
    
    var recurrenceDaysFormated: String {
        /*
         "Lundi"
         "Mardi"
         "Mercredi"
         "Jeudi"
         "Vendredi"
         "Samedi"
         "Dimanche"
         If only 1 day, then full day. Ex “Lundi”, "Mardi", "Mercredi"

         If 2 to 6 day, then each letter. Ex “L,M,J,V”

         If all days then “Tous les jours”

         If saturday/sunday only “Week-end”

         If all week-day“En semaine”
         */
        if arrRecurrenceDaysInteger.count == 7 || arrRecurrenceDaysInteger.count == 0 {
            return "Tous les jours".localized
        }
        var arrDayName = WeekDaysViewModel.GetWeekDays()
            for i in 0..<arrRecurrenceDaysInteger.count {
                if let idx = arrDayName.firstIndex(where: {$0.weekDayPosition == arrRecurrenceDaysInteger[i]}) {
                    arrDayName[idx].isSelected = true
                }
            }
        let arrWeekDays = arrDayName.filter({$0.isSelected == true})
        
        if arrWeekDays.count == 1 {
            if arrRecurrenceDaysInteger[0] == 6 || arrRecurrenceDaysInteger[0] == 7 {
                return "Week-end"
            }
            return arrWeekDays[0].weekDayName
        } else {
            if arrWeekDays.count == 2 {
                if arrRecurrenceDaysInteger[0] == 6 && arrRecurrenceDaysInteger[1] == 7 {
                    return "Week-end"
                }
            } else if arrWeekDays.count == 5 && arrRecurrenceDaysInteger.contains(6) == false && arrRecurrenceDaysInteger.contains(7) == false {
                return "En semaine".localized
            }
            return arrWeekDays.map({$0.weekDayName.prefix(3)}).joined(separator: ", ")
        }
    }
    //["Tous les 1 mois".localized, "Tous les 2 mois".localized, "Tous les 3 mois".localized, "Tous les 4 mois".localized, "Tous les 6 mois".localized, "Tous les 12 mois".localized]
    var recurrenceMonthFormated: String {
        switch durationDays {
        case "1":
            return "Tous les 1 mois".localized
        case "2":
            return "Tous les 2 mois".localized
        case "3":
            return "Tous les 3 mois".localized
        case "4":
            return "Tous les 4 mois".localized
        case "6":
            return "Tous les 6 mois".localized
        case "12":
            return "Tous les 12 mois".localized
        default:
            return ""
        }
    }
    
    var dayTextFormatted: String {
        switch scheduleType {
        case "1":
            return ""
        case "2":
            return recurrenceDaysFormated
        case "3":
            return recurrenceMonthFormated
        default:
            return ""
        }
    }
    
    static func getTaskList(listFor: String, currenWorkSpaceId: Int, searchText: String, completion: @escaping(_ arrData: [GroupedTasksViewModel], _ total: Int, _ totaltask: Int)->()) {
        var params: [String: Any] = [
            "search_key": searchText,
            "list_for": listFor, //AssignReceived,AssignSend
            "client_secret": Constants.kClientSecret,
            "page": 1,
            "limit": 10000
        ]
        if currenWorkSpaceId > 0
        {
            params["workspcae_id"] = currenWorkSpaceId
        }
        let filter = FilterDataCache.get()
        if filter.isFilterApplied {
            if filter.userIds.count > 0 {
                let selectedUsers = filter.userIds.map({"\($0)"}).joined(separator: ",")
                params["user_ids"] = selectedUsers
            }
            params["start_date"] = filter.startDate
            params["end_date"] = filter.endDate
            if filter.statusIds.count > 0 {
                let selectedStatus = filter.statusIds.map({"\($0)"}).joined(separator: ",")
                params["task_status_id"] = selectedStatus
            }
           // params["is_notification"] = filter.isUrgent ? 1 : 0
        }
        HpAPI.taskList.DataAPI(params: params, shouldShowError: false, shouldShowSuccess: false, key: nil) { (response: Result<TaskListResponseModel, Error>) in
            DispatchQueue.main.async {
                switch response {
                case .success(let res):
                    let arrResData = res.data ?? []
                    let arr = arrResData.map({GroupedTasksViewModel(data: $0)})
//                    let groupedDictionary = Dictionary(grouping: arr) { $0.dateOnly }
//                    let keys = groupedDictionary.keys.sorted(by: {$0 > $1})
 //                   let arrData = keys.map{ DateWiseTasks(date: $0.toDateString(dateFormateString: "EEEE dd MMM yyyy"), arrTasks: groupedDictionary[$0]!.sorted(by: {$0.dateCreated.date > $1.dateCreated.date})) }
                    completion(arr, res.total_count ?? 0, res.total_task ?? 0)
                    break
                case .failure(_):
                    completion([], 0, 0)
                    break
                }
            }
        }
    }
    
    static func getTaskUserList(listFor: String, completion: @escaping(_ arrData: [MembersDataViewModel])->()) {
        let params: [String: Any] = [
            "list_for": listFor, //AssignReceived,AssignSend
            "client_secret": Constants.kClientSecret,
            "page": 1,
            "limit": 10000
        ]
        HpAPI.taskUserList.DataAPI(params: params, shouldShowError: false, shouldShowSuccess: false, key: "data") { (response: Result<[MembersDataModel], Error>) in
            DispatchQueue.main.async {
                switch response {
                case .success(let res):
                    let arr = res.map({MembersDataViewModel(data: $0)})
                    completion(arr)
                    break
                case .failure(_):
                    completion([])
                    break
                }
            }
        }
    }
    static func getArchivedTaskList(parameters:[String:Any], completion: @escaping(_ arrData: [GroupedTasksViewModel])->()) {
        
        var params: [String: Any] = parameters
        params["client_secret"] = Constants.kClientSecret
        
        HpAPI.taskArchiveList.DataAPI(params: params, shouldShowError: false, shouldShowSuccess: false, key: nil) { (response: Result<TaskListResponseModel, Error>) in
            DispatchQueue.main.async {
                switch response {
                case .success(let res):
                    let arrResData = res.data ?? []
                    let arr = arrResData.map({GroupedTasksViewModel(data: $0)})
                   // let arr = res.map({TasksViewModel(data: $0)})
//                    let groupedDictionary = Dictionary(grouping: arr) { $0.dateOnly }
//                    let keys = groupedDictionary.keys.sorted(by: {$0 > $1})
//                    let arrData = keys.map{ DateWiseTasks(date: $0.toDateString(dateFormateString: "EEEE dd MMM yyyy"), arrTasks: groupedDictionary[$0]!.sorted(by: {$0.dateCreated.date > $1.dateCreated.date})) }
                    completion(arr)
                    break
                case .failure(_):
                    completion([])
                    break
                }
            }
        }
    }
    static func getCompletedTaskList(search: String, completion: @escaping(_ arrData: [DateWiseTasks])->()) {
        let params: [String: Any] = [
            "client_secret": Constants.kClientSecret,
            "search_key": search,
            "page": 1,
            "limit": 10000
        ]
        HpAPI.completedTaskList.DataAPI(params: params, shouldShowError: false, shouldShowSuccess: false, key: "data") { (response: Result<[TasksModel], Error>) in
            DispatchQueue.main.async {
                switch response {
                case .success(let res):
                    let arr = res.map({TasksViewModel(data: $0)})
                    let groupedDictionary = Dictionary(grouping: arr) { $0.dateOnly }
                    let keys = groupedDictionary.keys.sorted(by: {$0 > $1})
                    let arrData = keys.map{ DateWiseTasks(date: $0.toDateString(dateFormateString: "EEEE dd MMM yyyy"), arrTasks: groupedDictionary[$0]!.sorted(by: {$0.dateCreated.date > $1.dateCreated.date})) }
                    completion(arrData)
                    break
                case .failure(_):
                    completion([])
                    break
                }
            }
        }
    }
    
    static func getScheduledTaskList(completion: @escaping(_ arrData: [WorkSpaceOnlyTasksViewModel])->()) {
        let params: [String: Any] = [
            "client_secret": Constants.kClientSecret,
            "page": 1,
            "limit": 10000
        ]
        HpAPI.taskScheduledList.DataAPI(params: params, shouldShowError: false, shouldShowSuccess: false, key: "data") { (response: Result<[WorkspaceOnlyTaskModel], Error>) in
            DispatchQueue.main.async {
                switch response {
                case .success(let res):
                    let arr = res.map({WorkSpaceOnlyTasksViewModel(data: $0)})
                    completion(arr)
                    break
                case .failure(_):
                    completion([])
                    break
                }
            }
        }
    }
    
    static func getTaskDetails(id: Int, type: String = "task", completion: @escaping(_ taskData: TasksViewModel?)->()) {
        let params: [String: Any] = [
            "id": id,
            "type": type
        ]
        HpAPI.taskDetail.DataAPI(params: params, shouldShowError: false, shouldShowSuccess: false, key: "data") { (response: Result<TasksModel, Error>) in
            DispatchQueue.main.async {
                switch response {
                case .success(let res):
                    let data = TasksViewModel(data: res)
                    completion(data)
                    break
                case .failure(_):
                    completion(nil)
                    break
                }
            }
        }
    }
    
    static func taskRecall(id: Int, message: String, completion: @escaping(_ done: Bool)->()) {
        let params: [String: Any] = [
            "completion_id": id,
            "is_recall_message": message,
            "client_secret": Constants.kClientSecret
        ]
        HpAPI.taskRecall.DataAPI(params: params, shouldShowError: false, shouldShowSuccess: false, key: nil) { (response: Result<GeneralModel, Error>) in
            DispatchQueue.main.async {
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

//MARK: - Get All Chat messages 🔥
extension TasksViewModel {
    static func getAllChatMessagesFirebase(chatNodeId: String, isArchiveDataRequired: Bool = false, completion: @escaping(_ data: [ChatViewModel])->()) {
        let ref = Constants.firebseReference
        ref.child(Constants.taskChatNode).child(chatNodeId).observeSingleEvent(of: .value) { snapshot in
            DispatchQueue.main.async {
                if snapshot.exists() {
                    if let resData = snapshot.value as? [String: Any] {
                        do {
                            let dict = resData.map({$0.value})
                            let data = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
                            let arr = try JSONDecoder().decode([ChatModel].self, from: data)
                            let result = arr.map({ChatViewModel(data: $0)})
                            if isArchiveDataRequired {
                                completion(result)
                            } else {
                                completion(result.filter{$0.isArchivActionAvailable == false})
                            }
                        } catch (let err) {
                            print(err.localizedDescription)
                            completion([])
                        }
                    } else {
                        completion([])
                    }
                } else {
                    completion([])
                }
            }
        }
    }
    
    static func addArchiveTextMessage(chatNodeId: String, isRestore: Bool) {
        guard let userData = HpGlobal.shared.userInfo else { return }
        let ref = Constants.firebseReference
        let timestamp = Date().toMillis()
        let autoId = ref.childByAutoId().key ?? "-"
        
        let chatNodeData: [String: Any] = ["chatId": autoId, "senderId": userData.userId, "timestamp": timestamp, "isRead": false, "taskTitle": userData.fullName, "taskArchiveId": isRestore ? 0 : 1]
        
        ref.child(Constants.taskChatNode).child(chatNodeId).child(autoId).updateChildValues(chatNodeData) { err, reference in
            DispatchQueue.main.async { }
        }
    }
}

struct DateWiseTasks {
    var date: String
    var arrTasks: [TasksViewModel]
}
