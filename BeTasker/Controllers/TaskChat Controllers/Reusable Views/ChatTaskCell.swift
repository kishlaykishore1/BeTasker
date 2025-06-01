//
//  ChatTaskCell.swift
//  BeTasker
//
//  Created by kishlay kishore on 14/03/25.
//

import UIKit
import SDWebImage

protocol LinkTapDelegate: AnyObject {
    func didTapLink(url: String)
}

class ChatTaskCell: UITableViewCell {
    
    // MARK: - Outlets    
    @IBOutlet weak var lblTaskTitle: UILabel!
    @IBOutlet weak var lblTaskDescp: UILabel!
    @IBOutlet weak var seeMoreButton: UIButton!
    @IBOutlet weak var lblTaskLink: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var clnView: UICollectionView!
    @IBOutlet weak var linkView: UIView!
    @IBOutlet weak var viewDescription: UIView!
    @IBOutlet weak var backView: UIView!
    
    // MARK: - Variables
    weak var delegate: CollectionTableViewCellDelegate?
    weak var linkDelegate: LinkTapDelegate?
    var detectedLink: String?
    var seeMoreTapped: (() -> Void)?
    
    var arrImages: [FileViewModel] = [] {
        didSet {
            clnView.delegate = self
            clnView.dataSource = self
            clnView.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        seeMoreButton.setTitle("Voir plus".localized, for: .normal)
        seeMoreButton.isHidden = true
        self.clnView.register(UINib(nibName: "CollectionBigFileCell", bundle: nil), forCellWithReuseIdentifier: "CollectionBigFileCell")
        DispatchQueue.main.async { [weak self] in
            self?.backView.applyShadow(radius: 3, opacity: 0.1, offset: .zero)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configureCellData(for dataModel: ChatViewModel) {
        lblTaskTitle.text = dataModel.title
        if dataModel.description.isEmpty {
            viewDescription.isHidden = true
        } else {
            viewDescription.isHidden = false
            setTaskDescription(with: dataModel)
        }
        if dataModel.displayLink == "" {
            linkView.isHidden = true
            lblTaskLink.text = nil
        } else {
            linkView.isHidden = false
            setTheAttributedLabel(text: dataModel.displayLink, link: dataModel.displayLink)
        }
        arrImages = dataModel.arrImages
        clnView.isHidden = dataModel.arrImages.count == 0
    }
    
    func setTaskDescription(with viewModel: ChatViewModel) {
        let text = viewModel.description
        lblTaskDescp.text = text.isEmpty ? nil : text
        lblTaskDescp.numberOfLines = viewModel.isExpanded ? 0 : 3
        seeMoreButton.setTitle(viewModel.isExpanded ? "Voir moins".localized : "Voir plus".localized, for: .normal)

        // 🔐 Manual text height calculation
        let maxLines = 3
        let font = lblTaskDescp.font ?? UIFont.systemFont(ofSize: 16, weight: .regular)
        let labelWidth = UIScreen.main.bounds.width - 20 // Adjust for actual padding/margins in your cell

        let textAttributes: [NSAttributedString.Key: Any] = [.font: font]
        let attributedText = NSAttributedString(string: text, attributes: textAttributes)

        let boundingRect = attributedText.boundingRect(
            with: CGSize(width: labelWidth, height: CGFloat.greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )

        let lineHeight = font.lineHeight
        let totalLines = Int(ceil(boundingRect.height / lineHeight))

        seeMoreButton.isHidden = totalLines <= maxLines
    }



    
    func setTheAttributedLabel(text: String, link: String) {
        lblTaskLink.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        lblTaskLink.addGestureRecognizer(tapGesture)
        let (attributedString, link) = detectAndStyleLink(in: link, link: link)
        lblTaskLink.attributedText = attributedString
        detectedLink = link
    }
    
    func setTheUserData(userData: TempProfileViewModel?, messageTime: String?) {
        self.lblUserName.text = userData?.name
        let img = #imageLiteral(resourceName: "no-user")
        self.imgUser.sd_imageIndicator = SDWebImageActivityIndicator.gray
        self.imgUser.sd_imageTransition = SDWebImageTransition.fade
        self.imgUser.sd_setImage(with: userData?.profilePicURL, placeholderImage: img)
        self.lblTime.text = messageTime ?? ""
    }
    
    private func detectAndStyleLink(in text: String, link: String) -> (NSAttributedString, String?) {
        let attributedString = NSMutableAttributedString(string: text)
        
        guard let range = text.range(of: link) else {
                return (attributedString, nil)
            }
        let nsRange = NSRange(range, in: text)
        
        // Apply link style
        attributedString.addAttribute(.foregroundColor, value: #colorLiteral(red: 0.1270436943, green: 0.5698190331, blue: 1, alpha: 1), range: nsRange)
        attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: nsRange)
        
        let extractedLink = String(text[range.lowerBound...])
        return (attributedString, extractedLink)
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        if let link = detectedLink {
            linkDelegate?.didTapLink(url: link)
        }
    }
    
    
    @IBAction func seeMoreButton_Action(_ sender: UIButton) {
        Global.setVibration()
        seeMoreTapped?()
    }
    
    
}

// MARK: - Collection View Delegates and Datasources
extension ChatTaskCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionBigFileCell", for: indexPath) as! CollectionFileCell
        let data = arrImages[indexPath.row]
        let img = #imageLiteral(resourceName: "no-user")
        cell.imgItem.sd_imageIndicator = SDWebImageActivityIndicator.gray
        cell.imgItem.sd_imageTransition = SDWebImageTransition.fade
        cell.imgItem.sd_setImage(with: data.imageURL, placeholderImage: img)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedItem = arrImages[indexPath.item]
        delegate?.didSelectItem(imageData: selectedItem, arrImageData: arrImages, currentIndex: indexPath.row)
    }
}

// MARK: - Collection View DelegateFlowLayout Methods
extension ChatTaskCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 188.0, height: 190.0)
    }
}
