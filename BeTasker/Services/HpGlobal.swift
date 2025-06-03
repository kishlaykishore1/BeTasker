//
//  HpGlobal.swift
//

import UIKit

class HpGlobal: NSObject {
    static let shared = HpGlobal()

    var latitude: Double = 0
    var longitude: Double = 0
    var userInfo: ProfileDataViewModel?
    var settingsData: GeneralSettingsViewModel? = SettingDataCache.get()
    var isForceupdateShown = false
    var selectedWorkspace: WorkSpaceDataViewModel?
    var notificationData: NotificationModel = NotificationModel()
    var pushNotificationData: PushNotifyModel = PushNotifyModel()
    var registrationData: ProfileDataViewModel?
    var roomCreationData = RoomRegistrationViewModel(data: RoomRegistrationModel())
    var programCreationData = ProgramScheduleRegistrationViewModel()
    var programTemplateCreationData = TemplateRegistrationViewModel()
}

extension Notification.Name {
    static let updateProfile = Notification.Name("updateProfile")
    static let stopPlayer = Notification.Name("stopPlayer")
    static let stopSearchCollTimer = Notification.Name("stopSearchCollTimer")
    static let updateList = Notification.Name("updateList")
    static let updateHomeTab = Notification.Name(rawValue: "updateHomeTab")
    static let appNotification = Notification.Name(rawValue: "appNotification")
    static let videoNotification = Notification.Name(rawValue: "videoNotification")
    static let deeplinkNotification = Notification.Name("deeplinkNotification")
    static let updateRoomList = Notification.Name("updateRoomList")
    static let updateTemplateList = Notification.Name("updateTemplateList")
    static let updateProgramList = Notification.Name("updateProgramList")
    static let updateEquipmentList = Notification.Name("updateEquipmentList")
    static let updateMembersList = Notification.Name("updateMembersList")
    static let updateNotificationList = Notification.Name("updateNotificationList")
    static let updateReportList = Notification.Name("updateReportList")
    static let groupMembersNotification = Notification.Name("groupMembersNotification")
    static let workspaceSelectedNotification = Notification.Name("workspaceSelectedNotification")
    static let updateTaksList = Notification.Name("updateTaksList")
    static let updateTaskChat = Notification.Name("updateTaskChat")
    static let updateTaskMembersList = Notification.Name("updateTaskMembersList")
    static let receivedArchiveNotification = Notification.Name("archiveNotify")
    static let taskUpdatedNotification = Notification.Name("taskUpdatedNotification")
}


