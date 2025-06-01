
import UIKit

enum AccessType: String {
    case Completed
    case Limited
}

enum SocialType: String {
    case Facebook = "Facebook"
    case Apple = "Apple"
    case Google = "Google"
    case DeviceId = "DeviceId"
}

struct ProfileModel: Codable {
    var registration_step: Int?
    var user_info: ProfileDataModel?
}

struct ProfileViewModel {
    var data = ProfileModel()
    
    init(data: ProfileModel) {
        self.data = data
    }
    
    var userProfileData: ProfileDataViewModel {
        return ProfileDataViewModel(data: self.data.user_info ?? ProfileDataModel())
    }
    var registrationStep: Int {
        return data.registration_step ?? 0
    }
}

struct ProfileDataModel: Codable {
    var add_latitude, add_longitude: Double?
    var address: String?
    var address_city: String?
    var user_age: Int?
    var country: String?
    var country_code, country_flag: String?
    var national_number: String?
    var created, modified : String?
    var notification: Bool?
    var is_premium: Bool?
    var application_news_notification: Bool?
    var description: String?
    var dob: String?
    var dudid: String?
    var email: String?
    var first_name: String?
    var gender : String?
    var id : Int?
    var last_name: String?
    var mobile: String?
    var qr_code: String?
    var profile_pic: String?
    var profile_thumb_pic: String?
    var role: Int?
    var social_type: String?
    var society_name: String?
    var user_latitude: Double?
    var user_longitude: Double?
    var enterprises_data: EnterprisesDataModel?
    
    var settings: GeneralSettingsModel?
    
    var random_id: String?
}


struct ProfileDataViewModel {
    private var profileData = ProfileDataModel()
    private var settingsData = GeneralSettingsModel()
    
    init(data: ProfileDataModel) {
        self.profileData = data
        self.settingsData = data.settings ?? GeneralSettingsModel()
    }
    
    var userId: Int {
        return profileData.id ?? 0
    }
    
    var randomId: (withHash: String, plain: String) {
        let random = profileData.random_id ?? ""
        return ("#\(random)", random)
    }
    
    var socialType: SocialType {
        return SocialType(rawValue: profileData.social_type ?? "") ?? .DeviceId
    }
    
    var socialTypeGetter: String {
        get {
            return profileData.social_type ?? SocialType.DeviceId.rawValue
        }
        set {
            profileData.social_type = newValue
        }
    }
    
    var firstName: String {
        get {
            return profileData.first_name?.trim() ?? ""
        }
        set {
            profileData.first_name = newValue.trim()
        }
    }
    var lastName: String {
        get {
            return profileData.last_name?.trim() ?? ""
        }
        set {
            profileData.last_name = newValue.trim()
        }
    }
    var fullName: String {
        return "\(firstName) \(lastName)".trim()
    }
    var fullNameFormatted: String {
        return "\(firstName) \(lastName.prefix(1))."
    }
    var createdOn: String {
        if let cretd = profileData.created {
            let result = Global.GetFormattedDate(dateString: cretd, currentFormate: "yyyy-MM-dd'T'HH:mm:ssZZZZ", outputFormate: "dd MMM yyyy", isInputUTC: true, isOutputUTC: false)
            return result.dateString?.lowercased() ?? ""
        }
        return ""
    }
    
    var dateOfBirth: String {
        get {
            return profileData.dob ?? ""
        }
        set {
            profileData.dob = newValue
        }
    }
    
    var dob: (dobString: String?, dobDate: Date?) {
        if let strDoB = profileData.dob {
            let resultDate = Global.GetFormattedDate(dateString: strDoB, currentFormate: "yyyy-MM-dd", outputFormate: "d MMM yyyy", isInputUTC: true, isOutputUTC: false)
            return (resultDate.dateString, resultDate.date)
        }
        return (nil, nil)
    }
    var dobSendable: (dobString: String?, dobDate: Date?) {
        if let strDoB = profileData.dob {
            let resultDate = Global.GetFormattedDate(dateString: strDoB, currentFormate: "yyyy-MM-dd", outputFormate: "yyyy-MM-dd", isInputUTC: true, isOutputUTC: true)
            return (resultDate.dateString, resultDate.date)
        }
        return (nil, nil)
    }
    
    var city: String {
        return profileData.address_city ?? ""
    }
    var userAge: String {
        return "\(profileData.user_age ?? 0) ans"
    }
    
    var ageWithCity: String {
        if city != "" {
        return "\(userAge)  •  \(city)"
        }
        return userAge
    }
    
