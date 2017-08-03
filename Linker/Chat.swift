//
//  Chat.swift
//  Linker
//
//  Created by Bassyouni on 8/3/17.
//  Copyright © 2017 Bassyouni. All rights reserved.
//

import Foundation

class Chat
{
    private var _firstUser: LinkerUser!
    private var _secondUser: LinkerUser!
    private var _chatId: String!
    
    var messages: [Message]!
    
    init(firstUser: LinkerUser , secondUser: LinkerUser ,messagesArrayDict:[String: [String:String] ] , chatId: String) {
        self._firstUser = firstUser
        self._secondUser = secondUser
        self._chatId = chatId
        messages = [Message]()

        //_ = messagesArrayDict.keys.Array.sorted{$0<$1}
        let sortedMessagesArrayDict = messagesArrayDict.keys.sorted(by: {$0<$1})
        for key in sortedMessagesArrayDict
        {
            let tempMessage = Message()
            
            tempMessage.message = (messagesArrayDict[key]?["message"]!)!
            tempMessage.userId = (messagesArrayDict[key]?["userId"]!)!
            messages.append(tempMessage)
        }
    }
    
    init(firstUser: LinkerUser , secondUser: LinkerUser ,messagesArray: [Message] , chatId: String) {
        self._firstUser = firstUser
        self._secondUser = secondUser
        self._chatId = chatId
        messages = [Message]()
        
        self.messages = messagesArray
    }
    
    var firstUser: LinkerUser
    {
        set{_firstUser = newValue }
        get{return _firstUser }
    }
    
    var secondUser: LinkerUser
    {
        set{_secondUser = newValue }
        get{return _secondUser }
    }
    
    var chatId: String
    {
        set{_chatId = newValue }
        get{return _chatId }
    }
    
    
}
