//
//  NotificationModel.swift
//  Chrono Green
//
//  Created by MACMINI on 30/06/21.
//

import UIKit

enum NotifyType: String {
    case GroupNotification
    case ProgrammeNotification
    case GroupMember
    case adminNotify
    case NewTask
    case AssignTaskComplete
    case AssignTaskRecall
    case none
}

struct NotificationDataModel: Codable {
    var notification_list: [NotificationModel]?
    var notification_application_list: NotificationModel?
    var total: Int?
}

struct NotificationModel: Codable {
    var alert: AlertModel?
    var created: String?
    var status: Bool?
    var isFromBackground: Bool? = false
    
    var notify_type: String? // = "notify_type_chat_one_to_one";
    var sound: String? // = default;
    var token: String? // = "";
    var total_unread_count: Int? // = 141;
    var url: String? // = "";
    var common_id: Int?
    var invite_id: Int?
    var group_id: Int?
    var related_id: Int?
}

struct AlertModel: Codable {
    var body: String?
    var title: String?
}

final class NotificationViewModel {
    private var data = NotificationModel()
    init(data: NotificationModel) {
        self.data = data
    }
    var status: Bool {
        get {
            return data.status ?? false
        }
        set {
            data.status = newValue
        }
    }
    var inviteId: Int {
        return data.invite_id ?? 0
    }
    var groupId: Int {
        return data.group_id ?? 0
    }
    
    var relatedId: Int {
        return data.related_id ?? 0
    }
    
    var notifyType: NotifyType {
        if let type = data.notify_type, type != "" {
            return NotifyType(rawValue: type) ?? .none
        }
        return .none
    }
    
    var message: String {
        return data.alert?.body ?? ""
    }
    var title: String {
        return data.alert?.title ?? ""
    }
    var created: String {
        if let dt = data.created {
            return Global.GetFormattedDate(dateString: dt, currentFormate: "yyyy-MM-dd'T'HH:mm:ssZZZZ", outputFormate: "EEEE dd MMM yyyy · HH'h'mm", isInputUTC: true, isOutputUTC: false).dateString ?? ""
        }
        return ""
    }
    
    var url: URL? {
        return data.url?.makeUrl()
    }
    
    
    var commonId: Int {
        return data.common_id ?? 0
    }
    
    var token: String {
        return data.token ?? ""
    }
    var totalUnreadCount: Int {
        return data.total_unread_count ?? 0
    }
    
    
    //⭐
    var isFromBackground: Bool {
        get {
            return data.isFromBackground ?? false
        }
        set {
            data.isFromBackground = newValue
        }
    }

    
    static func GetNotificationsList(refreshControl: UIRefreshControl?, pageNumber: Int, completion: @escaping(_ data: [NotificationViewModel],_ total: Int)->()) {
        let params: [String: Any] = [
            "lc": Constants.lc,
            "device_type": Constants.kDeviceType,
            "page_no": pageNumber
        ]
        DispatchQueue.main.async {
            if pageNumber == 1 {
            //Global.showLoadingSpinner()
            }
        }
        HpAPI.notificationList.DataAPI(params: params, shouldShowError: false, shouldShowSuccess: false, key: "data") { (response: Result<NotificationDataModel, Error>) in
            DispatchQueue.main.async {
                Global.dismissLoadingSpinner()
                refreshControl?.endRefreshing()
                switch response {
                case .success(let data):
                    let arrNotifications = data.notification_list?.map({return NotificationViewModel(data: $0)})
                    completion(arrNotifications ?? [], data.total ?? 0)
                case .failure(_):
                    completion([], 0)
                }
            }
        }
    }

    
}
