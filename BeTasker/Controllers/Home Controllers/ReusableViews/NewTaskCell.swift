//
//  NewTaskCell.swift
//  BeTasker
//
//  Created by kishlay kishore on 25/05/25.
//

import UIKit
import SDWebImage

class NewTaskCell: UITableViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var viewStatusOuter: UIView!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblChatCount: UILabel!
    @IBOutlet weak var imgTask2: UIImageView!
    @IBOutlet weak var imgTask1: UIImageView!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lblTask: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var vwBottomline: UIView!
    @IBOutlet weak var viewNotifyRedDot: UIView!
    @IBOutlet weak var viewMessageCount: UIView!
    @IBOutlet weak var imgChatIcon: UIImageView!
    @IBOutlet weak var userView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        DispatchQueue.main.async {
            self.viewMessageCount.layer.cornerRadius = self.viewMessageCount.frame.height / 2
            self.viewStatusOuter.layer.cornerRadius = self.viewStatusOuter.frame.height / 2
            self.backView.setShadowWithColor(color: .black, opacity: 0.1, offset: CGSize(width: 0.0, height: 3.0), radius: 3, viewCornerRadius: 13.33)
            self.userView.roundCorners([.bottomLeft, .bottomRight], radius: 13.33)
        }
    }
    
    func setupTableData(data: TasksViewModel, messageData: TaskMessageData?) {
        lblStatus.text = data.taskStatus?.title.uppercased()
        lblTask.text = data.title
        lblDescription.text = data.description
        lblDate.text = data.dateCreatedFormatted.dateString
        lblUserName.text = data.taskCreator?.fullName
        if data.taskStatus?.id == 3 || data.taskStatus?.id == 10 {
            lblStatus.textColor = #colorLiteral(red: 0.9568627451, green: 0.2980392157, blue: 0.2980392157, alpha: 1)
            viewStatusOuter.backgroundColor = #colorLiteral(red: 1, green: 0.8784313725, blue: 0.8784313725, alpha: 1)
            lblTask.textColor = .white
            lblDescription.textColor = #colorLiteral(red: 1, green: 0.9999999404, blue: 1, alpha: 0.57)
            lblUserName.textColor = #colorLiteral(red: 1, green: 0.9999999404, blue: 1, alpha: 0.88)
            lblDate.textColor = #colorLiteral(red: 1, green: 0.9999999404, blue: 1, alpha: 0.52)
            backView.backgroundColor = #colorLiteral(red: 0.8666666667, green: 0.2705882353, blue: 0.2352941176, alpha: 1)
            userView.backgroundColor = #colorLiteral(red: 0.5176470588, green: 0, blue: 0, alpha: 0.49)
            viewNotifyRedDot.backgroundColor = .white
            viewMessageCount.backgroundColor = .clear
            lblChatCount.textColor = .white
            imgChatIcon.tintColor = .white
            vwBottomline.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.18)
        } else {
            lblStatus.textColor = data.taskStatus?.colorValue
            viewStatusOuter.backgroundColor = data.taskStatus?.colorValue.withAlphaComponent(0.1)
            lblTask.textColor = .color2D2D2DF8F8F8
            lblDescription.textColor = .color00000057
            lblUserName.textColor = .color00000057
            lblDate.textColor = .color00000036
            backView.backgroundColor = .colorFFFFFF000000
            userView.backgroundColor = UIColor(named: "ColorF9F9F9-2D2D2D")
            viewNotifyRedDot.backgroundColor = #colorLiteral(red: 0.9529411765, green: 0.1137254902, blue: 0.1137254902, alpha: 1)
            viewMessageCount.backgroundColor = .clear
            lblChatCount.textColor = .color00000057
            imgChatIcon.tintColor = .color00000057
            vwBottomline.backgroundColor = .colorE8E8E8
        }
        let img = #imageLiteral(resourceName: "no-user")
        imgUser.sd_imageIndicator = SDWebImageActivityIndicator.gray
        imgUser.sd_imageTransition = SDWebImageTransition.fade
        imgUser.sd_setImage(with: data.taskCreator?.profilePicURL, placeholderImage: img)
        if let messageChatData = messageData {
            configureMessageCount(task: messageChatData, taskStatusId: data.taskStatus?.id ?? 1)
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
    
    func configureMessageCount(task: TaskMessageData, taskStatusId: Int) {
        if !task.isRead {
            lblChatCount.text = task.unreadMessageCount == 0 ? "1" :  "\(task.unreadMessageCount)"
            if taskStatusId == 3 || taskStatusId == 10 {
                viewMessageCount.backgroundColor = .white
                lblChatCount.textColor = #colorLiteral(red: 0.7294117647, green: 0, blue: 0, alpha: 1)
                imgChatIcon.tintColor = #colorLiteral(red: 0.6901960784, green: 0.137254902, blue: 0.1176470588, alpha: 1)
                viewNotifyRedDot.backgroundColor = .white
            } else {
                viewMessageCount.backgroundColor = .colorFF1E1E
                imgChatIcon.tintColor = .white
                lblChatCount.textColor = .white
                viewNotifyRedDot.backgroundColor = #colorLiteral(red: 0.9529411765, green: 0.1137254902, blue: 0.1137254902, alpha: 1)
            }
            viewNotifyRedDot.isHidden = false
            lblChatCount.font = UIFont(name: Constants.KGraphikMedium, size: 13) ?? UIFont.systemFont(ofSize: 13, weight: .medium)
            lblTask.font = UIFont(name: Constants.KGraphikSemibold, size: 17) ?? UIFont.systemFont(ofSize: 17, weight: .semibold)
        } else {
            lblChatCount.text = task.messageCount == 0 ? "1" : "\(task.messageCount)"
            if taskStatusId == 3 || taskStatusId == 10 {
                viewMessageCount.backgroundColor = .clear
                lblChatCount.textColor = .white
                imgChatIcon.tintColor = .white
                viewNotifyRedDot.backgroundColor = .white
            } else {
                viewMessageCount.backgroundColor = .clear
                imgChatIcon.tintColor = .color00000057
                lblChatCount.textColor = .color00000057
                viewNotifyRedDot.backgroundColor = #colorLiteral(red: 0.9529411765, green: 0.1137254902, blue: 0.1137254902, alpha: 1)
            }
            viewNotifyRedDot.isHidden = true
            lblChatCount.font = UIFont(name: Constants.KGraphikRegular, size: 13) ?? UIFont.systemFont(ofSize: 13, weight: .regular)
            lblTask.font = UIFont(name: Constants.KGraphikMedium, size: 17) ?? UIFont.systemFont(ofSize: 17, weight: .medium)
        }
    }
}
