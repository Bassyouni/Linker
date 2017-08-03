//
//  AllUsersVC.swift
//  Linker
//
//  Created by Bassyouni on 8/2/17.
//  Copyright © 2017 Bassyouni. All rights reserved.
//

import UIKit
import Firebase

class AllUsersVC: UITableViewController {
    
    var allUsers = [LinkerUser]()
    var ref: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        self.grabDataFromFireBase()
        
    }
    
    func grabDataFromFireBase()
    {
                ref.observe(DataEventType.value, with: { (snapshot) in
                let postDict = snapshot.value as? [String : AnyObject] ?? [:]
                // ...
        
                print(postDict)
        
                if let dic = postDict["users"] as?  Dictionary<String,Dictionary<String,AnyObject>>
                {
                    self.allUsers.removeAll()
                    var fullName: String!
                    var id : String!
                    var imageUrl: String!
                    for (_,value) in dic
                    {
                        fullName = value["fullName"] as! String
                        imageUrl = value["imageUrl"] as! String
                        id = value["id"] as! String
                        
                        if id == currentUser.id
                        {
                            continue
                        }
                        
                        let linkerUser = LinkerUser(id: id, fullName: fullName, imageUrl: imageUrl)
                        self.allUsers.append(linkerUser)
                    }
        
                }
                                
                self.tableView.reloadData()
                })
    }



    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allUsers.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "AllUsersCell", for: indexPath) as? AllUsersCell
        {
            // Configure the cell...
            cell.configureCell(linkerUser: allUsers[indexPath.row] )
            return cell
        }
        else
        {
            return UITableViewCell()
        }

    }
    

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ChatVC2", sender: allUsers[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ChatVC
        {
            if let user = sender as? LinkerUser
            {
                destination.otherSideUser = user
            }
        
        }
    }

}
