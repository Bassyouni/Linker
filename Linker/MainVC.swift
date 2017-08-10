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
import CoreLocation
import GoogleMobileAds

class MainVC: ParentViewController , CLLocationManagerDelegate , UITableViewDelegate , UITableViewDataSource , GADBannerViewDelegate{
    
    //MARK: - variables
    var ref: DatabaseReference!
    var geoFire : GeoFire!
    var chatSections = ["Group" , "Individual"]
    var currentUserChats = [Chat]()
    var groupChat :Chat!
    let locationManger = CLLocationManager()

    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        ref = Database.database().reference()
        let locationRef = ref.child("location")
        geoFire = GeoFire(firebaseRef: locationRef)
        self.showLoading()
        self.firebaseOnlineOfflineCap()
        self.grabDataFromFireBase()
        self.grabGroupChatMessages()
        
        locationManger.delegate = self
        locationManger.desiredAccuracy = kCLLocationAccuracyBest
        locationManger.requestWhenInUseAuthorization()
        locationManger.startMonitoringSignificantLocationChanges()

        bannerView.adUnitID = "ca-app-pub-8680279546150258/7580191259"
        bannerView.rootViewController = self
        let request: GADRequest = GADRequest()
        request.testDevices = [ kGADSimulatorID ]
        bannerView.load(request)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.locationAuthStatus()
    }
    
    func locationAuthStatus()
    {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse
        {
            geoFire.setLocation(locationManger.location, forKey: currentUser.id)
        }
        else
        {
            locationManger.requestWhenInUseAuthorization()
            locationAuthStatus()
        }
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

     func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return chatSections.count
    }
    
     func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return chatSections[section]
    }

      func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0
        {
            return 1
        }
        return currentUserChats.count
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
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
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 1
        {
            return true
        }
        return false
    }
    
        func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete
            {
                let chatRef = ref.child("chats").child(currentUserChats[indexPath.row].chatId)
                chatRef.removeValue()
                currentUserChats.remove(at: indexPath.row)
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
    
    
    //MARK: - online offline capabilities
    func firebaseOnlineOfflineCap()
    {
        // since I can connect from multiple devices, we store each connection instance separately
        // any time that connectionsRef's value is null (i.e. has no children) I am offline
        let myConnectionsRef = Database.database().reference(withPath: "users/\(currentUser.id!)/connections")
        
        // stores the timestamp of my last disconnect (the last time I was seen online)
        let lastOnlineRef = Database.database().reference(withPath: "users/\(currentUser.id!)/lastOnline")
        
        let connectedRef = Database.database().reference(withPath: ".info/connected")
        
        connectedRef.observe(.value, with: { snapshot in
            // only handle connection established (or I've reconnected after a loss of connection)
            guard let connected = snapshot.value as? Bool, connected else { return }
            
            // add this device to my connections list
            let con = myConnectionsRef.childByAutoId()
            
            // when this device disconnects, remove it.
            con.onDisconnectRemoveValue()
            
            // The onDisconnect() call is before the call to set() itself. This is to avoid a race condition
            // where you set the user's presence to true and the client disconnects before the
            // onDisconnect() operation takes effect, leaving a ghost user.
            
            // this value could contain info about the device or a timestamp instead of just true
            con.setValue(true)
            
            // when I disconnect, update the last time I was seen online
            lastOnlineRef.onDisconnectSetValue(ServerValue.timestamp())
        })
    }
    
    //MARK: - add Location to firebase and init location
    
    
    
    
    
    
    
    
    
}
