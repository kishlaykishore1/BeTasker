//
//  PushNotifyModel.swift
//  BeTasker
//
//  Created by kishlay kishore on 15/04/25.
//

import UIKit

enum PushRedirectType: String {
    case NewTask = "home_page"
    case Chat = "task_tchat"
    case UrgentTask = "task_urgent"
    case WorkspaceList = "workplace_listing"
    case Archive = "archive"
    case none
}

struct PushNotifyModel: Codable {
    var sender_user_id: String?
    var workspace_id: String?
    var task_id: String?
    var order_id: String?
    var user_id: String?
    var receiver_user_id: String?
    var created: String?
    var redirect_type: String?
    var notify_type: String?
    var sound: String?
    var category: String?
    var title: String?
    var url: String?
    var link: String?
    var body: String?
    
    var alert: AlertModel?
    var isFromBackground: Bool? = false
    
    enum CodingKeys: String, CodingKey {
        case sender_user_id
        case workspace_id
        case task_id
        case order_id
        case user_id
        case receiver_user_id
        case created
        case redirect_type
        case notify_type
        case sound
        case category
        case title
        case url
        case link
        case body
        case alert = "aps"
    }
}

final class PushNotifyViewModel {
    
    private let model: PushNotifyModel

    init(model: PushNotifyModel) {
        self.model = model
    }

    var title: String {
        return model.title ?? model.alert?.title ?? "Notification"
    }

    var message: String {
        return model.body ?? model.alert?.body ?? ""
    }

    var redirectType: PushRedirectType {
        if let type = model.redirect_type, type != "" {
            return PushRedirectType(rawValue: type) ?? .none
        }
        return .none
    }
    
    var category: String {
        return model.category ?? ""
    }

    var taskId: String {
        return model.task_id ?? "0"
    }

    var senderId: String {
        return model.sender_user_id ?? "0"
    }

    var receiverId: String {
        return model.receiver_user_id ?? "0"
    }

    var workspaceId: String {
        return model.workspace_id ?? "0"
    }

    var url: String? {
        return model.url?.isEmpty == false ? model.url : model.link
    }

    var notifyType: String? {
        return model.notify_type
    }
    
    var userId: String {
        return model.user_id ?? "0"
    }

    var isFromBackground: Bool {
        return model.isFromBackground ?? false
    }
}

