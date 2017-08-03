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
    
    var ref: DatabaseReference!
    var currentUserChats = [Chat]()
    var hud : MBProgressHUD!

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        self.showLoading()
        self.grabDataFromFireBase()
    }
    
    //MARK: - progress hud
    func showLoading()
    {
        //        self.view.alpha = 0.5
        //    self.view.backgroundColor = UIColor.blackColor()
        self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = MBProgressHUDModeIndeterminate
    }
    
    func hideLoading()
    {
        //        self.view.alpha = 1.0
        self.hud.hide(true)
    }
    
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
                    
                    let chat = Chat(firstUser: firstUser, secondUser: secondUser, messagesArrayDict: (value["messages"] as? [String: [String:String] ] )!, chatId: key)
                    
                    self.currentUserChats.append(chat)
                }
                
            }
        }
        self.tableView.reloadData()
            self.hideLoading()
    })

    }



    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return currentUserChats.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityCell", for: indexPath) as? ActivityCell
        {
            // Configure the cell...
            
            cell.configureCell(chat: currentUserChats[indexPath.row])
            return cell
        }
        else
        {
            return UITableViewCell()
        }

    }
    
   override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier:"ChatVC", sender: currentUserChats[indexPath.row] )
        
    }
 
    
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ChatVC
        {
            destination.isNewChat = false
            if let chat = sender as? Chat
            {
                destination.chat = chat
            }
                
        }
    }
    

}
