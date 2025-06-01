//
//  StatusHistoryTableCell.swift
//  BeTasker
//
//  Created by kishlay kishore on 20/03/25.
//

import UIKit
import SDWebImage

class StatusHistoryTableCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var viewStatus: UIView!
    @IBOutlet weak var lblStatusDate: UILabel!
    @IBOutlet weak var viewWithStatus: UIView!
    
    // MARK: - Variables
    weak var delegate: CollectionTableViewCellDelegate?
    var arrImages: [FileViewModel] = [] {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.reloadData()
        }
    }
    var videoThumbnailCache = NSCache<NSURL, UIImage>()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.collectionView.register(UINib(nibName: "CollectionFileCell", bundle: nil), forCellWithReuseIdentifier: "CollectionFileCell")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setTheUserData(userData: TempProfileViewModel?) {
        self.lblName.text = userData?.name
        let img = #imageLiteral(resourceName: "no-user")
        self.imgUser.sd_imageIndicator = SDWebImageActivityIndicator.gray
        self.imgUser.sd_imageTransition = SDWebImageTransition.fade
        self.imgUser.sd_setImage(with: userData?.profilePicURL, placeholderImage: img)
    }
}

// MARK: - Collection View Delegate methods
extension StatusHistoryTableCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionFileCell", for: indexPath) as! CollectionFileCell
        let data = arrImages[indexPath.row]
        let img = #imageLiteral(resourceName: "no-user")
        
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
            cell.imgItem.sd_setImage(with: data.imageURL, placeholderImage: img)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedItem = arrImages[indexPath.item]
        delegate?.didSelectItem(imageData: selectedItem, arrImageData: arrImages, currentIndex: indexPath.row)
    }
}

// MARK: - Collection View DelegateFlowLayout Methods
extension StatusHistoryTableCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 90.0, height: 78.0)
    }
}
