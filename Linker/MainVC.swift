//
//  MainVC.swift
//  Linker
//
//  Created by Bassyouni on 8/1/17.
//  Copyright © 2017 Bassyouni. All rights reserved.
//

import UIKit
import FacebookCore
import Firebase

class MainVC: UITableViewController {
    
    //MARK: - variables
    var ref: DatabaseReference!
    var chatSections = ["Group" , "Individual"]
    var currentUserChats = [Chat]()
    var groupChat :Chat!
    var hud : MBProgressHUD!

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        self.showLoading()
        self.grabDataFromFireBase()
        self.grabGroupChatMessages()

    
    }
    
    //MARK: - progress hud
    func showLoading()
    {
        //self.view.alpha = 0.5
        //self.view.backgroundColor = UIColor.blackColor()
        self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = MBProgressHUDModeIndeterminate
    }
    
    func hideLoading()
    {
        //self.view.alpha = 1.0
        self.hud.hide(true)
    }
    
    
    //MARK: - Firebase grabbing data
    /// grabing all chats this user is having
    func grabDataFromFireBase()
    {
        ref.observe(DataEventType.value, with: { (snapshot) in
        let postDict = snapshot.value as? [String : AnyObject] ?? [:]
        // ...
    
        if let dic = postDict["chats"] as?  Dictionary<String,Dictionary<String,AnyObject>>
        {
            self.currentUserChats.removeAll()
            for (key,value) in dic
            {
                if value["firstUser"]?["id"] as? String == currentUser.id
                {
                    let firstUser = LinkerUser(id:value["firstUser"]?["id"] as! String , fullName: value["firstUser"]?["fullName"] as! String, imageUrl: value["firstUser"]?["imageUrl"] as? String)
                    let secondUser = LinkerUser(id: value["secondUser"]?["id"] as! String, fullName: value["secondUser"]?["fullName"] as! String, imageUrl: value["secondUser"]?["imageUrl"] as? String)
                    
                    let chat: Chat!
                    if (value["messages"] as? [String: [String:String] ]) != nil
                    {
                         chat = Chat(firstUser: firstUser, secondUser: secondUser, messagesArrayDict: (value["messages"] as? [String: [String:String] ] )!, chatId: key)
                    }
                    else
                    {
                         chat = Chat(firstUser: firstUser, secondUser: secondUser, messagesArrayDict: nil, chatId: key)
                    }
                    
                    
                    self.currentUserChats.append(chat)
                }
                else if value["secondUser"]?["id"] as? String == currentUser.id
                {
                    let firstUser = LinkerUser(id:value["firstUser"]?["id"] as! String , fullName: value["firstUser"]?["fullName"] as! String, imageUrl: value["firstUser"]?["imageUrl"] as? String)
                    let secondUser = LinkerUser(id: value["secondUser"]?["id"] as! String, fullName: value["secondUser"]?["fullName"] as! String, imageUrl: value["secondUser"]?["imageUrl"] as? String)
                    
                    let chat: Chat!
                    if (value["messages"] as? [String: [String:String] ]) != nil
                    {
                        chat = Chat(firstUser: secondUser, secondUser: firstUser, messagesArrayDict: (value["messages"] as? [String: [String:String] ] )!, chatId: key)
                    }
                    else
                    {
                        chat = Chat(firstUser: secondUser, secondUser: firstUser, messagesArrayDict: nil, chatId: key)
                    }
                    
                    
                    self.currentUserChats.append(chat)
                }
                
            }
        }
            self.tableView.reloadData()
            self.hideLoading()
    })

    }
    
    /// grabing group chat messages
    func grabGroupChatMessages()
    {
        let groupChatRef = ref.child("groupChat")
        groupChatRef.observe(DataEventType.value, with: { (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]

            
                 self.groupChat = Chat(messagesArrayDict: postDict as? [String : [String : String]], chatId: "LinkerChat1")
               self.tableView.reloadData()
            
        })
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return chatSections.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return chatSections[section]
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0
        {
            return 1
        }
        return currentUserChats.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0
        {

            if let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityCell", for: indexPath) as? ActivityCell
            {
                // Configure the cell...
                if groupChat != nil
                {
                    cell.configureGroupChatCell(groupChat: self.groupChat, name: "Linkers Chat")
                    return cell
                }
                else
                {
                    cell.userImage.image = UIImage(named: "backBG")
                    cell.userName.text = "Bassio"
                    cell.lastSentMessage.text = "nope!"
                    return cell
                }
                
            }
        }
        
        if indexPath.section == 1
        {

            if let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityCell", for: indexPath) as? ActivityCell
            {
                // Configure the cell...
                cell.configureCell(chat: currentUserChats[indexPath.row])
                return cell
            }

        }
        
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if indexPath.section == 0
        {
            performSegue(withIdentifier:"ChatVC", sender: nil )
        }
        else
        {
            performSegue(withIdentifier:"ChatVC", sender: currentUserChats[indexPath.row] )
        }
        
    
        
    
        
   }
 
    //MARK: - ibactions

    @IBAction func signOutBtnPressed(_ sender: Any) {
        AccessToken.current = nil
        
        let delegate = UIApplication.shared.delegate as? AppDelegate
        let loginPage = self.storyboard?.instantiateViewController(withIdentifier: "LandingVC")
        
        delegate?.window?.rootViewController = loginPage
        
    }
    
    @IBAction func composeBtnPressed(_ sender: Any) {
       performSegue(withIdentifier: "AllUsersVC", sender: nil)
    }
    
    @IBAction func unwindToVC1(segue:UIStoryboardSegue) { }

    
    //MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ChatVC
        {
            destination.isNewChat = false
            if let chat = sender as? Chat
            {
                destination.chat = chat
            }
            else if sender == nil
            {
                destination.chat = groupChat
                destination.isGroupChat = true
            }
                
        }
    }
    

}
