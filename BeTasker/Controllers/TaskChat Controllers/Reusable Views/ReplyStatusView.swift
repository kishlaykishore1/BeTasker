//
//  ReplyStatusView.swift
//  BeTasker
//
//  Created by kishlay kishore on 06/06/25.
//

import UIKit
import SDWebImage

class ReplyStatusView: UIView {
    
    // MARK: - Outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var viewStatus: UIView!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Variables
    var arrImages: [FileViewModel] = [] {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.reloadData()
        }
    }
    
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
        configureReplyStatus(with: dataModel)
    }
    
    /// Custom Reply View convenience initializer
    convenience init(dataModel: ChatViewModel) {
        self.init(frame: .zero)
        configureReplyViewStatus(with: dataModel)
    }
    
    // MARK: - XIB Setup
    private func commonInit() {
        Bundle.main.loadNibNamed("ReplyStatusView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.collectionView.register(UINib(nibName: "CollectionSmallFileCell", bundle: nil), forCellWithReuseIdentifier: "CollectionSmallFileCell")
    }
    
    func configureReplyStatus(with data: RepliedToMessageViewModel) {
        if data.arrImages.isEmpty {
            collectionView.isHidden = true
        } else {
            collectionView.isHidden = false
            arrImages = data.arrImages
        }
        lblStatus.text = data.title
        viewStatus.backgroundColor = data.colorValue
    }
    
    func configureReplyViewStatus(with data: ChatViewModel) {
        if data.arrImages.isEmpty {
            collectionView.isHidden = true
        } else {
            collectionView.isHidden = false
            arrImages = data.arrImages
        }
        lblStatus.text = data.title
        viewStatus.backgroundColor = data.colorValue
    }
    
}

// MARK: - Collection View Delegate methods
extension ReplyStatusView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrImages.count > 2 ? 2 : arrImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionSmallFileCell", for: indexPath) as! CollectionFileCell
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
            Global.generateThumbnailOnBkgThread(from: url) { thumbnail in
                if let thumbnail = thumbnail {
                    cell.imgItem.image = thumbnail
                } else {
                    cell.imgItem.image = img
                }
                cell.playIcon.isHidden = false
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
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //code
    }
}

// MARK: - Collection View DelegateFlowLayout Methods
extension ReplyStatusView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 62.0, height: 50.0)
    }
}
