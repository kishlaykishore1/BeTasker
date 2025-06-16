//
//  MentionHelper.swift
//  BeTasker
//
//  Created by kishlay kishore on 18/05/25.
//

import Foundation
import UIKit
import SDWebImage

struct Mention {
    let id: String
    let displayName: String
    let randomId: String?
    let profileImage: URL?
}

class MentionHelper {
    
    static func insertMention(_ mention: Mention, into textView: UITextView, allMentions: [Mention])  {
        let mentionText = "@\(mention.displayName)"
        
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(named: "TextColor-Black")!,
            .font: UIFont(name: Constants.KMonteserratSemibold, size: 14) ?? UIFont.systemFont(ofSize: 14, weight: .semibold),
            .mention: mention.id
        ]
        
        let attributedMention = NSAttributedString(string: mentionText, attributes: attributes)
        
        let mutableText = NSMutableAttributedString(attributedString: textView.attributedText)
        let selectedRange = textView.selectedRange
        mutableText.replaceCharacters(in: selectedRange, with: attributedMention)
        textView.attributedText = mutableText
        textView.selectedRange = NSRange(location: selectedRange.location + mentionText.count, length: 0)
        print("Inserting mention: @\(mention.displayName), id: \(mention.id)")
        
        refreshMentions(in: textView, knownMentions: allMentions)
        
        // ✅ Reset typing attributes after mention
        textView.typingAttributes = [
            .foregroundColor: UIColor.label,
            .font: UIFont(name: Constants.KMonteserratMedium, size: 14) ?? UIFont.systemFont(ofSize: 14, weight: .medium)
        ]
    }
    
    static func prepareMessageForSending(from attributedText: NSAttributedString, using allMentions: [Mention]) -> (message: String, mentions: [Mention]) {
        var plainText = ""
        var mentions: [Mention] = []
        
        attributedText.enumerateAttributes(in: NSRange(location: 0, length: attributedText.length), options: []) { attrs, range, _ in
            if let mentionId = attrs[.mention] as? String {
                if let mention = allMentions.first(where: { $0.id == mentionId }) {
                    mentions.append(mention)
                    plainText += "@\(mention.displayName)"
                }
            } else {
                let substring = attributedText.attributedSubstring(from: range).string
                plainText += substring
            }
        }
        
        return (plainText, mentions)
    }
    
    static func attributedStringForMessage(_ message: String, mentions: [Mention], isFromEditToTextView: Bool = false) -> NSAttributedString {
        let defaultFont = isFromEditToTextView ? UIFont(name: Constants.KMonteserratMedium, size: 14) ?? UIFont.systemFont(ofSize: 14, weight: .medium) : UIFont(name: Constants.KGraphikMedium, size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .medium)
        let defaultColor = UIColor(named: "Color2D2D2D-F8F8F8")!
        
        let attributed = NSMutableAttributedString(
            string: message,
            attributes: [
                .font: defaultFont,
                .foregroundColor: defaultColor
            ]
        )
        
        for mention in mentions {
            let mentionText = "@\(mention.displayName)"
            var searchRange = NSRange(location: 0, length: attributed.length)
            
            while true {
                let range = (attributed.string as NSString).range(of: mentionText, options: [], range: searchRange)
                if range.location == NSNotFound { break }
                
                attributed.addAttribute(.foregroundColor, value: defaultColor, range: range)
                attributed.addAttribute(.font, value: isFromEditToTextView ? UIFont(name: Constants.KMonteserratSemibold, size: 14) ?? UIFont.systemFont(ofSize: 14, weight: .semibold) : UIFont(name: Constants.KGraphikSemibold, size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .medium), range: range)
                attributed.addAttribute(.mention, value: mention.id, range: range)
                
                let nextLocation = range.location + range.length
                if nextLocation >= attributed.length { break }
                searchRange = NSRange(location: nextLocation, length: attributed.length - nextLocation)
            }
        }
        
        return attributed
    }
    
    static func refreshMentions(in textView: UITextView, knownMentions: [Mention]) {
        let fullText = NSMutableAttributedString(attributedString: textView.attributedText)
        
        for mention in knownMentions {
            let mentionText = "@\(mention.displayName)"
            var searchRange = NSRange(location: 0, length: fullText.length)
            
            while true {
                let foundRange = (fullText.string as NSString).range(of: mentionText, options: [], range: searchRange)
                
                if foundRange.location == NSNotFound { break }
                
                // Avoid overwriting unrelated matches
                let currentAttributes = fullText.attributes(at: foundRange.location, effectiveRange: nil)
                let alreadyTagged = currentAttributes[.mention] != nil
                
                if !alreadyTagged {
                    fullText.addAttributes([
                        .foregroundColor: UIColor(named: "TextColor-Black")!,
                        .mention: mention.id,
                        .font: UIFont(name: Constants.KMonteserratSemibold, size: 14) ?? UIFont.systemFont(ofSize: 14, weight: .semibold)
                    ], range: foundRange)
                }
                
                // Move to next possible match
                let nextLocation = foundRange.location + foundRange.length
                searchRange = NSRange(location: nextLocation, length: fullText.length - nextLocation)
            }
        }
        textView.attributedText = fullText
    }
    
    
    
    
    static func extractMentions(from attributedText: NSAttributedString) -> [Mention] {
        var mentions: [Mention] = []
        
        attributedText.enumerateAttributes(in: NSRange(location: 0, length: attributedText.length), options: []) { attrs, range, _ in
            if let mentionId = attrs[.mention] as? String {
                let name = attributedText.attributedSubstring(from: range).string.replacingOccurrences(of: "@", with: "")
                let mention = Mention(id: mentionId, displayName: name, randomId: nil, profileImage: nil)
                mentions.append(mention)
            }
        }
        
        return mentions
    }
    
    static func applyAttributedTextSafely(to textView: UITextView, message: String, mentions: [Mention]) {
        textView.attributedText = MentionHelper.attributedStringForMessage(message, mentions: mentions, isFromEditToTextView: true)
        textView.typingAttributes = [
            .foregroundColor: UIColor.label,
            .font: UIFont(name: Constants.KMonteserratMedium, size: 14) ?? UIFont.systemFont(ofSize: 14, weight: .medium)
        ]
    }
    
    static func getCurrentMentionQuery(_ textView: UITextView) -> (query: String, range: NSRange)? {
        guard let selectedRange = textView.selectedTextRange else { return nil }
        let cursorPosition = textView.offset(from: textView.beginningOfDocument, to: selectedRange.start)
        let text = textView.text as NSString
        let upToCursor = text.substring(to: cursorPosition)

        // Find last occurrence of '@' followed by word characters before cursor
        if let match = upToCursor.range(of: "@[a-zA-Z0-9_]*$", options: .regularExpression) {
            let nsRange = NSRange(match, in: upToCursor)
            let mentionText = (upToCursor as NSString).substring(with: nsRange)
            let query = mentionText.replacingOccurrences(of: "@", with: "")
            return (query: query, range: nsRange)
        }

        return nil
    }

    
    
}

extension NSAttributedString.Key {
    static let mention = NSAttributedString.Key("mention")
}
