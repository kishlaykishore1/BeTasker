
import UIKit

struct LoginRegisterModel: Codable {
    var data: TokenModel?
    var is_register: Bool?
    var registration_step: String?
}

struct TokenModel: Codable {
    var login: TokenDataModel?
    var user_info: ProfileDataModel?
}

struct TokenDataModel: Codable {
    var access_token: String?
    var refresh_token: String?
}


struct TokenDataViewModel {
    private var data = TokenDataModel()
    
    init(data: TokenDataModel) {
        self.data = data
    }
    var accessToken: String {
        return data.access_token ?? ""
    }
    var refreshToken: String {
        return data.refresh_token ?? ""
    }
}

struct LoginRegisterViewModel {
    private var data = LoginRegisterModel()
    init(data: LoginRegisterModel) {
        self.data = data
    }
    var tokenData: TokenDataViewModel {
        if let tokens = data.data?.login {
            return TokenDataViewModel(data: tokens)
        }
        return TokenDataViewModel(data: TokenDataModel(access_token: nil, refresh_token: nil))
    }
    var profileData: ProfileDataViewModel {
        if let profile = data.data?.user_info {
            return ProfileDataViewModel(data: profile)
        }
        return ProfileDataViewModel(data: ProfileDataModel())
    }
    var isRegistered: Bool {
        return data.is_register ?? false
    }
    var registrationStep: String {
        return data.registration_step ?? ""
    }
}

struct GeneralModel: Codable {
    var message: String?
    var image_name: String?
    var is_job_accepted: Bool?
    var interview_schedule_id: Int?
    var unread_total_count: Int?
}

struct GeneralViewModel {
    private var data = GeneralModel()
    
    init(data: GeneralModel) {
        self.data = data
    }
    
    var imageName: String {
        return data.image_name ?? ""
    }
}

struct SettingModel: Codable {
    var setting_data: GeneralSettingsModel?
}

struct SettingViewModel {
    var data = SettingModel()
    
    init(data: SettingModel) {
        self.data = data
    }
    
    var settings: GeneralSettingsViewModel {
        return GeneralSettingsViewModel(data: self.data.setting_data ?? GeneralSettingsModel())
    }
}

struct GeneralSettingsModel: Codable {
    var web_url: String?
    var web_url_status: Bool?
    var fb_url: String?
    var fb_url_status: Bool?
    var insta_url: String?
    var insta_url_status: Bool?
    var twitter_url: String?
    var twitter_url_status: Bool?
    var linked_in_url: String?
    var linked_in_url_status: Bool?
    var report_email: String?
    var contact_email: String?
    var terms_condition: String?
    var confidentiality: String?
    var force_status: Bool?
    var force_status_ios: Bool?
    var should_show_popup: Bool?
    var api_version: String?
    var app_version: String?
    var app_version_ios: String?
    var suggest_an_idea_url: String?
    var suggest_an_idea_url_status: Bool?
    var third_party_software: String?
    var become_partner_status: Bool?
    var become_partner: String?
    var app_system_password: String?
    var download_the_app: String?
    var temperature_and_settings: String?
    var company_type: [CompanyTypeModel]?
    var company_size: [CompanySizeModel]?
    var reffrence: [ReffrenceModel]?
}

struct GeneralSettingsViewModel {

    private var data = GeneralSettingsModel()
    
    init(data: GeneralSettingsModel) {
        self.data = data
    }
    
    var appSystemPassword: String {
        return data.app_system_password ?? ""
    }
    
