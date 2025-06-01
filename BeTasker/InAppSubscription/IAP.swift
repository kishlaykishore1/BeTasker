//
//  IAP.swift
//  missing
//
//  Created by 55 agency on 02/09/23.
//


import UIKit
import StoreKit
import SwiftyStoreKit
import Alamofire

enum EnumPurchaseStatus: String {
    case purchased
    case expired
    case notPurchased
    case error
}



struct IAPSubscription {
    static let monthly = "com.betasker.monthly"
    static let yearly = "com.betasker.yearly"

    
}

class IAP: NSObject {

    public class func getProductInfo(productId: String, CompletionHandler: @escaping (_ result: SKProduct?, _ price: String) -> Void) {
        SwiftyStoreKit.retrieveProductsInfo([productId]) { result in
            if let product = result.retrievedProducts.first
            {
                let numberFormatter = NumberFormatter()
                numberFormatter.formatterBehavior = .behavior10_4
                numberFormatter.numberStyle = .currency
                numberFormatter.locale = product.priceLocale
                let formattedPrice = numberFormatter.string(from: product.price) ?? ""
                CompletionHandler(product, formattedPrice)
            } else {
                //print("Error: \(result.error)")
                CompletionHandler(nil, "")
            }
        }
    }
    
    public class func getAllProductsInfo(productId: Set<String>, CompletionHandler: @escaping (_ dict: [String: String], _ dictPrice: [String: Float]) -> Void) {
        SwiftyStoreKit.retrieveProductsInfo(productId) { result in
            var dict: [String: String] = [:]
            var dictPrice: [String: Float] = [:]
            for product in result.retrievedProducts
            {
                let numberFormatter = NumberFormatter()
                numberFormatter.formatterBehavior = .behavior10_4
                numberFormatter.numberStyle = .currency
                numberFormatter.locale = product.priceLocale
                let formattedPrice = numberFormatter.string(from: product.price) ?? ""
                dict[product.productIdentifier] = formattedPrice
                dictPrice[product.productIdentifier] = Float(truncating: product.price)
            }
            CompletionHandler(dict, dictPrice)
        }
    }
    
    public class func getAllSoSSubscriptionsInfo(CompletionHandler: @escaping (_ dict: [String: String], _ dictPrice: [String: Float], _ priceLocale: Locale, _ priceSymbol: String?) -> Void) {
        let productId: Set<String> = [
            IAPSubscription.monthly,
            IAPSubscription.yearly
        ]
        SwiftyStoreKit.retrieveProductsInfo(productId) { result in
            var dict: [String: String] = [:]
            var dictPrice: [String: Float] = [:]
            var priceLocale: Locale = Locale(identifier: Constants.lc)
            var priceSymbol = ""
            for product in result.retrievedProducts
            {
                let numberFormatter = NumberFormatter()
                numberFormatter.formatterBehavior = .behavior10_4
                numberFormatter.minimumFractionDigits = 2
                numberFormatter.numberStyle = .decimal //.currency
                numberFormatter.locale = product.priceLocale
                priceLocale = product.priceLocale
                let formattedPrice = numberFormatter.string(from: product.price) ?? ""
                priceSymbol = product.priceLocale.currencySymbol ?? ""
                dict[product.productIdentifier] = "\(formattedPrice)\(product.priceLocale.currencySymbol ?? "")"
                dictPrice[product.productIdentifier] = Float(truncating: product.price)
                print(product.localizedTitle)
            }
            CompletionHandler(dict, dictPrice, priceLocale,priceSymbol)
        }
    }
    
    public class func getAllProductsInfo(CompletionHandler: @escaping (_ dict: [String: String], _ dictPrice: [String: Float], _ priceLocale: Locale) -> Void) {
    let productId: Set<String> = [
        IAPSubscription.monthly,
        IAPSubscription.yearly
    ]
        SwiftyStoreKit.retrieveProductsInfo(productId) { result in
            var dict: [String: String] = [:]
            var dictPrice: [String: Float] = [:]
            var priceLocale: Locale = Locale(identifier: "fr")
            for product in result.retrievedProducts
            {
                let numberFormatter = NumberFormatter()
                numberFormatter.formatterBehavior = .behavior10_4
                numberFormatter.minimumFractionDigits = 2
                numberFormatter.numberStyle = .decimal //.currency
                numberFormatter.locale = product.priceLocale
                priceLocale = product.priceLocale
                let formattedPrice = numberFormatter.string(from: product.price) ?? ""
                dict[product.productIdentifier] = "\(formattedPrice) \(product.priceLocale.currencySymbol ?? "")"
                dictPrice[product.productIdentifier] = Float(truncating: product.price)
            }
            CompletionHandler(dict, dictPrice, priceLocale)
        }
    }
    
