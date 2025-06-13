//
//  ChatMessageCell.swift
//  BeTasker
//
//  Created by kishlay kishore on 14/03/25.
//

import UIKit
import SDWebImage

class ChatMessageCell: UITableViewCell {
    
    @IBOutlet weak var mainStackView: UIStackView!
    // MARK: - Outlets
    @IBOutlet weak var vwMessageContent: UIView!
    @IBOutlet weak var vwMessage: UIView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var userCollectionView: UICollectionView!
    // REPLY UI
    @IBOutlet weak var replyMainView: UIView!
    @IBOutlet weak var imgRepliedToUser: UIImageView!
    @IBOutlet weak var lblRepliedToName: UILabel!
    @IBOutlet weak var viewRepliedType: UIView!
    
    
    // MARK: - Variables
    private var swipeHandler: SwipeToReplyHandler?
    var arrMembers: [TempProfileViewModel] = [] {
        didSet {
            arrMembers.count > 0 ? (userCollectionView.isHidden = false) : (userCollectionView.isHidden = true)
            userCollectionView.delegate = self
            userCollectionView.dataSource = self
            userCollectionView.reloadData()
        }
    }
    weak var linkDelegate: LinkTapDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        swipeHandler = SwipeToReplyHandler(for: mainStackView, in: self)
        DispatchQueue.main.async {[weak self] in
            self?.vwMessage.applyShadow(radius: 4, opacity: 0.1, offset: .zero)
        }
        self.userCollectionView.register(UINib(nibName: "ImgUserCollectionCell", bundle: nil), forCellWithReuseIdentifier: "ImgUserCollectionCell")
        messageTextView.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCellView(with dataModel: ChatViewModel, allmentionedUsers: [Mention]) {
        configureTextView(with: dataModel.message, mentionIds: dataModel.mentionedUserIds, allmentionedUsers: allmentionedUsers)
        configureReplyView(with: dataModel, allmentionedUsers: allmentionedUsers)
    }
    
    private func configureReplyView(with dataModel: ChatViewModel, allmentionedUsers: [Mention]) {
        viewRepliedType.subviews.forEach { $0.removeFromSuperview() }
        
        if dataModel.hasReply {
            guard let reply = dataModel.replyOfMessage else { return }
            var replyView: UIView
            
            switch reply.chatType {
            case .message:
                if reply.message.isOnlyEmojis {
                    replyView = ReplyEmojiView(dataModel: reply)
                } else {
                    replyView = ReplyTextView(dataModel: reply, allmentionedUsers: allmentionedUsers)
                }
            case .image:
                replyView = ReplyImageView(dataModel: reply)
            case .pdf:
                replyView = ReplyFileView(dataModel: reply)
            case .status:
                replyView = ReplyStatusView(dataModel: reply)
            case .taskDescription:
                replyView = UIView()
            case .video:
                replyView = UIView()
            @unknown default:
                replyView = UIView()
            }
            
            replyMainView.isHidden = false
            replyView.translatesAutoresizingMaskIntoConstraints = false
            viewRepliedType.addSubview(replyView)
            
            NSLayoutConstraint.activate([
                replyView.topAnchor.constraint(equalTo: viewRepliedType.topAnchor, constant: 1),
                replyView.bottomAnchor.constraint(equalTo: viewRepliedType.bottomAnchor, constant: -1),
                replyView.leadingAnchor.constraint(equalTo: viewRepliedType.leadingAnchor, constant: 1),
                replyView.trailingAnchor.constraint(equalTo: viewRepliedType.trailingAnchor, constant: -1)
            ])
        } else {
            replyMainView.isHidden = true
        }
    }
    
    
    
    private func configureTextView(with text: String, mentionIds: [String], allmentionedUsers: [Mention]) {
        messageTextView.isEditable = false
        messageTextView.isScrollEnabled = false
        messageTextView.dataDetectorTypes = [.link]
        messageTextView.textContainerInset = .zero
        messageTextView.textContainer.lineFragmentPadding = 0
        let mentions = mentionIds.compactMap { id in
            allmentionedUsers.first(where: { $0.id == id })
        }
        messageTextView.attributedText = MentionHelper.attributedStringForMessage(text, mentions: mentions)
    }
    
    
    func setTheUserData(userData: TempProfileViewModel?, messageTime: String?) {
        self.lblName.text = userData?.name
        let img = #imageLiteral(resourceName: "no-user")
        self.imgUser.sd_imageIndicator = SDWebImageActivityIndicator.gray
        self.imgUser.sd_imageTransition = SDWebImageTransition.fade
        self.imgUser.sd_setImage(with: userData?.profilePicURL, placeholderImage: img)
        self.lblName.text? += " · " + "\(messageTime ?? "")"
    }
    
    func setTheRepliedToUserData(userData: TempProfileViewModel?) {
        self.lblRepliedToName.text = userData?.name
        let img = #imageLiteral(resourceName: "no-user")
        self.imgRepliedToUser.sd_imageIndicator = SDWebImageActivityIndicator.gray
        self.imgRepliedToUser.sd_imageTransition = SDWebImageTransition.fade
        self.imgRepliedToUser.sd_setImage(with: userData?.profilePicURL, placeholderImage: img)
    }
    
}

// MARK: - TextView Delegate Methods
extension ChatMessageCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        linkDelegate?.didTapLink(url: URL.absoluteString)
        return false
    }
}

// MARK: - Collection View Delegate methods
extension ChatMessageCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrMembers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImgUserCollectionCell", for: indexPath) as! ImgUserCollectionCell
        let data = arrMembers[indexPath.row]
        let img = UIImage(named: "no-user")
        cell.imgUser.sd_imageIndicator = SDWebImageActivityIndicator.gray
        cell.imgUser.sd_imageTransition = SDWebImageTransition.fade
        cell.imgUser.sd_setImage(with: data.profilePicURL, placeholderImage: img)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {  }
}

// MARK: - Collection View DelegateFlowLayout Methods
extension ChatMessageCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 16, height: 16)
    }
}
