//
//  SubscriptionVC.swift
//  teamAlerts
//
//  Created by B2Cvertical A++ on 29/11/24.
//

import UIKit
import StoreKit
class SubscriptionVC: UIViewController {
    
    @IBOutlet weak var vwSaveMessage: UIView!
    @IBOutlet weak var lblSaveMessage: UILabel!
    @IBOutlet weak var lblCost2: UILabel!
    @IBOutlet weak var lblCost1: UILabel!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var vwTwelveMonths: UIView!
    @IBOutlet weak var vwOneMonth: UIView!
    
    @IBOutlet weak var lblDuration2: UILabel!
    var dictPrices: [String: Float] = [:]
    var dictPricesFormatted: [String: String] = [:]
    var priceLocale: Locale = Locale(identifier: "fr")
    var priceSymbol: String = ""
    var selectedSubscription: String = "" //S
    var delegate: PrClose?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        vwOneMonth.setShadowWithColor(color: .black, opacity: 0.2, offset: CGSize(width: 0, height: 1), radius: 8, viewCornerRadius: 28)
        vwTwelveMonths.setShadowWithColor(color: .black, opacity: 0.2, offset: CGSize(width: 0, height: 1), radius: 8, viewCornerRadius: 28)
        vwSaveMessage.setShadowWithColor(color: .label, opacity: 0.2, offset: CGSize(width: 0, height: 1), radius: 8, viewCornerRadius: 16)
        