    public class func purchaseCurrentProduct(productId:String,currentView:UIView,CompletionHandler: @escaping (_ result: Bool, _ transactionId: String?, _ endDate: String?, _ price: String?) -> Void) {
        
        DispatchQueue.main.async {
            Global.showLoadingSpinner(sender: currentView)
        }
        
        SwiftyStoreKit.purchaseProduct(productId, quantity: 1, atomically: true) { result in
            
            DispatchQueue.main.async {
                Global.dismissLoadingSpinner(currentView)
            }
            
            switch result {
            case .success(let purchase):
                //print("Transaction ID:", purchase.transaction.transactionIdentifier ?? "No id")
                //print("Purchase Success: \(purchase.productId)")
                if purchase.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
                let calendar = Calendar(identifier: .gregorian)
                let endDate = calendar.date(byAdding: .month, value: 1, to: purchase.transaction.transactionDate!)
                let endDateString = Global.GetFormattedDate(date: endDate!, outputFormate: "yyyy-MM-dd HH:mm:ss", isInputUTC: true, isOutputUTC: true).dateString
                CompletionHandler(true, purchase.transaction.transactionIdentifier, endDateString, purchase.product.localizedPrice)
                
            case .error(let error):
                
                // self.automaticFuncForPurchaseAutoRenewable(productId: productId, currentView: currentView)
                
                switch error.code {
                case .unknown:
                    Common.showAlertMessage(message: "Votre achat a été annulé. Vous n’avez pas été débité.".localized)
                case .clientInvalid:
                    Common.showAlertMessage(message: "Votre achat a été annulé. Vous n’avez pas été débité.".localized)
                case .paymentCancelled:
                    Common.showAlertMessage(message: "Votre achat a été annulé. Vous n’avez pas été débité.".localized)
                case .paymentInvalid:
                    Common.showAlertMessage(message: "The purchase identifier was invalid".localized)
                case .paymentNotAllowed:
                    Common.showAlertMessage(message: "The device is not allowed to make the payment".localized)
                case .storeProductNotAvailable:
                    Common.showAlertMessage(message: "The product is not available in the current storefront".localized)
                case .cloudServicePermissionDenied:
                    Common.showAlertMessage(message: "Access to cloud service information is not allowed".localized)
                case .cloudServiceNetworkConnectionFailed:
                    Common.showAlertMessage(message: "Could not connect to the network".localized)
                case .cloudServiceRevoked:
                    Common.showAlertMessage(message: "User has revoked permission to use this cloud service".localized)
                case .privacyAcknowledgementRequired:
                    Common.showAlertMessage(message: "User privacy Acknowledgement Required".localized)
                    break
                case .unauthorizedRequestData:
                    Common.showAlertMessage(message: "User unauthorized Request Data".localized)
                    break
                case .invalidOfferIdentifier:
                    Common.showAlertMessage(message: "invalid Offer Identifier".localized)
                    break
                case .invalidSignature:
                    Common.showAlertMessage(message: "invalid Signature".localized)
                    break
                case .missingOfferParams:
                    break
                case .invalidOfferPrice:
                    break
                case .overlayCancelled:
                    break
                case .overlayInvalidConfiguration:
                    break
                case .overlayTimeout:
                    break
                case .ineligibleForOffer:
                    break
                case .unsupportedPlatform:
                    break
                case .overlayPresentedInBackgroundScene:
                    break
                @unknown default:
                    break
                }
                
                CompletionHandler(false, nil, nil, nil)
                //print("error",error.localizedDescription)
                //print("error code",error.code)
                
            case .deferred(purchase: let purchase):
                print(purchase)
            }
        }
        
    }
    
