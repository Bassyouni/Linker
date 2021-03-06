//
//  Constants.swift
//  Linker
//
//  Created by Bassyouni on 8/1/17.
//  Copyright © 2017 Bassyouni. All rights reserved.
//

import Foundation


var currentUser = LinkerUser()


// colors
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}

extension UIFont {
    func sizeOfString (string: String, constrainedToWidth width: Double) -> CGSize {
        return NSString(string: string).boundingRect(with: CGSize(width: width, height: Double.greatestFiniteMagnitude),options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                             attributes: [NSFontAttributeName: self],
                                                             context: nil).size
    }
}


let adMobId = "ca-app-pub-8680279546150258~8179134669"
