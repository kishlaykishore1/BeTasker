//
//  ChatModel.swift
//  teamAlerts
//
//  Created by B2Cvertical A++ on 21/01/25.
//

import Foundation

enum EnumChatType: String {
    case taskDescription
    case message
    case image
    case video
    case pdf
    case status
}

struct ChatModel: Codable {
    var chatId: String?
    var message: String?
    var receiverId: Int?
    var senderId: Int?
    var timestamp: Double?
    var chatType: String?
    var fullName: String?
    var userImage: String?
    var imageURL: String?
    var pdfName: String?
    var pdfSize: Double?
    var arrFiles: [FileModel]?
    var taskStatusId: Int?
    var taskArchiveId: Int?
    var taskTitle: String?
    var description: String?
    var displayLink: String?
    var color_code: String?
    var notExists: Bool?
    var tempID: String?
    var latestImageData: Data?
    var isRead: Bool?
    var isEdited: Bool?
    var readBy: [String]?
    var mentionIds: [String]?
    var isExpanded: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case chatId
        case message
        case receiverId
        case senderId
        case timestamp
        case chatType
        case fullName
        case userImage
        case imageURL
        case pdfName
        case pdfSize
        case arrFiles
        case taskStatusId
        case taskArchiveId
        case taskTitle
        case description
        case displayLink
        case color_code
        case notExists
        case tempID
        case latestImageData
        case isRead
        case isEdited
        case readBy
        case mentionIds
    }
}

struct ChatViewModel {
    private var data = ChatModel()
    init(data: ChatModel) {
        self.data = data
    }
    var chatId: String {
        return data.chatId ?? ""
    }
    
    var message: String {
        get {
            return data.message ?? ""
        }
        set {
            data.message = newValue
        }
    }
    var colorCode: String {
        return data.color_code ?? ""
    }
    var colorValue: UIColor {
        return UIColor(hexString: colorCode)
    }
    
    var tempId: String? {
        get {
            return data.tempID ?? ""
        }
        set {
            data.tempID = newValue
        }
    }
    
    var mentionedUserIds: [String] {
        get {
            return data.mentionIds ?? []
        }
        set {
            data.mentionIds = newValue
        }
    }
    
    var title: String {
        return data.taskTitle ?? ""
    }
    
    var description: String {
        return data.description ?? ""
    }
    
    var displayLink: String {
        return data.displayLink ?? ""
    }
    
    var arrFiles: [FileModel] {
        return data.arrFiles ?? []
    }
    
    var arrImages: [FileViewModel] {
        if let arr = data.arrFiles {
            return arr.map({FileViewModel(data: $0)})
        }
        return []
    }
    
    var readBy: [String] {
        get {
            return data.readBy ?? []
        }
        set {
            data.readBy = newValue
        }
    }
    
    var isExpanded: Bool {
        get {
            return data.isExpanded
        }
        set {
            data.isExpanded = newValue
        }
    }
    
    var taskStatusId: Int {
        return data.taskStatusId ?? 0
    }
    
    var isStatusUpdate: Bool {
        return data.taskStatusId != nil
    }
    
    var isArchivActionAvailable: Bool {
        return data.taskArchiveId != nil
    }
    
    var taskArchiveId: Int? {
        return data.taskArchiveId
    }
    
    var isRead: Bool {
        return data.isRead ?? false
    }
    
    var isEdited: Bool {
        return data.isEdited ?? false
    }
    
    var chatType: EnumChatType {
        return EnumChatType(rawValue: data.chatType ?? "") ?? .message
    }
    
    var fullName: String {
        get {
            return data.fullName ?? ""
        }
        set {
            data.fullName = newValue
        }
    }
    var userImage: String? {
        get {
            return data.userImage ?? ""
        }
        set {
            data.userImage = newValue
        }
    }
    var userPicURL: URL? {
        return data.userImage?.makeUrl()
    }
    var imageURL: URL? {
        return data.imageURL?.makeUrl()
    }
    var pdfName: String {
        return data.pdfName ?? ""
    }
    var pdfSize: String {
        return "\(data.pdfSize ?? 0) MB"
    }
    var imageData: Data? {
        return data.latestImageData
    }
    var notExists: Bool {
        get {
            return data.notExists ?? false
        }
        set {
            data.notExists = newValue
        }
    }
    var receiverId: Int {
        return data.receiverId ?? 0
    }
    var senderId: Int {
        return data.senderId ?? 0
    }
    var isMine: Bool {
        return senderId == HpGlobal.shared.userInfo?.userId
    }
    