    var mobileNumber: String {
        get {
            return (profileData.mobile ?? "").replacingOccurrences(of: " ", with: "")
        }
        set {
            profileData.mobile = newValue.replacingOccurrences(of: " ", with: "")
        }
    }
    var mobileNumberWithCountryCode: String {
        return "\(countryPhoneCode) \(mobileNumber.formattedPhoneNumber())"
    }
    var uid: String {
        get {
        return profileData.dudid ?? ""
        }
        set {
            profileData.dudid = newValue
        }
    }
    var profilePicURL: URL? {
        return profileData.profile_pic?.makeUrl()
    }
    var profilePic: String? {
        return profileData.profile_pic
    }
    
    var qrCodeURL: URL? {
        return profileData.qr_code?.makeUrl()
    }
    var qrCode: String? {
        return profileData.qr_code
    }
    
    var email: String {
        get {
            return profileData.email ?? ""
        }
        set {
            profileData.email = newValue
        }
    }
    var allowNotification: Bool {
        get {
            return profileData.notification ?? false
        }
        set {
            profileData.notification = newValue
        }
    }
    
    var isPremium: Bool {
        get {
            return profileData.is_premium ?? false
        }
        set {
            profileData.is_premium = newValue
        }
    }
    
    var nationalNumber: String {
        get {
            return profileData.national_number?.trimmingCharacters(in: ["+"]) ?? ""
        }
        set {
            if newValue.hasPrefix("++") {
                profileData.national_number = newValue.replacingOccurrences(of: "++", with: "")
            } else {
                profileData.national_number = newValue.trimmingCharacters(in: ["+"])
            }
        }
    }
    var countryCode: String {
        get {
            return profileData.country_flag ?? "FR"
        }
        set {
            profileData.country_flag = newValue
        }
    }
    var countryPhoneCode: String {
        get {
            return profileData.country_code ?? ""
        }
        set {
            profileData.country_code = newValue
        }
    }
    
    var notifyNewMessage: Bool? {
        get {
            return profileData.application_news_notification
        }
        set {
            profileData.application_news_notification = newValue
        }
    }
    
    var userSettingsData: GeneralSettingsViewModel {
        return GeneralSettingsViewModel(data: settingsData)
    }
    
    var enterprisesData: EnterprisesDataViewModel {
        return EnterprisesDataViewModel(data: self.profileData.enterprises_data ?? EnterprisesDataModel())
    }
    
    var dialCode: (withPlus: String, withoutPlus: String) {
        return (withPlus: countryPhoneCode, withoutPlus: countryPhoneCode.replacingOccurrences(of: "+", with: ""))
    }
    
    var dialCodeWithFlag: (countryCode: String, codeWithFlag: String) {
        if dialCode.withoutPlus != "" {
            if let countryCode = Constants.countryPrefixes.first(where: {$0.value == dialCode.withoutPlus})?.key {
                let codeWithFlag = "\(self.emojiFlag(regionCode: countryCode)!) +\(Constants.countryPrefixes[countryCode]!)"
                return (countryCode: countryCode, codeWithFlag: codeWithFlag)
            }
        }
        return ("FR", "\(self.emojiFlag(regionCode: "FR")!) +33")
    }
    
    func emojiFlag(regionCode: String) -> String? {
        let code = regionCode.uppercased()
        
        guard Locale.isoRegionCodes.contains(code) else {
            return nil
        }
        
        var flagString = ""
        for s in code.unicodeScalars {
            guard let scalar = UnicodeScalar(127397 + s.value) else {
                continue
            }
            flagString.append(String(scalar))
        }
        return flagString
    }
    
}

struct EnterprisesDataModel: Codable {
    var company_address: String?
    var company_city: String?
    var company_designation: String?
    var company_latitude: Double?
    var company_longitude: Double?
    var company_name: String?
    var company_type_id: Int?
    var contact_country_code: String?
    var contact_country_flag: String?
    var contact_email: String?
    var contact_mobile: String?
    var description: String?
    var enterprises_logo: String?
    var id: Int?
    var seo_id: Int?
    var siret_number: String?
    var society_type_id: Int?
}

struct EnterprisesDataViewModel {
    var data = EnterprisesDataModel()
    
    init(data: EnterprisesDataModel) {
        self.data = data
    }
    
