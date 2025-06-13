//
//  EmojiMessageCell.swift
//  BeTasker
//
//  Created by kishlay kishore on 13/06/25.
//

import UIKit
import SDWebImage

class EmojiMessageCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var vwMessageContent: UIView!
    @IBOutlet weak var vwMessage: UIView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var userCollectionView: UICollectionView!

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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        swipeHandler = SwipeToReplyHandler(for: mainStackView, in: self)
        self.userCollectionView.register(UINib(nibName: "ImgUserCollectionCell", bundle: nil), forCellWithReuseIdentifier: "ImgUserCollectionCell")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCellView(with dataModel: ChatViewModel) {
        configureTextView(with: dataModel.message)
    }
    
    private func configureTextView(with text: String) {
        messageTextView.text = text
        messageTextView.isEditable = false
        messageTextView.isScrollEnabled = false
        messageTextView.textContainerInset = .zero
        messageTextView.textContainer.lineFragmentPadding = 0
        messageTextView.backgroundColor = .clear
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

// MARK: - Collection View Delegate methods
extension EmojiMessageCell: UICollectionViewDataSource, UICollectionViewDelegate {
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
extension EmojiMessageCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 16, height: 16)
    }
}
