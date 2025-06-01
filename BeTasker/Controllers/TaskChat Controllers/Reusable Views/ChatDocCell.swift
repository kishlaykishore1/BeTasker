//
//  ChatDocCell.swift
//  BeTasker
//
//  Created by kishlay kishore on 30/04/25.
//

import UIKit
import SDWebImage

class ChatDocCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var viewPdfContent: UIView!
    @IBOutlet weak var viewOuter: UIView!
    @IBOutlet weak var lblFileName: UILabel!
    @IBOutlet weak var lblFileSize: UILabel!
    @IBOutlet weak var btnDownload: UIButton!  
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
    var downloadPDFClosure: (()->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        DispatchQueue.main.async {[weak self] in
            self?.viewOuter.applyShadow(radius: 4, opacity: 0.1, offset: .zero)
        }
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
    
    // MARK: - Button Action Methods
    @IBAction func btnDownload_Action(_ sender: UIButton) {
        Global.setVibration()
        downloadPDFClosure?()
    }

}

// MARK: - Collection View Delegate methods
extension ChatDocCell: UICollectionViewDataSource, UICollectionViewDelegate {
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
extension ChatDocCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 16, height: 16)
    }
}