    public class func VerifyPurchase(productId: String, isRestored: Bool, CompletionHandler: @escaping (_ isExpired: Bool, _ isActive: Bool) -> Void) {
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: Constants.sharedSecreteIAP) //AppleReceiptValidator(service: .sandbox)
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            switch result {
            case .success(let receipt):
                let productId = productId
                // Verify the purchase of a Subscription
                let purchaseResult = SwiftyStoreKit.verifySubscription(
                    ofType: .autoRenewable, // or .nonRenewing (see below)
                    productId: productId,
                    inReceipt: receipt)
                
                switch purchaseResult {
                case .purchased(_, let items):
//                    if isRestored {
//                        Common.showAlertMessage(message: "Vos achats ont bien été restaurés sur votre compte 🎉".localized, alertType: .success)
//                    }
                    let products = items.sorted { first, second in
                        return first.purchaseDate > second.purchaseDate
                    }
                    if let item = products.first, let expDate = item.subscriptionExpirationDate {
                        //2021-11-15 11:09:45 +0000
                        if expDate > Date() {
                            if isRestored {
                                Common.showAlertMessage(message: "Vos achats ont bien été restaurés sur votre compte 🎉".localized, alertType: .success)
                            }
                            if let endDateString = Global.GetFormattedDate(date: expDate, outputFormate: "yyyy-MM-dd", isInputUTC: true, isOutputUTC: true).dateString {
                            UserDefaults.standard.set(endDateString, forKey: Constants.subscriptionEndDate)
                                if item.productId == IAPSubscription.monthly {
                                    UserDefaults.standard.set(true, forKey: Constants.userPremium)
                                    UserDefaults.standard.set(IAPSubscription.monthly, forKey: Constants.userSubscribedProductId)
                                } else if item.productId == IAPSubscription.yearly {
                                    UserDefaults.standard.set(true, forKey: Constants.userPremium)
                                    UserDefaults.standard.set(IAPSubscription.yearly, forKey: Constants.userSubscribedProductId)
                                } else {
                                    UserDefaults.standard.set(false, forKey: Constants.userPremium)
                                }
                            }
                        } else {
                            if isRestored {
                                Common.showAlertMessage(message: "Vos achats précédents ont expiré. Merci de bien vouloir choisir une nouvelle offre et y souscrire à nouveau.".localized)
                            }
                        }
                        CompletionHandler(expDate < Date(), true)
                    }
                case .expired(_, _):
                    
                    if isRestored {
                        Common.showAlertMessage(message: "Vos achats précédents ont expiré. Merci de bien vouloir choisir une nouvelle offre et y souscrire à nouveau.".localized, alertType: .warning)
                    }
                    CompletionHandler(true, true)
                case .notPurchased:
                    if isRestored {
                        Common.showAlertMessage(message: "Nous n'avons trouvé aucun achat précédemment effectué sur votre compte. Vérifiez que vous êtes connecté sur le même compte Apple ID avez lequel vous avez procédé au paiement initial.".localized, alertType: .warning)
                    }
                    CompletionHandler(true, false)
                }
                
            case .error(let err):
                if isRestored {
                    Common.showAlertMessage(message: "Une erreur s'est produite. Merci de bien vouloir réessayer.".localized)
                }
                CompletionHandler(true, false)
            }
        }
    }
    
    
    public class func restoreMyTransactions(currentView:UIView,CompletionHandler: @escaping (_ isExpired: Bool, _ isActive: Bool) -> Void) {
        DispatchQueue.main.async {
            Global.showLoadingSpinner(sender: currentView)
        }
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            
            var purchasedLast = [Purchase]()
            
            for purchase in results.restoredPurchases {
                purchasedLast.append(purchase)
            }

            if purchasedLast.count > 0 {
                if let purchase = purchasedLast.last {
                    if purchase.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    self.VerifyPurchase(productId: purchase.productId, isRestored: true) { (isExpired, isActive) in
                        DispatchQueue.main.async {
                            Global.dismissLoadingSpinner(currentView)
                        CompletionHandler(isExpired, isActive)
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    Global.dismissLoadingSpinner(currentView)
                    Common.showAlertMessage(message: "Nous n'avons trouvé aucun achat précédemment effectué sur votre compte. Vérifiez que vous êtes connecté sur le même compte Apple ID avez lequel vous avez procédé au paiement initial.".localized, alertType: .warning)
                    CompletionHandler(true, false)
                }
            }
        }
    }
    
    public class func checkSubscriptionStatus(for productID: String, completion: @escaping(_ status: EnumPurchaseStatus)->()) {
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: Constants.sharedSecreteIAP)
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            switch result {
             case .success(let receipt):
                let test = SwiftyStoreKit.verifySubscription(ofType: .autoRenewable, productId: productID, inReceipt: receipt)
                switch test {
                case .purchased(let expiryDate, let items):
                    print("purchased")
                    completion(.purchased)
                case .expired(let expiryDate, let items):
                    print("Product is expired.")
                    completion(.expired)
                case .notPurchased:
                    print("Product is not purchased.")
                    completion(.notPurchased)
                }
            case .error(let error):
                print("Receipt verification failed: \(error)")
                completion(.error)
            }
        }
    }
    
    public class func checkPurchaseStatus(for productID: String, completion: @escaping(_ isPurchased: Bool)->()) {
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: Constants.sharedSecreteIAP)
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            switch result {
             case .success(let receipt):
                let verifyResult = SwiftyStoreKit.verifyPurchase(productId: productID, inReceipt: receipt)
                
                switch verifyResult {
                case .purchased(let item):
                    print("Product is purchased.")
                    completion(true)
                case .notPurchased:
                    print("Product is not purchased.")
                    completion(false)
                }
            case .error(let error):
                print("Receipt verification failed: \(error)")
                completion(false)
            }
        }
    }
    
}