    var timestamp: Double {
        return data.timestamp ?? 0
    }
    
    var chatDate: (date: Date?, dateString: String?) {
        //let date = Date(milliseconds: Int(timestamp))
        //return Global.GetFormattedDate(date: date, outputFormate: "dd MMM yyyy • HH:mm", isInputUTC: true, isOutputUTC: false)
        let localDate = Date.fromUTCTimestampInMillis(Int64(timestamp))
        let localDateString = localDate.toLocalString(format: "dd MMM yyyy • HH:mm")
        return (date: localDate, dateString: localDateString)
    }
    var chatDateOnly: Date {
        let date = Date(milliseconds: Int(timestamp))
        return Global.GetFormattedDate(date: date, outputFormate: "dd MMM yyyy", isInputUTC: true, isOutputUTC: false).date ?? Date()
    }
    var chatTimeOnly: String {
        //let date = Date(milliseconds: Int(timestamp))
        //return Global.GetFormattedDate(date: date, outputFormate: "HH:mm", isInputUTC: true, isOutputUTC: false).dateString ?? ""
        let localDate = Date.fromUTCTimestampInMillis(Int64(timestamp))

        // Convert the Date to a local time string
        let localDateString = localDate.toLocalString(format: "HH:mm")
        return localDateString
    }
    var chatDateTime: Date {
        let date = Date(milliseconds: Int(timestamp))
        return Global.GetFormattedDate(date: date, outputFormate: "dd MMM yyyy HH:mm:ss", isInputUTC: true, isOutputUTC: false).date ?? Date()
    }
    
    static func == (lhs: ChatViewModel, rhs: ChatViewModel) -> Bool {
        return lhs.tempId != nil && lhs.tempId == rhs.tempId
    }
    
}

struct ChatStatusModel: Codable {
    var id: Int?
    var statusTitle: String?
    var timestamp: Double?
    var arrFiles: [FileModel]?
    var senderId: Int?
    var color_code: String?
    var archiveId: Int?
    var isArchive: Bool?
}

struct ChatStatusHistoryViewModel {
    private var data = ChatStatusModel()
    
    init(data: ChatStatusModel) {
        self.data = data
    }
    
    var statusId: Int {
        return data.id ?? 0
    }
    
    var statusMessage: String {
        get {
            return data.statusTitle ?? ""
        }
        set {
            data.statusTitle = newValue
        }
    }
    
    var timestamp: Double {
        return data.timestamp ?? 0
    }
    
    var statusDateTime: (date: Date?, dateString: String?) {
        let localDate = Date.fromUTCTimestampInMillis(Int64(timestamp))
        let localDateString = localDate.toLocalString(format: "dd MMM yyyy • HH:mm")
        return (date: localDate, dateString: localDateString)
    }
    
    var chatDateTime: Date {
        let date = Date(milliseconds: Int(timestamp))
        return Global.GetFormattedDate(date: date, outputFormate: "dd MMM yyyy HH:mm:ss", isInputUTC: true, isOutputUTC: false).date ?? Date()
    }
    
    var arrImages: [FileViewModel] {
        if let arr = data.arrFiles {
            return arr.map({FileViewModel(data: $0)})
        }
        return []
    }
    
    var senderId: Int {
        return data.senderId ?? 0
    }
    
    var colorCode: String {
        return data.color_code ?? ""
    }
    
    var colorValue: UIColor {
        return UIColor(hexString: colorCode)
    }
    
    var archiveId: Int {
        return data.archiveId ?? 0
    }
    
    var isArchive: Bool {
        return data.isArchive ?? false
    }
    
}


struct ChatReadStatusModel: Codable {
    var status: [String: Bool]
    
    init(status: [String: Bool]) {
        self.status = status
    }
}
