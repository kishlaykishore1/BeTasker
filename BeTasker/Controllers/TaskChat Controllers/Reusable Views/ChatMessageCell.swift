//
//  ChatMessageCell.swift
//  BeTasker
//
//  Created by kishlay kishore on 14/03/25.
//

import UIKit
import SDWebImage

class ChatMessageCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var vwMessageContent: UIView!
    @IBOutlet weak var vwMessage: UIView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var userCollectionView: UICollectionView!
    
    // MARK: - Variables
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
    
    func configureTextView(with text: String, mentionIds: [String], allmentionedUsers: [Mention]) {
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
