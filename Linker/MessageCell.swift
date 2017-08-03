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

    
    @IBOutlet weak var leftSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var message: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        messageBgColor.layer.cornerRadius = 15.0
        messageBgColor.layer.borderWidth = 2.0
//        message.sizeToFit()
//        message.layoutIfNeeded()
//       self.messageBgColor.sizeToFit()
//        
    }
    
    func configureCell(message: Message)
    {
        self.message.text = message.message
        self.message.sizeToFit()
        self.messageBgColor.sizeToFit()
        
        if message.userId == currentUser.id
        {
            messageBgColor.backgroundColor = UIColor.green
            self.message.textAlignment = .left
            rightSpaceConstraint.constant = 100
            messageBgColor.layoutIfNeeded()
            
        }
        else
        {
            messageBgColor.backgroundColor = UIColor.blue
            self.message.textAlignment = .left
            leftSpaceConstraint.constant = 100
            messageBgColor.layoutIfNeeded()
        }
    }

}
