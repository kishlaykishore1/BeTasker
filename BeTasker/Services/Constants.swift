//
//  Constants.swift
//  EasyAC
//
//  Created by MAC3 on 26/04/23.
//

import Foundation
import UIKit
import Firebase

class Constants {
    static let kAppDelegate          = UIApplication.shared.delegate as! AppDelegate
    static let kScreenWidth          = UIScreen.main.bounds.width
    static let kScreenHeight         = UIScreen.main.bounds.height
    static let kAppDisplayName       = UIApplication.appName
    static let kUserDefaults         = UserDefaults.standard
    static var UDID                  = UIDevice.current.identifierForVendor?.uuidString ?? ""
    static var KBundleID             = Bundle.main.bundleIdentifier
    static let lc                    = Locale.preferredLanguages[0].prefix(2) == "fr" ? "fr" : "en"
    static let kAccessToken = "kAccessToken"
    static let kRefreshToken = "kRefreshToken"
    static let kAppId = "1"
    static let roleId = "3"
    static let kAUTHVERIFICATIONID       = "authVerificationID" //Firebase phone auth
    
    static var kDeviceToken              = "" //"DEVICETOKEN"
    static var kFCMToken                 = "" //"FCMTOKEN"
    static var kClientSecret             = "oawjChexncnEdwyMR6YHawUiLcWhzFfRGMPuoapEasyAc"
    static let kDeviceType               = "iOS"
    static let kClientId                 = 6
    
    static let kUserInterfaceStyle = "kUserInterfaceStyle"
    
    static let kRoomAddIntroShown = "kRoomAddIntroShown"
    static let kMemberAddIntroShown = "kMemberAddIntroShown"
    static let kMemberContactIntroShown = "kMemberContactIntroShown"
    static let kPlanAddIntroShown = "kPlanAddIntroShown"
    
    static let Main                  = UIStoryboard(name: "Main", bundle: nil)
    static let Home                  = UIStoryboard(name: "Home", bundle: nil)
    static let Chat                  = UIStoryboard(name: "Chat", bundle: nil)
    static let Profile               = UIStoryboard(name: "Profile", bundle: nil)
    static let WorkSpace             = UIStoryboard(name: "WorkSpace", bundle: nil)
    static var KMDCPlaceHolderColor  = #colorLiteral(red: 0, green: 0.02745098039, blue: 0.1803921569, alpha: 0.14)
    static var KMDCFloatLabelColor   = UIColor.black
    
    static let firebseReference = Database.database().reference()
    static let taskChatNode = "taskChats"
    static let taskChatReadNode = "taskChatsUserReads"
    static let myDevicesNode = "myDevices"
    static let sharedSecreteIAP = "c6167a8e3866414cb306aa5aef9a777d"
    static let subscriptionEndDate = "subscriptionEndDate"
    static let userPremium = "premiumUser"
    static let userSubscribed = "userSubscribed"
    static let userSubscribedProductId = "userSubscribedProductId"
    static let KGraphikRegular       = "Graphik-Regular"
    static let KGraphikMedium        = "Graphik-Medium"
    static let KGraphikSemibold      = "Graphik-Semibold"
    static let KMonteserratMedium    = "Montserrat-Medium"
    static let KMonteserratSemibold  = "Montserrat-Semibold"
    static let kWorkSpaceIntroShown = "kWorkSpaceIntroShown"
    static let kSelectedWorkSpaceId = "kSelectedWorkSpaceId"
    static let KUserIDKey           = "KUserIDKey"
    static func saveAPITokens(accessToken: String, refreshToken: String) {
        kUserDefaults.set(accessToken, forKey: kAccessToken)
        kUserDefaults.set(refreshToken, forKey: kRefreshToken)
    }
    
    static func removeAPITokens() {
        kUserDefaults.removeObject(forKey: kAccessToken)
        kUserDefaults.removeObject(forKey: kRefreshToken)
    }
    
    static func getAPITokens() -> (accessToken: String?, refreshToken: String?) {
        guard let accessToken = kUserDefaults.string(forKey: kAccessToken), let refreshToken = kUserDefaults.string(forKey: kRefreshToken) else {
            return (nil, nil)
        }
        return (accessToken, refreshToken)
    }
    
