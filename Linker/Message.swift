//
//  Message.swift
//  Linker
//
//  Created by Bassyouni on 8/2/17.
//  Copyright © 2017 Bassyouni. All rights reserved.
//

import Foundation

class Message
{
    private var _message:String!
    private var _userId:String!
    private var _image: UIImage?
    private var _imageUrl: String!
    private var _userName: String!
    private var _messageKey: String!
    
    init(){}
    
    init(userName: String , message :String , imageUrl: String? , messageKey: String) {
        
        self._userName = userName
        self._message = message
        self._messageKey = messageKey
        
        if imageUrl != nil
        {
            self._imageUrl = imageUrl
        }
        
        self._userId = nil
        self._image = nil
    }
    
    var messageKey: String
    {
        set { _messageKey = newValue }
        get { return _messageKey }
    }
    
    var userName: String
    {
        set {_userName = newValue}
        get {return _userName}
    }
    
    var imageUrl: String?
    {
        set { _imageUrl = newValue }
        get {return _imageUrl}
    }
    
    var image: UIImage
    {
        set { _image = newValue }
        get { return _image! }
    }
    
    var message: String {
        set{_message = newValue}
        get{return _message}
    }
    
    var userId: String {
        set{_userId = newValue}
        get{return _userId}
    }

    
    func toDictonary() -> Dictionary<String, String>
    {
        var tempDict = Dictionary<String , String>()
        tempDict["message"] = self._message
        tempDict["userId"] = self._userId
        if imageUrl != nil
        {
            tempDict["imageUrl"] = self.imageUrl!
        }
        return tempDict
        
    }
    
    func toGroupChatDict() -> Dictionary<String , String>
    {
        var tempDict = Dictionary<String , String>()
        tempDict["message"] = self._message
        tempDict["fullName"] = self._userName
        if imageUrl != nil
        {
            tempDict["imageUrl"] = self.imageUrl!
        }
        return tempDict
    }
    
}
