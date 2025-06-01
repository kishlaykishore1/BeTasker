//
//  ReviewManager.swift
//  BeTasker
//
//  Created by kishlay kishore on 28/05/25.
//

import Foundation
import StoreKit

import StoreKit

final class ReviewManager {
    
    // MARK: - Singleton Instance
    static let shared = ReviewManager()
    
    private init() {}  // Prevent external initialization
    
    private let reviewKey = "hasRequestedReviewForVersion"
    
    // MARK: - Request Review if Appropriate
    func requestReviewIfAppropriate() {
        guard let windowScene = UIApplication.shared
            .connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else {
                return
        }

        let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        let lastVersionPrompted = UserDefaults.standard.string(forKey: reviewKey)
        
        // Only show if not already shown for this version
        guard lastVersionPrompted != currentVersion else { return }
        
        SKStoreReviewController.requestReview(in: windowScene)
        UserDefaults.standard.set(currentVersion, forKey: reviewKey)
    }

    // Optional: Reset for testing
    func resetReviewFlag() {
        UserDefaults.standard.removeObject(forKey: reviewKey)
    }
}

