
import UIKit
import MaterialComponents
import SDWebImage
import SDWebImageSVGKitPlugin
import AVFoundation

struct FontName {
    struct Graphik {
        static let medium = "Graphik-Medium"
        static let regular = "Graphik-Regular"
    }
}


class Global {
    
    public class func setAttributedText(arrText: [(text: String, fontName: String, size: CGFloat, weight: UIFont.Weight, clr: UIColor)]) -> NSMutableAttributedString {
        let finalString = NSMutableAttributedString()
        for item in arrText {
            let attibString = NSMutableAttributedString(string: item.text, attributes: [NSAttributedString.Key.foregroundColor: item.clr, NSAttributedString.Key.font: UIFont(name: item.fontName, size: item.size) ?? UIFont.systemFont(ofSize: item.size, weight: item.weight)])
            finalString.append(attibString)
        }
        return finalString
    }
    
    public class func showAlert(withMessage: String, sender: UIViewController? = UIApplication.topViewController(), handler: ((_ okPressed:Bool) -> Void)? = nil) {
        
        let alertController = UIAlertController(title: Constants.kAppDisplayName, message: withMessage, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Okay".localized, style: .default) { (ok) in
            handler?(true)
        }
        alertController.addAction(okAction)
        sender?.present(alertController, animated: true, completion: nil)
    }
    
    public class func showAlert(message: String, okTitle: String, cancelTitle: String?, sender: UIViewController? = UIApplication.topViewController(), handler: @escaping (_ okPressed:Bool)->()){
        let alertController = UIAlertController(title: Constants.kAppDisplayName, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: okTitle, style: .default) { (ok) in
            handler(true)
        }
        alertController.addAction(okAction)
        if let cancelTitle = cancelTitle{
            let cancelOption = UIAlertAction(title: cancelTitle, style: .default, handler: { (axn) in
                alertController.dismiss(animated: true, completion: nil)
                
            })
            alertController.addAction(cancelOption)
        }
        
        sender?.present(alertController, animated: true, completion: nil)
    }
    
    public class func getInt(for value : Any?) -> Int? {
        
        if let stateCode = value as? String {
            return Int(stateCode)
            
        }else if let stateCodeInt = value as? Int {
            return stateCodeInt
            
        }
        return nil
        
    }
    
    public class func stringifJson(_ value: Any, prettyPrinted: Bool = true) -> String! {
        let options = prettyPrinted ? JSONSerialization.WritingOptions.prettyPrinted : .fragmentsAllowed
        if JSONSerialization.isValidJSONObject(value) {
            do {
                let data = try JSONSerialization.data(withJSONObject: value, options: options)
                if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                    return string as String
                }
            }  catch {
                return ""
            }
        }
        return ""
    }
    
    public class func encodedDataToJSONString<T: Codable>(data: T) -> String {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(data) {
           return String(decoding: encoded, as: UTF8.self)
        }
        return ""
    }
    
