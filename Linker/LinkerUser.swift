//
//  User.swift
//  Linker
//
//  Created by Bassyouni on 7/31/17.
//  Copyright © 2017 Bassyouni. All rights reserved.
//

import Foundation

class LinkerUser
{
    var id: String!
    var fullName: String!
    var imageUrl :String?
    var isOnline: Bool!
    
    init(id: String , fullName: String , imageUrl: String? ) {
        self.id = id
        self.fullName = fullName
        
        if imageUrl != nil
        {
            self.imageUrl = imageUrl!
        }
    }
    
    init(id: String , fullName: String , imageUrl: String? ,isOnline: Bool) {
        self.id = id
        self.fullName = fullName
        self.isOnline = isOnline
        
        if imageUrl != nil
        {
            self.imageUrl = imageUrl!
        }
    }
    
    init() {}
    
    public func makeDict() -> Dictionary<String ,String>
    {
        var dict = Dictionary<String,String>()
        
        dict["id"] = self.id
        dict["fullName"] = self.fullName
        dict["imageUrl"] = self.imageUrl
        return dict
    }
    
    
    
    
    
}
