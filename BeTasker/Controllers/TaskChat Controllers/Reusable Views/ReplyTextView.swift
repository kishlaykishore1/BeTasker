//
//  ReplyTextView.swift
//  BeTasker
//
//  Created by kishlay kishore on 06/06/25.
//

import UIKit

class ReplyTextView: UIView {
    
    // MARK: - Outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var viewMessage: UIView!
    @IBOutlet weak var viewMessageContent: UIView!
    @IBOutlet weak var tvMessage: UITextView!
    
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    /// Custom convenience initializer
    convenience init(dataModel: RepliedToMessageViewModel, allmentionedUsers: [Mention]) {
        self.init(frame: .zero)
        let corners: UIRectCorner = dataModel.isMine ? [.topLeft, .topRight, .bottomLeft] : [.topLeft, .topRight, .bottomRight]
        configureReplyText(with: dataModel.message, mentionIds: dataModel.mentionedUserIds, allmentionedUsers: allmentionedUsers, corners: corners)
    }
    
    /// For Direct reply View convenience initializer
    convenience init(dataModel: ChatViewModel, allmentionedUsers: [Mention]) {
        self.init(frame: .zero)
        let corners: UIRectCorner = dataModel.isMine ? [.topLeft, .topRight, .bottomLeft] : [.topLeft, .topRight, .bottomRight]
        configureReplyText(with: dataModel.message, mentionIds: dataModel.mentionedUserIds, allmentionedUsers: allmentionedUsers, corners: corners)
    }
    
    // MARK: - XIB Setup
    private func commonInit() {
        Bundle.main.loadNibNamed("ReplyTextView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    func configureReplyText(with text: String, mentionIds: [String], allmentionedUsers: [Mention], corners: UIRectCorner = []) {
        DispatchQueue.main.async {
            self.viewMessageContent.roundCorners(corners, radius: 13.3)
        }
        tvMessage.isEditable = false
        tvMessage.isScrollEnabled = false
        tvMessage.dataDetectorTypes = [.link]
        tvMessage.textContainerInset = .zero
        tvMessage.textContainer.lineFragmentPadding = 0
        let mentions = mentionIds.compactMap { id in
            allmentionedUsers.first(where: { $0.id == id })
        }
        tvMessage.attributedText = MentionHelper.attributedStringForMessage(text, mentions: mentions)
    }
}
