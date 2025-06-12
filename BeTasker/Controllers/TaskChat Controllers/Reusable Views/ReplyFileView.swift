//
//  ReplyFileView.swift
//  BeTasker
//
//  Created by kishlay kishore on 06/06/25.
//

import UIKit

class ReplyFileView: UIView {

    // MARK: - Outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var lblFileName: UILabel!
    @IBOutlet weak var lblFileSize: UILabel!
    
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
        let corners: UIRectCorner = dataModel.isMine ? [.topLeft, .topRight, .bottomLeft] : [.topLeft, .topRight, .bottomRight]
        configureReplyDoc(with: dataModel, corners: corners)
    }
    
    /// Custom Reply View convenience initializer
    convenience init(dataModel: ChatViewModel) {
        self.init(frame: .zero)
        let corners: UIRectCorner = dataModel.isMine ? [.topLeft, .topRight, .bottomLeft] : [.topLeft, .topRight, .bottomRight]
        configureReplyViewDoc(with: dataModel, corners: corners)
    }
    
    // MARK: - XIB Setup
    private func commonInit() {
        Bundle.main.loadNibNamed("ReplyFileView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    func configureReplyDoc(with data: RepliedToMessageViewModel, corners: UIRectCorner = []) {
        DispatchQueue.main.async {
            self.outerView.roundCorners(corners, radius: 13.3)
        }
        lblFileName.text = data.pdfName
        lblFileSize.text = data.pdfSize
    }
    
    func configureReplyViewDoc(with data: ChatViewModel, corners: UIRectCorner = []) {
        DispatchQueue.main.async {
            self.outerView.roundCorners(corners, radius: 13.3)
        }
        lblFileName.text = data.pdfName
        lblFileSize.text = data.pdfSize
    }
}