        //        let clr = UIColor.label
        //        let text1 = "Le plus rentable".localized
        //        let text2 = " - 3,74€/mois soit 50% d’économie".localized
        //        lblSaveMessage.attributedText = Global.setAttributedText(arrText: [(text: text1, fontName: FontName.Graphik.medium, size: 12, weight: .medium, clr: clr), (text: text2, fontName: FontName.Graphik.regular, size: 12, weight: .regular, clr: clr)])
        fetchInAppProducts()
    }
    
    func fetchInAppProducts() {
        GetAllPrices {
            DispatchQueue.main.async {
                print("dictPrices = \(self.dictPrices)")
                print("dictPricesFormatted = \(self.dictPricesFormatted)")
                print("priceLocale = \(self.priceLocale)")
                self.updateSubscriptionInterface()
            }
        }
    }
    
    func updateSubscriptionInterface() {
        let cost1Text:String = self.dictPricesFormatted[IAPSubscription.monthly] ?? ""
        self.lblCost1.text = "\(cost1Text)"
        
        let cost2Text:String = self.dictPricesFormatted[IAPSubscription.yearly] ?? ""
        self.lblCost2.text = "\(cost2Text)"
        
        let monthlyPrice:Float = self.dictPrices[IAPSubscription.monthly] ?? 5.99
        let YearlyPrice:Float = self.dictPrices[IAPSubscription.yearly] ?? 44.99
        
        //let priceDiff = (12 * monthlyPrice) - YearlyPrice
        let perMonthBenefit = YearlyPrice/12
        let roundedValue = Double(perMonthBenefit).cutOffDecimalsAfter(2)
        
        let perMonthNumber = NSDecimalNumber(value: roundedValue)
        
        let numberFormatter = NumberFormatter()
        numberFormatter.formatterBehavior = .behavior10_4
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.numberStyle = .decimal //.currency
        numberFormatter.locale = self.priceLocale
        let formattedperMonthBenefit = numberFormatter.string(from: perMonthNumber) ?? ""
        let currentPricePercentage:Int = Int(perMonthBenefit/monthlyPrice * 100)
        
        //let discPercentage = Int((perMonthBenefit/monthlyPrice) * 100)
        let discPercentage = 100 - currentPricePercentage
        
        
        let clr = UIColor.label
        let text1 = "Le plus rentable".localized
        let text2 = " \(formattedperMonthBenefit)\(self.priceSymbol)/\("mois soit".localized) \(discPercentage)% \("d’économie".localized)"
        lblSaveMessage.attributedText = Global.setAttributedText(arrText: [(text: text1, fontName: FontName.Graphik.medium, size: 12, weight: .medium, clr: clr), (text: text2, fontName: FontName.Graphik.regular, size: 12, weight: .regular, clr: clr)])
        
    }
    @IBAction func restoreAction(_ sender: UIButton) {
        Global.setVibration()
        IAP.restoreMyTransactions(currentView: self.view) { isExpired, isActive in
            if isActive && !isExpired {
                let enddate = UserDefaults.standard.value(forKey: Constants.subscriptionEndDate) as? String ?? self.selectedSubscription == IAPSubscription.yearly ? self.toGetEndDate(type: 1) : self.toGetEndDate(type: 0)
                self.callUpdatePremium(premium: 1, endDate: enddate)
                UserDefaults.standard.set(true, forKey: Constants.userSubscribed)
                self.dismiss(animated: true) {
                    self.delegate?.closedDelegateAction()
                }
            }
        }
    }
    
    @IBAction func purchaseYearlySubscription(_ sender: UIButton) {
        self.selectedSubscription = IAPSubscription.yearly
        self.purchaseSelectedSubscription()
        
    }
    @IBAction func purchaseMonthlySubscription(_ sender: UIButton) {
        self.selectedSubscription = IAPSubscription.monthly
        self.purchaseSelectedSubscription()
    }
    @IBAction func closeAction(_ sender: Any) {
        Global.setVibration()
        self.dismiss(animated: true)
    }
    
    @IBAction func opentTerms(_ sender: Any) {
        Global.setVibration()
        guard let data = HpGlobal.shared.settingsData else { return }
        
        let vc = Constants.Main.instantiateViewController(withIdentifier: "WebViewVC") as! WebViewVC
        vc.titleString = "Conditions Générales d’Utilisation".localized
        vc.url = data.termsCondition
        let nvc = UINavigationController(rootViewController: vc)
        if #available(iOS 13.0, *) {
            nvc.isModalInPresentation = true
        } else {
            // Fallback on earlier versions
        }
        self.present(nvc, animated: true, completion: nil)
    }
    
    @IBAction func openPrivacyPolicy(_ sender: Any) {
        Global.setVibration()
        guard let data = HpGlobal.shared.settingsData else { return }
        
        let vc = Constants.Main.instantiateViewController(withIdentifier: "WebViewVC") as! WebViewVC
        vc.titleString = "Politique de confidentialité".localized
        vc.url = data.confidentiality
        let nvc = UINavigationController(rootViewController: vc)
        if #available(iOS 13.0, *) {
            nvc.isModalInPresentation = true
        } else {
            // Fallback on earlier versions
        }
        self.present(nvc, animated: true, completion: nil)
    }
    
    // 0 --- Monthly , 1 ---- Yearly
    func toGetEndDate(type: Int) -> String {
        let currentDate = Date()
        let updatedDate = type == 0 ? Calendar.current.date(byAdding: .month, value: 1, to: currentDate)! : Calendar.current.date(byAdding: .year, value: 1, to: currentDate)!
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let formattedDate = dateFormatter.string(from: updatedDate)
        print(formattedDate)  // Example output: 2026-03-28
        return formattedDate
    }
    
    fileprivate func GetAllPrices(completion: @escaping()->()) {
        Global.showLoadingSpinner(sender: self.view)
        IAP.getAllSoSSubscriptionsInfo { (dict, dictPrices, priceLocale,pSymbol)  in
            DispatchQueue.main.async {
                Global.dismissLoadingSpinner(self.view)
                self.dictPricesFormatted = dict
                self.dictPrices = dictPrices
                self.priceLocale = priceLocale
                self.priceSymbol = pSymbol ?? ""
                completion()
            }
        }
    }
    func purchaseSelectedSubscription() {
        IAP.purchaseCurrentProduct(productId: selectedSubscription, currentView: self.view) { result, transactionId, endDate, price in
            DispatchQueue.main.async {
                Global.dismissLoadingSpinner(self.view)
                guard result == true else { return }
                Common.showAlertMessage(message: "Successfully purchased.".localized, alertType: .success)
                let enddate = self.selectedSubscription == IAPSubscription.yearly ? self.toGetEndDate(type: 1) : self.toGetEndDate(type: 0)
                self.callUpdatePremium(premium: 1, endDate: enddate)
                UserDefaults.standard.set(self.selectedSubscription, forKey: Constants.userSubscribedProductId)
                UserDefaults.standard.set(true, forKey: Constants.userSubscribed)
                self.dismiss(animated: true) {
                    self.delegate?.closedDelegateAction()
                }
            }
        }
    }
    
    func purchaseSubscription() {
        //        IAP.purchaseCurrentProduct(productId: selectedSubscription, currentView: self.view) { result, transactionId, endDate, price in
        //            DispatchQueue.main.async {
        //                Global.dismissLoadingSpinner(self.view)
        //                guard result == true else { return }
        //                guard self.isPayingForOther == false else {
        //                    self.purchaseForOther(paymentMethod: .InApp, transactionId: transactionId, amount: self.dictPrices[self.selectedSubscription] ?? 0, intentId: nil, cardType: "")
        //                    return
        //                }
        //
        //                if result == true {
        //                    var dict = [[String: Any]]()
        //                    for item in self.arrMembers {
        //                        var obj = [String: Any]()
        //                        obj["invite_user_id"] = item.userIdSosAlert
        //                        obj["payforyou_user_id"] = 0
        //                        obj["is_nominee"] = 0
        //                        obj["is_for_access"] = 1
        //                        dict.append(obj)
        //                    }
        //                    let dictMembers = Global.stringifyJson(dict, prettyPrinted: false)
        //                    var params: [String: Any] = [
        //                        "alert_members": dictMembers ?? "",
        //                        "configure_for": "InviteOne",
        //                        "is_location": 1,
        //                        "is_camera": 1,
        //                        "is_microphone": 1,
        //                        "is_critical_notification": 1,
        //                        //"secret_code": self.secreteCode ?? "",
        //                        "is_audio_video_permission": self.isVideoOptionChosen ? 1 : 0,
        //                        "number_of_contact": self.segmentControl.selectedSegmentIndex + 1,
        //                        "user_alert_id": self.userAlertId ?? 0,
        //                        "is_send_pay_request": 1,
        //                        "payforyou_contact_ids": "",
        //                        "amount": self.dictPrices[self.selectedSubscription] ?? 0, //price ?? "",
        //                        "package": "1 month",
        //                        //"releted_id": HpGlobal.shared.mandateData.id ?? 0,
        //                        "payment_id": transactionId ?? "",
        //                        "device_type": Constants.DEVICETYPE,
        //                        "end_date_time": endDate ?? "",
        //                        "payment_status": "purchased",
        //                        "payment_gateway": "Apple Store",
        //                        "paid_by":"InApp",
        //                        "in_app_product_id": self.selectedSubscription,
        //                        "purchase_type": "SoS"
        //                    ]
        //                    if self.isForRenew == false {
        //                        params["secret_code"] = self.secreteCode ?? ""
        //                    }
        //                    let api = self.isForRenew ? HpAPI.renewAlertData : HpAPI.setupAlertData
        //                    api.DataAPI(params: params, shouldShowError: true, shouldShowSuccess: false, key: nil) { (response: Result<GeneralModel, Error>) in
        //                        DispatchQueue.main.async {
        //                            switch response {
        //                            case .success(_):
        //                                let vc = StoryBoard.SOSAlerts.instantiateViewController(withIdentifier: "FinishSosVC") as! FinishSosVC
        //                                vc.isInvite = false
        //                                vc.hidesBottomBarWhenPushed = true
        //                                self.navigationController?.pushViewController(vc, animated: true)
        //                            case .failure(_):
        //                                break
        //                            }
        //                        }
        //                    }
        //                }
        //            }
        //        }
    }
}

extension SubscriptionVC {
    func callUpdatePremium(premium: Int, endDate: String) {
        updatePremiumAPI(premium: premium, endDate: endDate, showloader: true) { userData, userModel in
            DispatchQueue.main.async {
                HpGlobal.shared.userInfo = userData
            }
        }
    }
    
    private func updatePremiumAPI(premium: Int, endDate: String, showloader: Bool = false, completion: @escaping(_ userData: ProfileDataViewModel, _ userModel: ProfileModel?)->()) {
        let params: [String: Any] = [
            "is_premium": premium,
            "premium_end_date": endDate,
        ]
        DispatchQueue.main.async {
            if showloader {
                Global.showLoadingSpinner(nil, sender: self.view)
            }
        }
        HpAPI.userPremium.DataAPI(params: params, shouldShowError: false, shouldShowSuccess: false, key: "data") { (response: Result<ProfileModel, Error>) in
            DispatchQueue.main.async {
                Global.dismissLoadingSpinner(self.view)
                switch response {
                case .failure(let error):
                    debugPrint(error.localizedDescription)
                    if let err = error as? ErrorTypesAPP {
                        switch err {
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
}

