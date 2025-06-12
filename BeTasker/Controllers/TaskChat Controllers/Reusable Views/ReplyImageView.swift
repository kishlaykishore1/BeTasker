//
//  ReplyImageView.swift
//  BeTasker
//
//  Created by kishlay kishore on 06/06/25.
//

import UIKit
import SDWebImage

class ReplyImageView: UIView {

   // MARK: - Outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var imgImage: UIImageView!
    
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
        configureReplyImage(with: dataModel)
    }
    
    /// Custom convenience initializer
    convenience init(dataModel: ChatViewModel) {
        self.init(frame: .zero)
        configureReplyViewImage(with: dataModel)
    }
    
    // MARK: - XIB Setup
    private func commonInit() {
        Bundle.main.loadNibNamed("ReplyImageView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    func configureReplyImage(with data: RepliedToMessageViewModel) {
        imgImage.contentMode = .center
        let img = UIImage(named: "img_PlaceHolder")
        imgImage.sd_imageIndicator = SDWebImageActivityIndicator.gray
        imgImage.sd_imageTransition = SDWebImageTransition.fade
        imgImage.sd_setImage(with: data.imageURL, placeholderImage: img) { [weak imgFile = imgImage] image, error,_,_ in
            if let _ = error {
                imgFile?.contentMode = .center
                imgFile?.image = img
            } else {
                imgFile?.contentMode = .scaleAspectFill
            }
        }
    }
    
    func configureReplyViewImage(with data: ChatViewModel) {
        imgImage.contentMode = .center
        let img = UIImage(named: "img_PlaceHolder")
        imgImage.sd_imageIndicator = SDWebImageActivityIndicator.gray
        imgImage.sd_imageTransition = SDWebImageTransition.fade
        imgImage.sd_setImage(with: data.imageURL, placeholderImage: img) { [weak imgFile = imgImage] image, error,_,_ in
            if let _ = error {
                imgFile?.contentMode = .center
                imgFile?.image = img
            } else {
                imgFile?.contentMode = .scaleAspectFill
            }
        }
    }
}
