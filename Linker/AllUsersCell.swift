//
//  AllUsersCell.swift
//  Linker
//
//  Created by Bassyouni on 8/2/17.
//  Copyright © 2017 Bassyouni. All rights reserved.
//

import UIKit
import SDWebImage

class AllUsersCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userImage.layer.borderWidth = 1.0
        userImage.layer.masksToBounds = false
        userImage.layer.borderColor = UIColor.white.cgColor
        userImage.layer.cornerRadius = userImage.frame.size.height/2
        userImage.clipsToBounds = true
    }

    func configureCell(linkerUser: LinkerUser)
    {
        self.userName.text = linkerUser.fullName
        self.userImage.sd_setImage(with: URL(string: linkerUser.imageUrl!))
    }



}
