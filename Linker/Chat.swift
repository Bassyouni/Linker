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
    
    init(firstUser: LinkerUser , secondUser: LinkerUser ,messagesArrayDict:[String: [String:String] ]?, chatId: String) {
        self._firstUser = firstUser
        self._secondUser = secondUser
        self._chatId = chatId
        messages = [Message]()

        if messagesArrayDict != nil
        {
            let sortedMessagesArrayDict = messagesArrayDict?.keys.sorted(by: {$0<$1})
            for key in sortedMessagesArrayDict!
            {
                let tempMessage = Message()
                
                tempMessage.message = (messagesArrayDict?[key]?["message"]!)!
                tempMessage.userId = (messagesArrayDict?[key]?["userId"]!)!
                
                if messagesArrayDict?[key]?["imageUrl"] != nil
                {
                    tempMessage.imageUrl = (messagesArrayDict?[key]?["imageUrl"]!)!
                }
                messages.append(tempMessage)
            }
        }
        else
        {
            messages = [Message]()
        }
        
    }
    
    init(firstUser: LinkerUser , secondUser: LinkerUser ,messagesArray: [Message] , chatId: String) {
        self._firstUser = firstUser
        self._secondUser = secondUser
        self._chatId = chatId
        messages = [Message]()
        
        self.messages = messagesArray
    }
    
    /// init for Group Chats
    ///
    /// - Parameters:
    ///   - messagesArrayDict: json coming from firebase
    ///   - chatId: dummy variable
    init(messagesArrayDict:[String: [String:String] ]?, chatId: String)
    {
        self._chatId = chatId
        messages = [Message]()
        
        if messagesArrayDict != nil
        {
            let sortedMessagesArrayDict = messagesArrayDict?.keys.sorted(by: {$0<$1})
            for key in sortedMessagesArrayDict!
            {
                let tempMessage = Message()
                
                tempMessage.message = (messagesArrayDict?[key]?["message"]!)!
                tempMessage.userName = (messagesArrayDict?[key]?["fullName"]!)!
                
                if messagesArrayDict?[key]?["imageUrl"] != nil
                {
                    tempMessage.imageUrl = (messagesArrayDict?[key]?["imageUrl"]!)!
                }
                messages.append(tempMessage)
            }
        }
        else
        {
            messages = [Message]()
        }
    }
    
    init(){}
    
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
