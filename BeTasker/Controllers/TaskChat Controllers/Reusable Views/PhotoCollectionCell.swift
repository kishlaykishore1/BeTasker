//
//  PhotoCollectionCell.swift
//  BeTasker
//
//  Created by kishlay kishore on 19/03/25.
//

import UIKit

class PhotoCollectionCell: UICollectionViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var imgPhoto: UIImageView!
    @IBOutlet weak var imgCamera: UIImageView!
    @IBOutlet weak var vwRemovePhoto: UIView!
    @IBOutlet weak var vwLoader: UIActivityIndicatorView!
    
    var removePhotoClosure: (()->())?
    
    @IBAction func RemovePhoto(_ sender: Any) {
        removePhotoClosure?()
    }
}