    var appVersionIos: String {
        return data.app_version_ios ?? ""
    }
    var confidentiality: String {
        return data.confidentiality ?? ""
    }
    var contactEmail: String {
        return data.contact_email ?? ""
    }
    var fbUrl: String {
        return data.fb_url ?? ""
    }
    var fbURLStatus: Bool {
        return data.fb_url_status ?? false
    }
    var forceStatusIos: Bool {
        return data.force_status_ios ?? false
    }
    var instaURL: String {
        return data.insta_url ?? ""
    }
    var instaURLStatus: Bool {
        return data.insta_url_status ?? false
    }
    var linkedInUrl: String? {
        return data.linked_in_url ?? ""
    }
    var linkedStatus: Bool {
        return data.linked_in_url_status ?? false
    }
    var twitterURL: String {
        return data.twitter_url ?? ""
    }
    var twitterURLStatus: Bool {
        return data.twitter_url_status ?? false
    }
    var thirdPartySoftware: String {
        return data.third_party_software ?? ""
    }
    var reportEmail: String {
        return data.report_email ?? ""
    }
    var shouldShowPopup: Bool {
        return data.should_show_popup ?? false
    }
    var termsCondition: String {
        return data.terms_condition ?? ""
    }
    var apiVersion: String? {
        return data.api_version ?? ""
    }
    var apiVersionFormatted: String {
        if let info = Bundle.main.infoDictionary, let currentVersion = info["CFBundleShortVersionString"] as? String {
            return "v.\(currentVersion)-\(apiVersion ?? "")"
        }
        return ""
    }
    var webURL: String {
        return data.web_url ?? ""
    }
    var webURLStatus: Bool {
        return data.web_url_status ?? false
    }
    var becomePartner: String? {
        return data.become_partner ?? ""
    }
    var companyTypeData: [CompanyTypeViewModel] {
        return data.company_type?.map({return CompanyTypeViewModel(data: $0)}) ?? []
    }
    var companySizeData: [CompanySizeViewModel] {
        return data.company_size?.map({return CompanySizeViewModel(data: $0)}) ?? []
    }
    var reffrenceData: [ReffrenceViewModel] {
        return data.reffrence?.map({return ReffrenceViewModel(data: $0)}) ?? []
    }
    var shareInvitation: String {
        return data.download_the_app ?? ""
    }
    var shareAPP: String {
        return data.temperature_and_settings ?? ""
    }
}

struct CompanyTypeModel: Codable {
    var society_type_id: Int?
    var title: String?
}

struct CompanyTypeViewModel {
    var data = CompanyTypeModel()
    
    init(data: CompanyTypeModel) {
        self.data = data
    }
    
    var societyTypeId: Int {
        return data.society_type_id ?? 0
    }
    var title: String {
        return data.title ?? ""
    }
}

struct CompanySizeModel: Codable {
    var company_type_id: Int?
    var title: String?
}

struct CompanySizeViewModel {
    var data = CompanySizeModel()
    
    init(data: CompanySizeModel) {
        self.data = data
    }
    
    var companyTypeId: Int {
        return data.company_type_id ?? 0
    }
    var title: String {
        return data.title ?? ""
    }
}

struct ReffrenceModel: Codable {
    var seo_id: Int?
    var title: String?
}

struct ReffrenceViewModel {
    var data = ReffrenceModel()
    
    init(data: ReffrenceModel) {
        self.data = data
    }
    
    var seoId: Int {
        return data.seo_id ?? 0
    }
    var title: String {
        return data.title ?? ""
    }
}

//set, get & remove WasteCategory in cache
struct SettingDataCache {
    static let key = "settingData"
    static func save(_ value: GeneralSettingsModel) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(value) {
            Constants.kUserDefaults.set(encoded, forKey: key)
        }
    }
    static func get() -> GeneralSettingsViewModel? {
        if let savedData = UserDefaults.standard.object(forKey: key) as? Data {
            let decoder = JSONDecoder()
            if let dataRes = try? decoder.decode(GeneralSettingsModel.self, from: savedData) {
                return GeneralSettingsViewModel(data: dataRes)
            } else {
                return GeneralSettingsViewModel(data: GeneralSettingsModel())
            }
        } else {
            return GeneralSettingsViewModel(data: GeneralSettingsModel())
        }
    }
    static func remove() {
        Constants.kUserDefaults.removeObject(forKey: key)
    }
}
