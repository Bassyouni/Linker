//
//  MessageCell.swift
//  Linker
//
//  Created by Bassyouni on 8/2/17.
//  Copyright © 2017 Bassyouni. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {

    @IBOutlet weak var messageBgColor: UIView!
    @IBOutlet weak var messageImage: UIImageView!
    @IBOutlet weak var message: UILabel!

    @IBOutlet weak var leftSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightSpaceConstraint: NSLayoutConstraint!

    @IBOutlet var imageToBackGroundBottomConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        messageBgColor.layer.cornerRadius = 15.0
        messageBgColor.layer.borderWidth = 1.0

    }
    
    func configureCell(message: Message)
    {

        if message.message == "" && message.imageUrl != nil
        {
            imageToBackGroundBottomConstraint.isActive = true
            messageImage.sd_setImage(with:  URL(string: message.imageUrl!) )
            messageImage.isHidden = false
            self.message.isHidden = true
            
        }
        else
        {
            imageToBackGroundBottomConstraint.isActive = false
            self.message.isHidden = false
            messageImage.isHidden = true
            self.message.text = message.message
            self.message.sizeToFit()
            self.messageBgColor.sizeToFit()
        }
        
        let constraintConstant = self.contentView.frame.width -  (self.message.font.sizeOfString(string: message.message, constrainedToWidth: 200).width + 60)
        
        
        if message.userId == currentUser.id
        {
            messageBgColor.backgroundColor = UIColor(red: 109.0/255, green: 228.0/255, blue: 75.0/255, alpha: 1)
            self.message.textColor = UIColor.black
            self.message.textAlignment = .center
            
            if constraintConstant < 100 || !messageImage.isHidden
            {
                leftSpaceConstraint.constant = 100
            }
            else
            {
                leftSpaceConstraint.constant = constraintConstant
            }
            
            rightSpaceConstraint.constant = 10
            
        }
        else
        {
            messageBgColor.backgroundColor = UIColor(red: 57, green: 133, blue: 255)
            self.message.textColor = UIColor.white
            self.message.textAlignment = .center
            
            if constraintConstant < 100 && !messageImage.isHidden
            {
                rightSpaceConstraint.constant = 100
            }
            else
            {
                rightSpaceConstraint.constant = constraintConstant
            }
            
            leftSpaceConstraint.constant = 10
        }
    }

}