//    public class func makeCall(for number : String){
//        if let url = URL(string: "tel://\(number)"), UIApplication.shared.canOpenURL(url) {
//            if #available(iOS 10, *) {
//                UIApplication.shared.open(url)
//            } else {
//                UIApplication.shared.openURL(url)
//            }
//        }
//    }
    
    public class func calling(phoneNo: String) {
        var phoneNumber = phoneNo
        phoneNumber = phoneNumber.components(separatedBy: [" ", "-", "(", ")"]).joined()
        phoneNumber = phoneNumber.replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
        if let phoneCallURL:NSURL = NSURL(string:"telprompt:\(phoneNumber)") {
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL as URL)) {
                application.open(phoneCallURL as URL, options: [:], completionHandler: nil)
            }
        }
    }
    
    public class func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        
        return label.frame.height
    }
    
    public class func hmsFrom(seconds: Int, completion: @escaping (_ hours: Int, _ minutes: Int, _ seconds: Int)->()) {
        
        completion(seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
        
    }
    
    public class func getStringFrom(seconds: Int) -> String {
        
        return seconds < 10 ? "0\(seconds)" : "\(seconds)"
    }
    
    public class var currentLanguge : String {
        return Bundle.main.preferredLocalizations[0] as String
    }
    
    public class func getDateFromString(dateString: String, formatString: String, outputFormatString: String) -> Date {

        // Create a DateFormatter for parsing the string
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatString
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        
        // Convert the string to a Date object
        if let fullDate = dateFormatter.date(from: dateString) {
            // Create another DateFormatter for removing the time
            let onlyDateFormatter = DateFormatter()
            onlyDateFormatter.dateFormat = outputFormatString
            onlyDateFormatter.timeZone = TimeZone(identifier: "UTC")
            // Format the date back to a string and parse it again to remove the time
            if let dateOnly = onlyDateFormatter.date(from: onlyDateFormatter.string(from: fullDate)) {
                return dateOnly
            } else {
                return Date()
            }
        } else {
            return Date()
        }

    }
    
    public class func GetFormattedDate(dateString: String, currentFormate: String, outputFormate: String, isInputUTC: Bool, isOutputUTC: Bool) -> (date: Date?, dateString: String?) {
        let dtFormatter = DateFormatter()
        dtFormatter.dateFormat = currentFormate
        dtFormatter.calendar = Calendar(identifier: .gregorian)
        dtFormatter.locale = Locale(identifier: Constants.lc)
        
        if isInputUTC {
            dtFormatter.timeZone = TimeZone(identifier: "UTC")
        } else {
            dtFormatter.timeZone = TimeZone.current
        }
        
        if let date = dtFormatter.date(from: dateString) {
            if isOutputUTC {
                dtFormatter.timeZone = TimeZone(identifier: "UTC")
            } else {
                dtFormatter.timeZone = TimeZone.current
            }
            dtFormatter.dateFormat = outputFormate
            let outDate = dtFormatter.string(from: date)
            
            return (date, outDate.firstCapitalized)
        }
        return (nil, nil)
    }
    public class func GetFormattedDate(date: Date, outputFormate: String, isInputUTC: Bool, isOutputUTC: Bool) -> (date: Date?, dateString: String?){
        let dtFormatter = DateFormatter()
        dtFormatter.dateFormat = outputFormate
        dtFormatter.calendar = Calendar(identifier: .gregorian)
        dtFormatter.locale = Locale(identifier: Constants.lc)
        
        if isInputUTC {
            dtFormatter.timeZone = TimeZone(identifier: "UTC")
        } else {
            dtFormatter.timeZone = TimeZone.current
        }
        
        let dtString = dtFormatter.string(from: date)
        if let date = dtFormatter.date(from: dtString) {
            if isOutputUTC {
                dtFormatter.timeZone = TimeZone(identifier: "UTC")
            } else {
                dtFormatter.timeZone = TimeZone.current
            }
            dtFormatter.dateFormat = outputFormate
            let outDate = dtFormatter.string(from: date)
            
            return (date, outDate.firstUppercased)
        }
        
        return (nil, nil)
    }
    
    
    public class func convertDateFormater(_ date: String, _ formatFrom: String = "", _ format: String = "dd-MM-yyyy") -> String {
        let dateFormatter = DateFormatter()
        if formatFrom == "" {
            dateFormatter.dateStyle = DateFormatter.Style.medium
            dateFormatter.timeStyle = DateFormatter.Style.none
        } else {
            dateFormatter.dateFormat = formatFrom
        }
        let date = dateFormatter.date(from: date)
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date!)
    }
    
    public class func convertToTimestamp(dateString: String, format: String = "yyyy-MM-dd HH:mm") -> Int? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC") // Adjust timezone if needed
        
        if let date = dateFormatter.date(from: dateString) {
            return date.toMillis()// Unix timestamp in seconds
        }
        return nil
    }
    
    public class func replacePlusFormat(_ str: String) -> String {
        if str.hasPrefix("++") {
            return str.replacingOccurrences(of: "++", with: "")
        }
        return str.trimmingCharacters(in: ["+"])
    }
}