    var id: Int {
        return data.id ?? 0
    }
    var companyAddress: String {
        return data.company_address ?? ""
    }
    var companyCity: String {
        return data.company_city ?? ""
    }
    var companyDesignation: String {
        return data.company_designation ?? ""
    }
    var companyLatitude: Double {
        return data.company_latitude ?? 0.0
    }
    var companyLongitude: Double {
        return data.company_longitude ?? 0.0
    }
    var companyName: String {
        return data.company_name ?? ""
    }
    var contactCountryPhoneCode: String {
        return data.contact_country_code ?? ""
    }
    var contactCountryCode: String {
        return data.contact_country_flag ?? ""
    }
    var contactEmail: String {
        return data.contact_email ?? ""
    }
    var contactMobile: String {
        return data.contact_mobile ?? ""
    }
    var description: String {
        return data.description ?? ""
    }
    var enterprisesLogo: String {
        return data.enterprises_logo ?? ""
    }
    var enterprisesLogoURL: URL? {
        return enterprisesLogo.makeUrl()
    }
    var companyTypeId: Int {
        return data.company_type_id ?? 0
    }
    var seoId: Int {
        return data.seo_id ?? 0
    }
    var siretNumber: String {
        return data.siret_number ?? ""
    }
    var societyTypeId: Int {
        return data.society_type_id ?? 0
    }
}


//set, get & remove WasteCategory in cache
struct RegUserDataCache {
    static let key = "registerUser"
    static func save(_ value: ProfileModel) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(value) {
            Constants.kUserDefaults.set(encoded, forKey: key)
        }
    }
    static func get() -> ProfileViewModel? {
        if let savedData = UserDefaults.standard.object(forKey: key) as? Data {
            let decoder = JSONDecoder()
            if let dataRes = try? decoder.decode(ProfileModel.self, from: savedData) {
                return ProfileViewModel(data: dataRes)
            } else {
                return ProfileViewModel(data: ProfileModel(registration_step: 0, user_info: ProfileDataModel()))
            }
        } else {
            return ProfileViewModel(data: ProfileModel(registration_step: 0, user_info: ProfileDataModel()))
        }
    }
    static func remove() {
        Constants.kUserDefaults.removeObject(forKey: key)
    }
}

struct CompanyPublishJobsVideoModel: Codable {
    var publish_video: [CompanyPublishJobsVideoDataModel]?
}

struct CompanyPublishJobsVideoViewModel {
    var data = CompanyPublishJobsVideoModel()
    
    init(data: CompanyPublishJobsVideoModel) {
        self.data = data
    }
   
    var videoData: [CompanyPublishJobsVideoDataViewModel] {
        return data.publish_video?.map({return CompanyPublishJobsVideoDataViewModel(data: $0)}) ?? []
    }
}

struct CompanyPublishJobsVideoDataModel: Codable {
    var video_file: String?
    var video_thumb: String?
    var id: Int?
}

struct CompanyPublishJobsVideoDataViewModel {
    private var data = CompanyPublishJobsVideoDataModel()
    
    init(data: CompanyPublishJobsVideoDataModel) {
        self.data = data
    }
    
    var id: Int {
        return data.id ?? 0
    }
    
    var videoThumbURL: URL? {
        return data.video_thumb?.makeUrl()
    }
    
    var videoFile: String {
        return data.video_file ?? ""
    }
}

struct TempProfileModel: Codable {
    var id : Int?
    var member_id: Int?
    var name: String?
    var first_name: String?
    var last_name: String?
    var photo: String?
    var random_id: String?
}

struct TempProfileViewModel {
    private var profileData = TempProfileModel()
    
    init(data: TempProfileModel) {
        self.profileData = data
    }
    
    var id: Int {
        return profileData.id ?? 0
    }

    var memberId: Int {
        return profileData.member_id ?? 0
    }
    
    var name: String {
        get {
            return profileData.name?.trim() ?? ""
        }
        set {
            profileData.name = newValue.trim()
        }
    }
    
    var firstName: String {
        get {
            return profileData.first_name?.trim() ?? ""
        }
        set {
            profileData.first_name = newValue.trim()
        }
    }
    
    var lastName: String {
        get {
            return profileData.last_name?.trim() ?? ""
        }
        set {
            profileData.last_name = newValue.trim()
        }
    }
    var fullName: String {
        return "\(firstName) \(lastName)".trim()
    }
    var fullNameFormatted: String {
        return "\(firstName) \(lastName.prefix(1))."
    }
    
    var profilePic: String {
        return profileData.photo ?? ""
    }
    
    var profilePicURL: URL? {
        return profileData.photo?.makeUrl()
    }
    
    var randomId: String {
        return profileData.random_id ?? ""
    }
}
