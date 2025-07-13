
import UIKit
import Foundation
import Alamofire
import AVFoundation
import Firebase

var player: AVAudioPlayer?

enum MimeType: String {
    case video = "video/mp4"
    case audio = "audio/m4a"
    case image = "image/jpeg"
    case pdf = "application/pdf"
}

enum ReportTypes: String {
    case bugReport = "BugReport"
}

enum ErrorTypesAPP: Error {
    case noInternet
    case somethingWentWrong
    case notActive
    case notRegistered
    case tokenExpired
    case decodingError
    case unauthenticate
}

class HelperCheckInternetAPI: NSObject
{
    class func isConnectedToInternet() -> Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}

enum HpAPI: String {
    
    var baseURL: String {
        //return "https://easyac.55.agency/demo/api/v1/" //DEMO
        //return "https://admin.teamalerts.app/demo/api/v1/" //Demo
        return "https://admin.teamalerts.app/api/v2/" // Version 2 Prod
        //return "https://admin.teamalerts.app/api/v1/" //Prod
    }
    
    var apiURL: String {
        if self.rawValue == "TOKEN" {
            return "\(baseURL)oauth/token"
        }
        return "\(baseURL)\(self.rawValue)"
    }
    
    case STATIC                     = ""
    case SETTINGDATA                = "settings/settingData"
    case SOCIALLOGIN                = "login/social-login-chk" //Used to get Access Token (login)
    case REGISTER                   =  "users/register" //"recruteurs/register"
    case EDITSETTING                = "users/edit-setting" //Edit profile
    case GETPROFILE                 = "users/view-profile"
    case QRLOGIN                    = "users/verify-qr-login" //For QR Login or Link Devices
   
    case DELETEACCOUNT              = "users/delete-user-account"
    case LOGOUT                     = "users/logout"
    case UNBLOCKUSERS               = "users/unblock-all-user"
    case NOTIFICATIONSETTING        = "settings/notification-settings"
    
    case SENDMAIL                   = "admin-reports/send-mail" //Bug Report - bug_report
    
    case FAQLIST                    = "faqs/faq-list"
    
    case USERSTATUSCHK              = "users/user-status-chk" //update user lat/lng
    
    case notificationList = "notifications/notification-list"
    
    case colorList = "colors/color-list"
    case iconList = "icons/icon-list"
    case myEquipments = "equipments/my-equipments"
    case equipmentsCreate = "equipments/create"
    case equipmentsDelete = "equipments/delete"
    case equipmentsUpdate = "equipments/update"
    
    case roomsCreateUpdate = "rooms/create-or-update"
    case myRooms = "rooms/my-rooms"
    case roomsDelete = "rooms/delete"
    case roomSettings = "room-settings/get-room-settings"
    case updateRoomSetting = "room-settings/update-room-setting"
    case roomWithoutEquipmentList = "rooms/room-with-out-equipment-list"
    case repositionRooms = "rooms/reposition"
    
    case getSystemSettings = "systems/get-systems"
    case updateSystem = "systems/update-system"
    
    case programsCreateUpdate = "programs/create-or-update"
    case myPrograms = "programs/my-programs"
    
    case plansCreateUpdate = "plans/create-or-update"
    case myPlans = "plans/my-plans"
    
    case membersSearch = "members/search"
    case membersList = "members/member-list"
    case inviteMember = "members/invite-member"
    case addMember = "members/member-create-update"
    case resendInvitation = "members/resend-invitation"
    case acceptRejectRequest = "members/accept-or-reject-request"
    case membersDelete = "members/delete"
    case deviceChat = "user-chats/device-chat"
    
    case uploadImages = "settings/uploadImages"
    case uploadSignupProfile = "settings/upload-profile-images"
    
    ////////////////////////////////
    
    case getGroupList = "groups/get-group-list"
    case addEditGroup = "groups/add-edit-group"
    case deleteGroup = "groups/delete-group"
    
    case myTemplates = "templates/my-templates"
    case myProgramTemplates = "templates/my-programs"
    case addEditTemplate = "templates/add-edit-template"
    case deleteTemplate = "templates/delete-template"
    case templateSortOrder = "templates/template-sort-order"
    case templateProgramIsActive = "templates/program-is-active"
    
