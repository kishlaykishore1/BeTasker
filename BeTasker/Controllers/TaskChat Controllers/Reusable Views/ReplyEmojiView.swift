//
//  ReplyEmojiView.swift
//  BeTasker
//
//  Created by kishlay kishore on 13/06/25.
//

import UIKit

class ReplyEmojiView: UIView {

    // MARK: - Outlets
    @IBOutlet var contentView: UIView!
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
    convenience init(dataModel: RepliedToMessageViewModel) {
        self.init(frame: .zero)
        configureReplyText(with: dataModel.message)
    }
    
    /// For Direct reply View convenience initializer
    convenience init(dataModel: ChatViewModel) {
        self.init(frame: .zero)
        configureReplyText(with: dataModel.message)
    }
    
    // MARK: - XIB Setup
    private func commonInit() {
        Bundle.main.loadNibNamed("ReplyEmojiView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    func configureReplyText(with text: String) {
        tvMessage.text = text
        tvMessage.isEditable = false
        tvMessage.isScrollEnabled = false
        tvMessage.textContainerInset = .zero
        tvMessage.textContainer.lineFragmentPadding = 0
        tvMessage.backgroundColor = .clear
    }
}
