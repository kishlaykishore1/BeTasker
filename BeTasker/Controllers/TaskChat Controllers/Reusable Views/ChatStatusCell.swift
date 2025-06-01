//
//  ChatStatusCell.swift
//  BeTasker
//
//  Created by kishlay kishore on 14/03/25.
//

import UIKit
import SDWebImage

protocol CollectionTableViewCellDelegate: AnyObject {
    func didSelectItem(imageData: FileViewModel, arrImageData: [FileViewModel], currentIndex: Int)
}

class ChatStatusCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var clnView: UICollectionView!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var vwStatus: UIView!
    @IBOutlet weak var userCollectionView: UICollectionView!
    
    // MARK: - Variables
    weak var delegate: CollectionTableViewCellDelegate?
    
    var arrImages: [FileViewModel] = [] {
        didSet {
            clnView.delegate = self
            clnView.dataSource = self
            clnView.reloadData()
        }
    }
    
    var arrMembers: [TempProfileViewModel] = [] {
        didSet {
            arrMembers.count > 0 ? (userCollectionView.isHidden = false) : (userCollectionView.isHidden = true)
            userCollectionView.delegate = self
            userCollectionView.dataSource = self
            userCollectionView.reloadData()
        }
    }
    var videoThumbnailCache = NSCache<NSURL, UIImage>()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.clnView.register(UINib(nibName: "CollectionFileCell", bundle: nil), forCellWithReuseIdentifier: "CollectionFileCell")
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
extension ChatStatusCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == clnView {
            return arrImages.count
        } else {
            return arrMembers.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == clnView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionFileCell", for: indexPath) as! CollectionFileCell
            let data = arrImages[indexPath.row]
            let img = UIImage(named: "img_PlaceHolder")
            cell.imgItem.contentMode = .center
            guard let url = data.imageURL else {
                cell.imgItem.image = img
                return cell
            }
            
            if url.isVideoURL {
                // Show video thumbnail
                cell.imgItem.image = img
                if let cached = videoThumbnailCache.object(forKey: url as NSURL) {
                    cell.imgItem.image = cached
                    cell.playIcon.isHidden = false
                } else {
                    Global.generateThumbnailOnBkgThread(from: url) { thumbnail in
                        if let thumbnail = thumbnail {
                            self.videoThumbnailCache.setObject(thumbnail, forKey: url as NSURL)
                            cell.imgItem.image = thumbnail
                        } else {
                            cell.imgItem.image = img
                        }
                        cell.playIcon.isHidden = false
                    }
                }
            } else {
                // Show image
                cell.playIcon.isHidden = true
                cell.imgItem.sd_imageIndicator = SDWebImageActivityIndicator.gray
                cell.imgItem.sd_imageTransition = SDWebImageTransition.fade
                cell.imgItem.sd_setImage(with: data.imageURL, placeholderImage: img) { [weak imgFile = cell.imgItem] image, error,_,_ in
                    if let _ = error {
                        imgFile?.contentMode = .center
                        imgFile?.image = img
                    } else {
                        imgFile?.contentMode = .scaleAspectFill
                    }
                }
                
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImgUserCollectionCell", for: indexPath) as! ImgUserCollectionCell
            let data = arrMembers[indexPath.row]
            let img = UIImage(named: "no-user")
            cell.imgUser.sd_imageIndicator = SDWebImageActivityIndicator.gray
            cell.imgUser.sd_imageTransition = SDWebImageTransition.fade
            cell.imgUser.sd_setImage(with: data.profilePicURL, placeholderImage: img)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == clnView {
            let selectedItem = arrImages[indexPath.item]
            delegate?.didSelectItem(imageData: selectedItem, arrImageData: arrImages, currentIndex: indexPath.row)
        }
    }
}

// MARK: - Collection View DelegateFlowLayout Methods
extension ChatStatusCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == clnView {
            return CGSize(width: 90.0, height: 78.0)
        } else {
            return CGSize(width: 16.0, height: 16.0)
        }
    }
}