    case getNotification = "group-notifications/get-notification"
    case groupNotificationsCreate = "group-notifications/create-or-update"
    
    case getReport = "reports/get-report"
    case reportCreate = "reports/create-or-update"
    
    case allTemplates = "templates/all-templates"
    
    case taskCreateUpdate = "task/create-or-update"
    case taskList = "task/task-list"
    case taskDetail = "task/details"
    case taskCompletion = "task/completion"
    case completedTaskList = "task/completed-task-list"
    case taskRecall = "task/recall"
    case taskScheduledList = "task/task-scheduled-list"
    case taskUserList = "task/task-user-list"
    case statusList = "status/status-list"
    case homeStatusList = "status/home-status-list"
    case taskStatusUpdate = "task/task-status-update"
    case taskPrioritySchedule = "task/task-send-now"
    
    case workSpaceCreateUpdate = "workspaces/create-or-update"
    case workSpaceList = "workspaces/list"
    case workSpaceMyList = "workspaces/my-list"
    case workSpacemembersList = "workspaces/member-list"
    case workSpaceDelete = "workspaces/delete"
    case workSpaceDetails = "workspaces/details"
    case taskArchiveRestore = "task/archive-restore"
    case taskReminder = "task/task-reminder"
    case taskArchiveDelete = "task/delete"
    case taskArchiveList = "task/archive-list"
    case userPremium     = "users/premium"
    case chatNotify      = "task/chat-notify"
    case updateTaskNotification = "task/update-task-notification-setting"
    //MARK: - Generic Function to fetch/Post data from API
    func DataAPI<T: Decodable>(params: [String: Any], shouldShowError: Bool, shouldShowSuccess: Bool, shouldShowInfo: Bool = false, key: String?, completion: @escaping (Result<T, Error>) ->()) {
        
        var headers: HTTPHeaders = [
            "lc": Constants.lc
        ]
        if let token = Constants.getAPITokens().accessToken {
            headers["Authorization"] = "Bearer \(token)"
        }
        
        var params: [String: Any] = params
        
        if let info = Bundle.main.infoDictionary, let currentVersion = info["CFBundleShortVersionString"] as? String {
            params["app_version"] = currentVersion
        }
        params["app_id"] = Constants.kAppId
        
        print("🔸API:-", apiURL)
        print("🔸Params:-", params)
        print("🔸Header:-", headers)
        

        if !HelperCheckInternetAPI.isConnectedToInternet() {
            if shouldShowError {
                Common.showAlertMessage(message: Messages.ProblemWithInternet, alertType: .error)
            }
            completion(.failure(ErrorTypesAPP.noInternet))
            return
        }
        
        let manager = Alamofire.Session.default
        //manager.session.configuration.timeoutIntervalForRequest = 300
        //manager.session.configuration.httpMaximumConnectionsPerHost = 100
        
        manager.request(apiURL, method: .post, parameters: params, encoding: URLEncoding.default, headers: headers).responseJSON
        { (response: DataResponse) in
            DispatchQueue.main.async {
                print("🔵🔵🔵:\(self.apiURL):🔵🔵🔵", response.result)
                switch (response.result) {
                case .success:
                    if let successCode  = response.response?.statusCode {
                        if let JSON = response.value as? [String: AnyObject] {
                            
                            var errorType = ErrorTypesAPP.somethingWentWrong
                            var message = ""
                            if let msg = JSON["message"] as? String {
                                message = msg
                            }
                            
                            switch successCode {
                            case 200:
                                do {
                                    var resData: AnyObject?
                                    if let key = key {
                                        resData = JSON[key]
                                    } else {
                                        resData = JSON as AnyObject
                                    }
                                    if let resData = resData {
                                        let data = try JSONSerialization.data(withJSONObject: resData, options: .prettyPrinted)
                                        let result = try JSONDecoder().decode(T.self, from: data)
                                        if shouldShowSuccess {
                                            Common.showAlertMessage(message: message, alertType: .success)
                                        }
                                        if shouldShowInfo && !message.isEmpty {
                                            Common.showAlertMessage(message: message, alertType: .info)
                                        }
                                        completion(.success(result))
                                    } else {
                                        if shouldShowError {
                                            Common.showAlertMessage(message: message, alertType: .error)
                                        }
                                        completion(.failure(ErrorTypesAPP.somethingWentWrong))
                                    }
                                } catch (let err) {
                                    print("❌❌❌❌❌", err)
                                    completion(.failure(ErrorTypesAPP.decodingError))
                                }
                            case 401:
                                if let msg = JSON["error"] as? String {
                                    message = msg
                                }
                                if let active = JSON["active"] as? Bool { //, active == true
                                    errorType = .notActive
                                    if active == false {
                                        Common.showAlertMessage(message: message, alertType: .error)
                                    }
                                    //if active == false {
                                    self.apiLogoutUser()
                                    //}
                                }
                                if let msg = JSON["error"] as? String {
                                    message = msg
                                    if msg.contains("Unauthenticated") {
                                        errorType = .unauthenticate
                                    }
                                }
                                if let tokenExpired = JSON["refresh_token"] as? Bool, tokenExpired == true {
                                    errorType = .tokenExpired
                                }
                                if let registered = JSON["is_register"] as? Bool, registered == false {
                                    errorType = .notRegistered
                                }
                                if shouldShowError {
                                    Common.showAlertMessage(message: message, alertType: .error)
                                }
                                completion(.failure(errorType))
                            default:
                                completion(.failure(ErrorTypesAPP.somethingWentWrong))
                            }
                        }
                    }
                    
                case .failure(let error):
                    print("🔴API FAILURE🔴", self.apiURL)
                    print(response.response ?? "")
                    var message = ""
                    var errorType = ErrorTypesAPP.somethingWentWrong
                    if error._code == NSURLErrorTimedOut {
                        message = Messages.NetworkError
                        errorType = .noInternet
                    } else {
                        message = Messages.somethingWentWrong
                        errorType = .somethingWentWrong
                    }
                    if shouldShowError {
                        Common.showAlertMessage(message: message, alertType: .error)
                    }
                    completion(.failure(errorType))
                }
            }
        }
        
        
    }
    
