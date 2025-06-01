//
//  ChatFileCell.swift
//  BeTasker
//
//  Created by kishlay kishore on 14/03/25.
//

import UIKit
import SDWebImage

class ChatFileCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var imgFile: UIImageView!
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.userCollectionView.register(UINib(nibName: "ImgUserCollectionCell", bundle: nil), forCellWithReuseIdentifier: "ImgUserCollectionCell")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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
extension ChatFileCell: UICollectionViewDataSource, UICollectionViewDelegate {
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
extension ChatFileCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 16, height: 16)
    }
}