    static let countryPrefixes: [String: String] = ["AF": "93", "AL": "355", "DZ": "213", "AS": "1", "AD": "376", "AO": "244", "AI": "1", "AQ": "672", "AG": "1", "AR": "54", "AM": "374", "AW": "297", "AU": "61", "AT": "43", "AZ": "994", "BS": "1", "BH": "973", "BD": "880", "BB": "1", "BY": "375", "BE": "32", "BZ": "501", "BJ": "229", "BM": "1", "BT": "975", "BA": "387", "BW": "267", "BR": "55", "IO": "246", "BG": "359", "BF": "226", "BI": "257", "KH": "855", "CM": "237", "CA": "1", "CV": "238", "KY": "345", "CF": "236", "TD": "235", "CL": "56", "CN": "86", "CX": "61", "CO": "57", "KM": "269", "CG": "242", "CK": "682", "CR": "506", "HR": "385", "CU": "53", "CY": "537", "CZ": "420", "DK": "45", "DJ": "253", "DM": "1", "DO": "1", "EC": "593", "EG": "20", "SV": "503", "GQ": "240", "ER": "291", "EE": "372", "ET": "251", "FO": "298", "FJ": "679", "FI": "358", "FR": "33", "GF": "594", "PF": "689", "GA": "241", "GM": "220", "GE": "995", "DE": "49", "GH": "233", "GI": "350", "GR": "30", "GL": "299", "GD": "1", "GP": "590", "GU": "1", "GT": "502", "GN": "224", "GW": "245", "GY": "595", "HT": "509", "HN": "504", "HU": "36", "IS": "354", "IN": "91", "ID": "62", "IQ": "964", "IE": "353", "IL": "972", "IT": "39", "JM": "1", "JP": "81", "JO": "962", "KZ": "77", "KE": "254", "KI": "686", "KW": "965", "KG": "996", "LV": "371", "LB": "961", "LS": "266", "LR": "231", "LI": "423", "LT": "370", "LU": "352", "MG": "261", "MW": "265", "MY": "60", "MV": "960", "ML": "223", "MT": "356", "MH": "692", "MQ": "596", "MR": "222", "MU": "230", "YT": "262", "MX": "52", "MC": "377", "MN": "976", "ME": "382", "MS": "1", "MA": "212", "MM": "95", "NA": "264", "NR": "674", "NP": "977", "NL": "31", "AN": "599", "NC": "687", "NZ": "64", "NI": "505", "NE": "227", "NG": "234", "NU": "683", "NF": "672", "MP": "1", "NO": "47", "OM": "968", "PK": "92", "PW": "680", "PA": "507", "PG": "675", "PY": "595", "PE": "51", "PH": "63", "PL": "48", "PT": "351", "PR": "1", "QA": "974", "RO": "40", "RW": "250", "WS": "685", "SM": "378", "SA": "966", "SN": "221", "RS": "381", "SC": "248", "SL": "232", "SG": "65", "SK": "421", "SI": "386", "SB": "677", "ZA": "27", "GS": "500", "ES": "34", "LK": "94", "SD": "249", "SR": "597", "SZ": "268", "SE": "46", "CH": "41", "TJ": "992", "TH": "66", "TG": "228", "TK": "690", "TO": "676", "TT": "1", "TN": "216", "TR": "90", "TM": "993", "TC": "1", "TV": "688", "UG": "256", "UA": "380", "AE": "971", "GB": "44", "US": "1", "UY": "598", "UZ": "998", "VU": "678", "WF": "681", "YE": "967", "ZM": "260", "ZW": "263", "BO": "591", "BN": "673", "CC": "61", "CD": "243", "CI": "225", "FK": "500", "GG": "44", "VA": "379", "HK": "852", "IR": "98", "IM": "44", "JE": "44", "KP": "850", "KR": "82", "LA": "856", "LY": "218", "MO": "853", "MK": "389", "FM": "691", "MD": "373", "MZ": "258", "PS": "970", "PN": "872", "RE": "262", "RU": "7", "BL": "590", "SH": "290", "KN": "1", "LC": "1", "MF": "590", "PM": "508", "VC": "1", "ST": "239", "SO": "252", "SJ": "47", "SY": "963", "TW": "886", "TZ": "255", "TL": "670", "VE": "58", "VN": "84", "VG": "284", "VI": "340", "EH": "121"]
    
}


// WARNING: Change these constants according to your project's design
struct Const {
    /// Image height/width for Large NavBar state
    static let ImageSizeForLargeState: CGFloat = 32
    /// Margin from right anchor of safe area to right anchor of Image
    static let ImageRightMargin: CGFloat = 16
    /// Margin from bottom anchor of NavBar to bottom anchor of Image for Large NavBar state
    static let ImageBottomMarginForLargeState: CGFloat = 8
    /// Margin from bottom anchor of NavBar to bottom anchor of Image for Small NavBar state
    static let ImageBottomMarginForSmallState: CGFloat = 6
    /// Image height/width for Small NavBar state
    static let ImageSizeForSmallState: CGFloat = 32
    /// Height of NavBar for Small state. Usually it's just 44
    static let NavBarHeightSmallState: CGFloat = 44
    /// Height of NavBar for Large state. Usually it's just 96.5 but if you have a custom font for the title, please make sure to edit this value since it changes the height for Large state of NavBar
    static let NavBarHeightLargeState: CGFloat = 96.5
}

struct ColorsConst {
    static let borderColor = UIColor(named: "ColorE8E8E8")!
    
    static let Color1E1E1E = UIColor(named: "Color1E1E1E")!

    static let Color2D2D2D = UIColor(named: "Color2D2D2D")!

    static let Color62DD3C = UIColor(named: "Color62DD3C")!

    static let Color00072E = UIColor(named: "Color00072E")!

    static let Color001277 = UIColor(named: "Color001277")!

    static let Color161616 = UIColor(named: "Color161616")!

    static let Color262626 = UIColor(named: "Color262626")!

    static let Color777777 = UIColor(named: "Color777777")!

    static let ColorACAEBB = UIColor(named: "ColorACAEBB")!

    static let ColorBDBDBD = UIColor(named: "ColorBDBDBD")!

    static let ColorE8E8E8 = UIColor(named: "ColorE8E8E8")!

    static let ColorEAEAEA = UIColor(named: "ColorEAEAEA")!

    static let ColorF9F9F9 = UIColor(named: "ColorF9F9F9")!

    static let ColorFAFAFA = UIColor(named: "ColorFAFAFA")!

    static let ColorFFD01E = UIColor(named: "ColorFFD01E")!
    
    static let ColorFF5D5D = UIColor(named: "ColorFF5D5D")!
    
    static let ColorB1B1B1 = UIColor(named: "ColorB1B1B1")!
    
    static let ColorF5F5F5 = UIColor(named: "ColorF5F5F5")!
    
    static let Color4D4D4D = UIColor(named: "Color4D4D4D")!
    
    static let ColorC7C7C7 = UIColor(named: "ColorC7C7C7")!
}