    //MARK: - Upload pic
    func requestUpload<T: Decodable>(params: [String: Any]? = nil, files: [String: Any]? = nil, imgDataDict: [String: Data?] = [:], shouldShowError: Bool, shouldShowSuccess: Bool, key: String?, completion: @escaping (Result<T, Error>) ->()) {
        
        var headers: HTTPHeaders = [
            "lc": Constants.lc
        ]
        if let token = Constants.getAPITokens().accessToken {
            headers["Authorization"] = "Bearer \(token)"
        }
        
        var params: [String: Any] = params ?? [:]
        
        if let info = Bundle.main.infoDictionary, let currentVersion = info["CFBundleShortVersionString"] as? String {
            params["app_version"] = currentVersion
        }
        params["app_id"] = Constants.kAppId
        
        print("🔸API:-", apiURL)
        print("🔸Params:-", params)
        print("🔸Header:-", headers)
        
        AF.upload( multipartFormData:
                    { multipartFormData in
            // Attach image
            if let files = files {
                for (key, value) in files {
                    if let getImage = value as? UIImage {
                        let imageData = getImage.jpegData(compressionQuality: 0.5)
                        multipartFormData.append(imageData!, withName: key, fileName: "\(key).jpg", mimeType: "image/jpg")
                        
                        print("\(key).jpg")
                    } else if let getAudioUrl = value as? Data {
                        
                        // multipartFormData.append(songData_ as Data, withName: "audio", fileName: songName, mimeType: "audio/m4a")
                        
                        multipartFormData.append(getAudioUrl, withName: key, fileName: "\(key).m4a", mimeType: "audio/m4a")
                    }
                }
            } else {
                for (key, value) in imgDataDict {
                    if let imgData = value {
                        multipartFormData.append(imgData, withName: key, fileName: "user.jpg", mimeType: "image/jpeg")
                    }
                }
            }
            
            for (key, value) in params ?? [:]
            {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
        },to: apiURL , method: .post , headers: headers).responseJSON
        { (response: DataResponse) in
            print("🔵🔵🔵:\(self.apiURL):🔵🔵🔵", response.result)
            switch (response.result) {
            case .success:
                if let successCode  = response.response?.statusCode{
                    if let JSON = response.value as? [String: AnyObject] {
                        
                        var errorType = ErrorTypesAPP.somethingWentWrong
                        var message = ""
                        if let msg = JSON["message"] as? String {
                            message = msg
                        }
                        
                        switch successCode {
                        case 200:
                            do {
                                var resData: AnyObject?
                                if let key = key {
                                    resData = JSON[key]
                                } else {
                                    resData = JSON as AnyObject
                                }
                                if let resData = resData {
                                    let data = try JSONSerialization.data(withJSONObject: resData, options: .prettyPrinted)
                                    let result = try JSONDecoder().decode(T.self, from: data)
                                    if shouldShowSuccess {
                                        Common.showAlertMessage(message: message, alertType: .success)
                                    }
                                    completion(.success(result))
                                } else {
                                    if shouldShowError {
                                        Common.showAlertMessage(message: message, alertType: .error)
                                    }
                                    completion(.failure(ErrorTypesAPP.somethingWentWrong))
                                }
                            } catch (let err) {
                                print("❌❌❌❌❌", err)
                                completion(.failure(ErrorTypesAPP.decodingError))
                            }
                        case 401:
                            if let msg = JSON["error"] as? String {
                                message = msg
                            }
                            if let active = JSON["active"] as? Bool { //, active == true
                                errorType = .notActive
                                if active == false {
                                    Common.showAlertMessage(message: message, alertType: .error)
                                }
                                //if active == false {
                                self.apiLogoutUser()
                                //}
                            }
                            if let msg = JSON["error"] as? String {
                                message = msg
                                if msg.contains("Unauthenticated") {
                                    errorType = .unauthenticate
                                }
                            }
                            if let tokenExpired = JSON["refresh_token"] as? Bool, tokenExpired == true {
                                errorType = .tokenExpired
                            }
                            if let registered = JSON["is_register"] as? Bool, registered == false {
                                errorType = .notRegistered
                            }
                            if shouldShowError {
                                Common.showAlertMessage(message: message, alertType: .error)
                            }
                            completion(.failure(errorType))
                        default:
                            completion(.failure(ErrorTypesAPP.somethingWentWrong))
                        }
                        
                    }
                    
                }
                
            case .failure(let error):
                print("🔴API FAILURE🔴", self.apiURL)
                var message = ""
                var errorType = ErrorTypesAPP.somethingWentWrong
                if error._code == NSURLErrorTimedOut {
                    message = Messages.ProblemWithInternet
                    errorType = .noInternet
                } else {
                    message = Messages.somethingWentWrong
                    errorType = .somethingWentWrong
                }
                if shouldShowError {
                    Common.showAlertMessage(message: message, alertType: .error)
                }
                completion(.failure(errorType))
            }
        }
    }
    
    //MARK: - Upload with progress
    func requestUploadProgress<T: Decodable>(params: [String: Any]? = nil, fileOrgName: String? = nil, files: [String: Data?]? = nil, mimeType: MimeType, shouldShowError: Bool, shouldShowSuccess: Bool, key: String?, completion: @escaping (Result<T, Error>) ->()) {
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(Constants.getAPITokens().accessToken ?? "")",
            "lc": Constants.lc
        ]
        var params: [String: Any]? = params
        
        if let info = Bundle.main.infoDictionary, let currentVersion = info["CFBundleShortVersionString"] as? String {
            params?["app_version"] = currentVersion
        }
        params?["app_id"] = Constants.kAppId
        print("🔸API:-", apiURL)
        print("🔸Header:-", headers)
        print("🔸Parameters:-", params ?? [:])
        
        AF.upload( multipartFormData: { multipartFormData in
            // Attach files
            if let files = files {
                for (key, value) in files {
                    if let fileData = value {
                        var fileName = ""
                        switch mimeType {
                        case .video:
                            fileName = "\(UUID().uuidString).mp4"
                        case .audio:
                            fileName = "\(UUID().uuidString).m4a"
                        case .image:
                            fileName = "\(UUID().uuidString).jpg"
                        case .pdf:
                            fileName = fileOrgName != nil ? fileOrgName! : "\(UUID().uuidString).pdf"
                        }
                        multipartFormData.append(fileData, withName: key, fileName: fileName, mimeType: mimeType.rawValue)
                    }
                }
            }
            
            for (key, value) in params ?? [:] {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
        }, to: apiURL , method: .post , headers: headers).uploadProgress(closure: { progress in
            print("===============>", progress.fractionCompleted)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "percentageUploaded"), object:["percentage": progress.fractionCompleted])
        }).responseJSON { (response: DataResponse) in
            print("🔵🔵🔵:\(self.apiURL):🔵🔵🔵", response.result)
            switch (response.result) {
            case .success:
                if let successCode  = response.response?.statusCode{
                    if let JSON = response.value as? [String: AnyObject] {
                        
                        var errorType = ErrorTypesAPP.somethingWentWrong
                        var message = ""
                        if let msg = JSON["message"] as? String {
                            message = msg
                        }
                        
                        switch successCode {
                        case 200:
                            do {
                                var resData: AnyObject?
                                if let key = key {
                                    resData = JSON[key]
                                } else {
                                    resData = JSON as AnyObject
                                }
                                if let resData = resData {
                                    let data = try JSONSerialization.data(withJSONObject: resData, options: .prettyPrinted)
                                    let result = try JSONDecoder().decode(T.self, from: data)
                                    if shouldShowSuccess {
                                        Common.showAlertMessage(message: message, alertType: .success)
                                    }
                                    completion(.success(result))
                                } else {
                                    if shouldShowError {
                                        Common.showAlertMessage(message: message, alertType: .error)
                                    }
                                    completion(.failure(ErrorTypesAPP.somethingWentWrong))
                                }
                            } catch (let err) {
                                print("❌❌❌❌❌", err)
                                completion(.failure(ErrorTypesAPP.decodingError))
                            }
                        case 401:
                            if let msg = JSON["error"] as? String {
                                message = msg
                            }
                            if let active = JSON["active"] as? Bool {
                                errorType = .notActive
                                if active == false {
                                    Common.showAlertMessage(message: message, alertType: .error)
                                }
                                self.apiLogoutUser()
                            }
                            if let msg = JSON["error"] as? String {
                                message = msg
                            }
                            if let tokenExpired = JSON["refresh_token"] as? Bool, tokenExpired == true {
                                errorType = .tokenExpired
                            }
                            if let registered = JSON["is_register"] as? Bool, registered == false {
                                errorType = .notRegistered
                            }
                            if shouldShowError {
                                Common.showAlertMessage(message: message, alertType: .error)
                            }
                            completion(.failure(errorType))
                        default:
                            completion(.failure(ErrorTypesAPP.somethingWentWrong))
                        }
                        
                    }
                    
                }
                
            case .failure(let error):
                print("🔴🔴🔴🔴🔴🔴API FAILURE🔴🔴🔴🔴🔴🔴", self.apiURL)
                var message = ""
                var errorType = ErrorTypesAPP.somethingWentWrong
                if error._code == NSURLErrorTimedOut {
                    message = Messages.ProblemWithInternet
                    errorType = .noInternet
                } else {
                    message = Messages.somethingWentWrong
                    errorType = .somethingWentWrong
                }
                if shouldShowError {
                    Common.showAlertMessage(message: message, alertType: .error)
                }
                completion(.failure(errorType))
            }
        }
    }
    
    //MARK: - SettingData
    func apiGeneralSettingData(showloader: Bool = false, completion: @escaping(_ completed: Bool)->()) {
        
        let params: [String: Any] = [
            "device_type": Constants.kDeviceType,
            "device_id": Constants.UDID,
            "device_token": Constants.kFCMToken, //Constants.kDeviceToken
            "client_secret": Constants.kClientSecret,
            "app_id": Constants.kAppId
        ]
        
        DispatchQueue.main.async {
            if showloader {
                Global.showLoadingSpinner()
            }
        }
        
        HpAPI.SETTINGDATA.DataAPI(params: params, shouldShowError: false, shouldShowSuccess: false, key: "data") { (response: Result<SettingModel, Error>) in
            DispatchQueue.main.async {
                if showloader {
                    Global.dismissLoadingSpinner()
                }
                switch response {
                case .failure(let error):
                    if let err = error as? ErrorTypesAPP {
                        switch err {
                        case .unauthenticate:
                            self.apiLogoutUser()
                        default:
                            break
                        }
                    }
                case .success(let data):
                    SettingDataCache.save(data.setting_data ?? GeneralSettingsModel())
                    let dataSetting = SettingViewModel(data: data)
                    HpGlobal.shared.settingsData = dataSetting.settings
                    completion(true)
                }
            }
        }
    }
    
    //MARK: - Logout
    func apiLogoutUser() {
        let queue = DispatchQueue(label: "com.insidejobrh.LogoutUser", qos: .userInteractive, attributes: .concurrent)
        queue.async {
            let params: [String: Any] = [
                "device_type": Constants.kDeviceType,
                "device_id": Constants.UDID,
                "device_token": Constants.kFCMToken, //Constants.kDeviceToken
                "client_secret": Constants.kClientSecret,
                "app_id": Constants.kAppId
            ]
            DispatchQueue.main.async {
                Global.showLoadingSpinner()
            }
            HpAPI.LOGOUT.DataAPI(params: params, shouldShowError: false, shouldShowSuccess: false, key: nil) { (response: Result<[String: String], Error>) in
                DispatchQueue.main.async {
                    Global.dismissLoadingSpinner()
                    clearLogoutDataFromApp()
                }
            }
        }
    }
    
    func clearLogoutDataFromApp() {
        Global.clearAllAppUserDefaults()
        Constants.removeAPITokens()
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    
    
    //MARK: - Update location
    func apiUpdateLocation(lat: Double, lng: Double, isForeground: Bool) {
        guard Constants.getAPITokens().accessToken != nil else { return }
        let queue = DispatchQueue(label: "com.insidejobrh.UpdateLocation", qos: .background, attributes: .concurrent)
        queue.async {
            let params: [String: Any] = [
                "device_type": Constants.kDeviceType,
                "device_id": Constants.UDID,
                "device_token": Constants.kFCMToken, //Constants.kDeviceToken
                //"voip_token": Constants.VOIPTOKEN,
                "client_secret": Constants.kClientSecret,
                "app_id": Constants.kAppId,
                "latitude": lat,
                "longitude": lng,
                "is_using_app": "1",
                "is_foreground": isForeground == true ? 1 : 0,
                "user_time_zone": TimeZone.current.identifier
            ]
            HpAPI.USERSTATUSCHK.DataAPI(params: params, shouldShowError: false, shouldShowSuccess: false, key: nil) { (response: Result<[String: String], Error>) in
                DispatchQueue.main.async {
                    switch response {
                    case .failure(_):
                        break
                    case .success(_):
                        break
                    }
                }
            }
        }
    }
    
}

