//
//  ActivityCell.swift
//  Linker
//
//  Created by Bassyouni on 8/2/17.
//  Copyright © 2017 Bassyouni. All rights reserved.
//

import UIKit
import SDWebImage

class ActivityCell: UITableViewCell {
    

    @IBOutlet weak var lastSentMessage: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userImage.layer.borderWidth = 1.0
        userImage.layer.masksToBounds = false
        userImage.layer.borderColor = UIColor.white.cgColor
        userImage.layer.cornerRadius = userImage.frame.size.height/2
        userImage.clipsToBounds = true
    }

    func configureCell(chat: Chat)
    {
        lastSentMessage.text = chat.messages.last?.message
        
        userName.text = chat.secondUser.fullName!
        userImage.sd_setImage(with: URL(string:chat.secondUser.imageUrl! ))
    }
}
