//
//  ArchiveTaskTblCell.swift
//  BeTasker
//
//  Created by kishlay kishore on 25/05/25.
//

import UIKit
import SDWebImage

class ArchiveTaskTblCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblChatCount: UILabel!
    @IBOutlet weak var imgTask2: UIImageView!
    @IBOutlet weak var imgTask1: UIImageView!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var imgTaskIndicator: UIImageView!
    @IBOutlet weak var lblTask: UILabel!
    @IBOutlet weak var vwTopline: UIView!
    @IBOutlet weak var vwBottomline: UIView!
    @IBOutlet weak var viewNotifyRedDot: UIView!
    @IBOutlet weak var viewMessageCount: UIView!
    @IBOutlet weak var imgChatIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        DispatchQueue.main.async {
            self.viewMessageCount.layer.cornerRadius = self.viewMessageCount.frame.height / 2
        }
    }
    
    func setupTableData(data: TasksViewModel, messageData: TaskMessageData?) {
        lblStatus.text = data.taskStatus?.title
        lblStatus.textColor = data.taskStatus?.colorValue
        imgTaskIndicator.tintColor = data.taskStatus?.colorValue
        lblTask.text = data.title
        lblDate.text = data.dateCreatedFormatted.dateString
        lblUserName.text = data.taskCreator?.fullName
        let img = #imageLiteral(resourceName: "no-user")
        imgUser.sd_imageIndicator = SDWebImageActivityIndicator.gray
        imgUser.sd_imageTransition = SDWebImageTransition.fade
        imgUser.sd_setImage(with: data.taskCreator?.profilePicURL, placeholderImage: img)
        if let messageChatData = messageData {
            configureMessageCount(task: messageChatData)
        } else {
            lblChatCount.text = "1"
            viewNotifyRedDot.isHidden = true
        }
        
        if data.arrImages.count > 0 {
            imgTask2.sd_imageIndicator = SDWebImageActivityIndicator.gray
            imgTask2.sd_imageTransition = SDWebImageTransition.fade
            imgTask2.sd_setImage(with: data.arrImages[0].fileURL, placeholderImage: img)
            if data.arrImages.count > 1 {
                imgTask1.sd_imageIndicator = SDWebImageActivityIndicator.gray
                imgTask1.sd_imageTransition = SDWebImageTransition.fade
                imgTask1.sd_setImage(with: data.arrImages[1].fileURL, placeholderImage: img)
            } else {
                imgTask1.image = nil
            }
        } else {
            imgTask1.image = nil
            imgTask2.image = nil
        }
    }
    
    func configureMessageCount(task: TaskMessageData) {
        if !task.isRead {
            lblChatCount.text = task.unreadMessageCount == 0 ? "1" :  "\(task.unreadMessageCount)"
            viewMessageCount.backgroundColor = .colorFF1E1E
            imgChatIcon.tintColor = .white
            lblChatCount.textColor = .white
            viewNotifyRedDot.backgroundColor = #colorLiteral(red: 0.9529411765, green: 0.1137254902, blue: 0.1137254902, alpha: 1)
            viewNotifyRedDot.isHidden = false
            lblChatCount.font = UIFont(name: Constants.KGraphikMedium, size: 13) ?? UIFont.systemFont(ofSize: 13, weight: .medium)
            lblTask.font = UIFont(name: Constants.KGraphikSemibold, size: 17) ?? UIFont.systemFont(ofSize: 17, weight: .semibold)
        } else {
            lblChatCount.text = task.messageCount == 0 ? "1" : "\(task.messageCount)"
            viewMessageCount.backgroundColor = .clear
            imgChatIcon.tintColor = .color00000057
            lblChatCount.textColor = .color00000057
            viewNotifyRedDot.backgroundColor = #colorLiteral(red: 0.9529411765, green: 0.1137254902, blue: 0.1137254902, alpha: 1)
            viewNotifyRedDot.isHidden = true
            lblChatCount.font = UIFont(name: Constants.KGraphikRegular, size: 13) ?? UIFont.systemFont(ofSize: 13, weight: .regular)
            lblTask.font = UIFont(name: Constants.KGraphikMedium, size: 17) ?? UIFont.systemFont(ofSize: 17, weight: .medium)
        }
    }
}