extension Global {
    public static func openURL(_ url: URL?) {
        guard let url = url else {
            return
        }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    public static func openURL(_ url: String) {
        
        guard let url = URL(string: url) else {
            return
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    public class func calcAge(birthday: String) -> Int {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "yyyy-MM-dd"
        let birthdayDate = dateFormater.date(from: birthday)
        let calendar: NSCalendar! = NSCalendar(calendarIdentifier: .gregorian)
        let now = Date()
        let calcAge = calendar.components(.year, from: birthdayDate!, to: now, options: [])
        let age = calcAge.year
        return age!
    }
}

extension Global {
    public class func setVibration() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    public class func doubleVibration() {
        //            let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        //            impactFeedbackGenerator.impactOccurred()
        //            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        //                impactFeedbackGenerator.impactOccurred()
        //            }
        let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
        notificationFeedbackGenerator.notificationOccurred(.success)
    }

    public class func getSVGIconImage(roomIconURL: URL?, completion: @escaping(_ img: UIImage?)->()) {
        let svgCoder = SDImageSVGKCoder.shared
        SDImageCodersManager.shared.addCoder(svgCoder)
       
        SDWebImageDownloader.shared.downloadImage(with: roomIconURL) { (image, imgData, err, done) in
            DispatchQueue.main.async {
                let img = image?.withRenderingMode(.alwaysTemplate)
                completion(img)
            }
        }
    }
    
    public class func setTextField(txtField: MDCOutlinedTextField, label: String, fontSize: CGFloat, labelFontSize: CGFloat, textColorNormal: UIColor? = nil, textColorEditing: UIColor? = nil) {
        txtField.label.text = "\(label)".localized
        txtField.font = UIFont(name: "Graphik-Medium", size: fontSize)
        txtField.label.font = UIFont(name: "Graphik-Regular", size: labelFontSize)
        if let textColorNormal = textColorNormal {
            txtField.setTextColor(textColorNormal, for: .normal)
        }
        if let textColorEditing = textColorEditing {
            txtField.setTextColor(textColorEditing, for: .editing)
        }
        txtField.setNormalLabelColor(Constants.KMDCPlaceHolderColor, for: .normal)
        txtField.setFloatingLabelColor(Constants.KMDCFloatLabelColor, for: .normal)
        txtField.setOutlineColor(.clear, for: .normal)
        txtField.setOutlineColor(.clear, for: .editing)
        txtField.containerRadius = 0
        txtField.leadingEdgePaddingOverride = 0
        txtField.trailingEdgePaddingOverride = 0
        txtField.sizeToFit()
    }

    public class func emojiFlag(regionCode: String) -> String? {
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

    public class func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    public class func generateThumbnail(url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        let time = CMTime(seconds: 1.0, preferredTimescale: 600)
        
        do {
            let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            let thumbnail = UIImage(cgImage: img)
            return thumbnail
        } catch {
            print("Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
    
    public class func generateThumbnailOnBkgThread(from url: URL, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let asset = AVAsset(url: url)
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            let time = CMTime(seconds: 1, preferredTimescale: 600)

            var thumbnail: UIImage?
            do {
                let cgImage = try generator.copyCGImage(at: time, actualTime: nil)
                thumbnail = UIImage(cgImage: cgImage)
            } catch {
                print("Thumbnail error: \(error)")
            }

            DispatchQueue.main.async {
                completion(thumbnail)
            }
        }
    }
    
    //MARK: - Add to chats 🔥
    public func sendNewMessageToFireBase(taskID: String, message: String = "", isfromNotify: Bool = false, senderId: Int = 0, data: [String: Any]?, files: [[String: Any]] = []) {
        guard let data else { return }
        let ref = Constants.firebseReference
        let timestamp = Date().toMillis()
        let autoId = ref.childByAutoId().key ?? "-"
        var chatNodeData: [String: Any] = [:]
        
        if isfromNotify {
            chatNodeData = ["chatId": autoId, "message":message, "senderId": senderId, "timestamp": timestamp, "isRead": false, "chatType": EnumChatType.message.rawValue]
        } else {
            guard let userData = HpGlobal.shared.userInfo else { return }
            chatNodeData = ["chatId": autoId, "message": "", "senderId": userData.userId, "timestamp": timestamp, "isRead": false, "chatType": EnumChatType.taskDescription.rawValue, "arrFiles": files, "taskTitle": data["title"] ?? "", "description": data["description"] ?? "", "displayLink": data["display_link"] ?? ""]
        }
         
        ref.child(Constants.taskChatNode).child(taskID).child(autoId).updateChildValues(chatNodeData) { err, reference in
            DispatchQueue.main.async { }
        }
    }
    
    public func updateTaskDescriptionMessage(for taskID: Int, with newData: [String: Any], view: UIView, completion: ((Bool) -> Void)? = nil) {
        let chatNodeId = "\(taskID)"
        let ref = Constants.firebseReference.child(Constants.taskChatNode).child(chatNodeId)

        Global.showLoadingSpinner(sender: view)
        debugPrint("Process Started to update task description message")
        ref.observeSingleEvent(of: .value) { snapshot in
            DispatchQueue.main.async {
                Global.dismissLoadingSpinner(view)

                guard snapshot.exists(),
                      let resData = snapshot.value as? [String: Any] else {
                    completion?(false)
                    debugPrint("Process failed")
                    return
                }
                debugPrint("Fist Phase Crossed")
                do {
                    let dict = resData.map { $0.value }
                    let data = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
                    let arr = try JSONDecoder().decode([ChatModel].self, from: data)
                    let result = arr.map({ChatViewModel(data: $0)})
                    debugPrint("Second Phase Crossed")
                    if let targetMessage = result.first(where: { $0.chatType == .taskDescription }) {
                        let chatId = targetMessage.chatId
                        let updateRef = ref.child(chatId)
                        debugPrint("Third Phase Crossed")
                        let addedData = ["chatId": targetMessage.chatId, "senderId": targetMessage.senderId, "timestamp": targetMessage.timestamp]
                        let updatedDict = newData.merging(addedData) { (_, new) in new }
                        updateRef.updateChildValues(updatedDict) { error, _ in
                            if let error = error {
                                print("Firebase update error:", error.localizedDescription)
                                completion?(false)
                            } else {
                                debugPrint("Process completed successfully")
                                completion?(true)
                            }
                        }
                    } else {
                        print("No matching taskDescription message found for taskID:", taskID)
                        completion?(false)
                    }
                } catch {
                    print("Decoding error:", error.localizedDescription)
                    completion?(false)
                }
            }
        }
    }

    
    public class func shareUserQRCode() {
        guard let data = HpGlobal.shared.userInfo else { return }
        let qrString = data.qrCode ?? ""
        if let qrImage = generateQRCode(from: qrString) {
            let activityVC = UIActivityViewController(activityItems: [qrImage], applicationActivities: nil)
            guard let getNav = UIApplication.topViewController()?.navigationController else {
                return
            }
            let rootNavView = UINavigationController(rootViewController: activityVC)
            getNav.present(rootNavView, animated: true, completion: nil)
        }
    }
    
    public class func shareToConnect() -> String {
        guard let data = HpGlobal.shared.userInfo else { return "" }
        let url = HpGlobal.shared.settingsData?.shareInvitation ?? ""
        return "\("Voici mon identifiant BeTasker :".localized) \(data.randomId.plain) \n\("Obtenez l'application BeTasker et ajoutez-moi à votre équipe.".localized)\n\(url)"
    }
    
    public class func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        filter.setValue(data, forKey: "inputMessage")
        
        guard let outputImage = filter.outputImage else { return nil }
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledImage = outputImage.transformed(by: transform)
        
        return UIImage(ciImage: scaledImage)
    }
    
    public class func extractRandomID(from urlString: String) -> String? {
        // Ensure the URL string can be converted to a URL object
        guard let url = URL(string: urlString) else { return nil }
        
        // Create URLComponents from the URL
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
        
        // Iterate over query items to find the 'random_id' parameter
        for queryItem in components.queryItems ?? [] {
            if queryItem.name == "random_id" {
                return queryItem.value
            }
        }
        
        // Return nil if 'random_id' parameter is not found
        return nil
    }
    
    public class func addLabelToImage(image: UIImage, label: UILabel) -> UIImage? {
        let tempView = UIStackView(frame: CGRect(x: 0, y: 0, width: 80, height: 50))
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: image.size.height, height: image.size.height))
        imageView.contentMode = .scaleAspectFill
        tempView.axis = .vertical
        tempView.alignment = .center
        tempView.spacing = 8
        imageView.image = image
        tempView.addArrangedSubview(imageView)
        tempView.addArrangedSubview(label)
        let renderer = UIGraphicsImageRenderer(bounds: tempView.bounds)
        let image = renderer.image { rendererContext in
            tempView.layer.render(in: rendererContext.cgContext)
        }
        return image
    }
    
    public class func openURLSafely(_ urlString: String) {
        var formatted = urlString.trimmingCharacters(in: .whitespacesAndNewlines)

        if !formatted.lowercased().hasPrefix("http://") && !formatted.lowercased().hasPrefix("https://") {
            formatted = "https://\(formatted)"
        }

        if let url = URL(string: formatted) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            print("Invalid URL: \(formatted)")
        }
    }


}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}

