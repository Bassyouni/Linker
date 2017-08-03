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
    
    var message: String {
        set{_message = newValue}
        get{return _message}
    }
    
    var userId: String {
        set{_userId = newValue}
        get{return _userId}
    }
    
    init(){}
    
    func toDictonary() -> Dictionary<String, String>
    {
        var tempDict = Dictionary<String , String>()
        tempDict["message"] = self._message
        tempDict["userId"] = self._userId
        return tempDict
        
    }
}