extension UIViewController {
    func playSound(name: String, ext: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .duckOthers)
            try AVAudioSession.sharedInstance().setActive(true)

            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)

            /* iOS 10 and earlier require the following line:
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */

            guard let player = player else { return }
            player.numberOfLoops = -1
            player.play()

        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func stopSound() {
        player?.stop()
        player = nil
    }
    
    //MARK: - Login - to get access token
    func Login(uid: String, dialCode: String, phoneNumber: String, socialType: SocialType, completion: @escaping(_ data: LoginRegisterViewModel?,_ error: ErrorTypesAPP?)->()) {
        var params: [String: Any] = [
            "device_token": Constants.kFCMToken, //Constants.kDeviceToken
            "lc": Constants.lc,
            "device_id": Constants.UDID,
            "device_type": Constants.kDeviceType,
            "client_id": "6",
            "grant_type": "password",
            "client_secret": Constants.kClientSecret,
            "social_type": socialType.rawValue,
            "national_number": dialCode,
            "mobile": phoneNumber.replacingOccurrences(of: " ", with: "")
        ]
        switch socialType {
        case .Facebook:
            params["facebook_user_id"] = uid
        case .Apple:
            params["apple_user_id"] = uid
        case .Google:
            params["google_user_id"] = uid
        case .DeviceId:
            params["dudid"] = uid
        }
        DispatchQueue.main.async {
            Global.showLoadingSpinner()
        }
        HpAPI.SOCIALLOGIN.DataAPI(params: params, shouldShowError: true, shouldShowSuccess: false, key: nil) { (response: Result<LoginRegisterModel, Error>) in
            DispatchQueue.main.async {
                Global.dismissLoadingSpinner()
                switch response {
                case .failure(let error):
                    if let err = error as? ErrorTypesAPP {
                        switch err {
                        case .notRegistered:
                            completion(nil, err)
                        default:
                            completion(nil, err)
                        }
                    }
                case .success(let res):
                    let tokenViewModel = LoginRegisterViewModel(data: res)
                    completion(tokenViewModel, nil)
                }
            }
        }
    }
    
    //MARK: - View Profile
    func apiGetProfileData(id: Int?, showloader: Bool = false, completion: @escaping(_ userData: ProfileDataViewModel, _ userModel: ProfileModel?)->()) {
        var params: [String: Any] = [
            "device_type": Constants.kDeviceType,
            "device_id": Constants.UDID,
            "device_token": Constants.kFCMToken, //Constants.kDeviceToken
            "client_secret": Constants.kClientSecret,
            "app_id": Constants.kAppId
        ]
        if let id = id {
            params["profile_id"] = id
        }
        DispatchQueue.main.async {
            if showloader {
                Global.showLoadingSpinner(nil, sender: self.view)
            }
        }
        HpAPI.GETPROFILE.DataAPI(params: params, shouldShowError: false, shouldShowSuccess: false, key: "data") { (response: Result<ProfileModel, Error>) in
            DispatchQueue.main.async {
                if showloader {
                    Global.dismissLoadingSpinner(self.view)
                }
                switch response {
                case .failure(let error):
                    if let err = error as? ErrorTypesAPP {
                        switch err {
                        case .unauthenticate:
                            HpAPI.STATIC.apiLogoutUser()
                        default:
                            break
                        }
                    }
                case .success(let res):
                    let profileData = ProfileViewModel(data: res)
                    completion(profileData.userProfileData, res)
                }
            }
        }
    }
    
    func apiBugReport(txt: String, mailFor: String) {
        let params: [String: Any] = [
            "device_type": Constants.kDeviceType,
            "device_id": Constants.UDID,
            "device_token": Constants.kFCMToken, //Constants.kDeviceToken
            "client_secret": Constants.kClientSecret,
            "app_id": Constants.kAppId,
            "mail_for": mailFor,
            "message": txt
        ]
        
        DispatchQueue.main.async {
            Global.showLoadingSpinner()
        }
        HpAPI.SENDMAIL.DataAPI(params: params, shouldShowError: true, shouldShowSuccess: true, key: nil) { (response: Result<[String: String], Error>) in
            DispatchQueue.main.async {
                Global.dismissLoadingSpinner()
            }
        }
    }
    
    
    //MARK:- Get Address
    /*
    func GetAddress(target: CLLocationCoordinate2D, completion: @escaping (_ fullAddress: String?, _ city: String?, _ country: String?, _ postalCode: String?)->()) {
        let geoCoder = GMSGeocoder()
        geoCoder.reverseGeocodeCoordinate(target) { (respose, error) in
                if let result = respose?.firstResult() {
                    if let address = result.lines {
                        let address = address.joined(separator: ",")
                        completion(address, result.locality ?? result.subLocality ?? result.administrativeArea, result.country, result.postalCode)
                    } else {
                        completion(nil, nil, nil, nil)
                    }
                } else {
                    completion(nil, nil, nil, nil)
                }
            
        }
    }
     */
    
    //MARK: - Report popup
    fileprivate static var _saveAction: UIAlertAction?
    fileprivate static var _isEditBio: Bool = false
    fileprivate var saveAction: UIAlertAction {
        get {
            return UIViewController._saveAction ?? UIAlertAction()
        }
        set {
            UIViewController._saveAction = newValue
        }
    }
    
    fileprivate var isEditBio: Bool {
        get {
            return UIViewController._isEditBio
        }
        set {
            UIViewController._isEditBio = newValue
        }
    }
    
    func ShowReportPopup(title: String, message: String, text: String?, okTitle: String, cancleTitle: String, okStyle: UIAlertAction.Style, cancelStyle: UIAlertAction.Style, placeholderText: String, sender: UIViewController?, isEditBio: Bool = false, isDarkMode: Bool, handler: @escaping (_ text: String?)->())
    {
        DispatchQueue.main.async {
            
            let actionInReport = UIAlertController(title: title, message: message, preferredStyle: .alert)
            if isDarkMode, #available(iOS 13.0, *) {
                actionInReport.overrideUserInterfaceStyle = .dark
            }
            actionInReport.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = placeholderText
                textField.autocapitalizationType = .sentences
                
                if let aboutInfo = text {
                    textField.text = aboutInfo
                }
                textField.addTarget(sender, action: #selector(self.textChanged(_:)), for: .editingChanged)
            }
            self.saveAction = UIAlertAction(title: okTitle, style: okStyle, handler: { (_) in
                if let textField: UITextField = actionInReport.textFields?.first {
                    handler(textField.text?.trim())
                }
            })
            let cancelAction = UIAlertAction(title: cancleTitle, style: cancelStyle, handler: { (_) in
                handler(nil)
            })
            
            self.isEditBio = isEditBio
            self.saveAction.isEnabled = isEditBio
            
            actionInReport.addAction(cancelAction)
            actionInReport.addAction(self.saveAction)
            
            
            sender?.present(actionInReport, animated: true, completion: nil)
        }
    }
    
    @objc fileprivate func textChanged(_ sender: UITextField)
    {
        if !isEditBio {
        saveAction.isEnabled = (sender.text!.trim() != "")
        }
    }
    
    func SendReport(title: String, message: String, placeholderText: String, reportType: ReportTypes, id: Int? = nil, key: String, isDarkMode: Bool, completion: @escaping(_ isDone: Bool)->()) {
        self.ShowReportPopup(title: title, message: message, text: nil, okTitle: Messages.txtSettingSend, cancleTitle: "Annuler", okStyle: .destructive, cancelStyle: .default, placeholderText: placeholderText, sender: self, isDarkMode: isDarkMode) { (text) in
            DispatchQueue.main.async {
                
                if let text = text {
                    var params: [String: Any] = [
                        "lc": Constants.lc,
                        "message": text,
                        "mail_for": reportType.rawValue
                    ]
                    if let id = id {
                        params[key] = id
                    }
                    DispatchQueue.main.async {
                        Global.showLoadingSpinner(sender: self.view)
                    }
                    HpAPI.SENDMAIL.DataAPI(params: params, shouldShowError: true, shouldShowSuccess: true, key: nil) { (response: Result<GeneralModel, Error>) in
                        DispatchQueue.main.async {
                            Global.dismissLoadingSpinner(self.view)
                            switch response {
                            case .success(_):
                                completion(true)
                            case .failure(_):
                                completion(false)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func acceptRejectMembership(isAccepted: Bool, id: Int, completion: @escaping(_ done: Bool)->()) {
        let params: [String: Any] = [
            "lc": Constants.lc,
            "member_id": id,
            "post_type": isAccepted ? "Accepted" : "Rejected" //Rejected/Accepted
        ]
        HpAPI.acceptRejectRequest.DataAPI(params: params, shouldShowError: true, shouldShowSuccess: true, key: nil) { (response: Result<GeneralModel, Error>) in
            DispatchQueue.main.async {
                Global.dismissLoadingSpinner(self.view)
                switch response {
                case .success(_):
                    completion(true)
                case .failure(_):
                    completion(false)
                    break
                }
            }
        }
    }
}
