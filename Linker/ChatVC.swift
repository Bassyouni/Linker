//
//  ChatVC.swift
//  Linker
//
//  Created by Bassyouni on 8/2/17.
//  Copyright © 2017 Bassyouni. All rights reserved.
//

import UIKit
import SDWebImage
import Firebase
import FirebaseStorage

class ChatVC: ParentViewController , UITableViewDelegate , UITableViewDataSource ,UITextViewDelegate, UIImagePickerControllerDelegate , UINavigationControllerDelegate {
  
    //MARK: - variables
    var messages = [Message]()
    var chat: Chat?
    var otherSideUser: LinkerUser?
    var ref: DatabaseReference!
    var isNewChat: Bool = true
    var isGroupChat: Bool = false
    var imagePicker: UIImagePickerController!


 
    //MARK: - iboutlets
    @IBOutlet weak var keyboardHeightLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageInputTextView: UITextView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageImage: UIImageView!

    
    //MARK: - view DidLoad & deinit
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewConfig()
        
        //tap to hideKeyBoard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ChatVC.hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tapGesture)
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
   
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140
        tableView.backgroundView = UIImageView(image: UIImage(named: "chatBG"))
        
        messageInputTextView.delegate = self
    
        
        ref = Database.database().reference()
        
        // case 1 : it is a new chat
        if isNewChat && otherSideUser != nil
        {
            self.navigationItem.title = otherSideUser?.fullName
            self.showLoading()
            self.checkIfChatIsExisted()
        }
        // case 2 : its and existing chat but not a group chat
        else if !isNewChat && chat != nil && !isGroupChat
        {
            self.navigationItem.title = chat?.secondUser.fullName
            messages = (chat?.messages)!
            messagesFromFireBaseRealTime()
            
        }
        // case 3 : it is a group chat
        else if chat != nil && isGroupChat
        {
            self.navigationItem.title = "Linker Chat"
            self.groupChatMessagesFromFirebase()
        }
        
    }
  
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    //MARK: - Firebase data grabbing
    func checkIfChatIsExisted()
    {
        ref.observe(DataEventType.value, with: { (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            // ...
            
            if let dic = postDict["chats"] as?  Dictionary<String,Dictionary<String,AnyObject>>
            {
                for (key,value) in dic
                {
                    if value["firstUser"]?["id"] as? String == currentUser.id || value["secondUser"]?["id"] as? String == currentUser.id
                    {
                        if value["secondUser"]?["id"] as? String == self.otherSideUser?.id || value["firstUser"]?["id"] as? String == self.otherSideUser?.id
                        {
                            self.chat = Chat()
                            self.chat?.chatId = key
                            self.chat?.firstUser = currentUser
                            self.chat?.secondUser = self.otherSideUser!
                            
                            //to make messages update real time
                            self.messagesFromFireBaseRealTime()
                            
                        }
                    }
                    
                }
            }
            self.tableView.reloadData()
            self.hideLoading()
        })
    }
    
    /// Grabs data for group chat from Firebase realtime
    func groupChatMessagesFromFirebase()
    {
        //this function is real time
        let messagesRef = self.ref.child("groupChat")
        messagesRef.observe(DataEventType.value, with:{(snapshot) in
        
            if let messagesArray = snapshot.value as? [String: [String:String]]
            {
                self.chat = Chat(messagesArrayDict: messagesArray, chatId: "LinkerChat1")
                self.messages = (self.chat?.messages)!
            }
            self.tableView.reloadData()
            self.scrollDownTableView()
        
        
        })
    }
    
    /// Grabs data for one to one chat from Firebase realtime
    func messagesFromFireBaseRealTime()
    {
        // this funtion is real time
        let newRef = self.ref.child("chats").child((chat?.chatId)!).child("messages")
        newRef.queryOrderedByKey().observe(DataEventType.value, with: {(snapshot) in
            
            if let messagesArray = snapshot.value as? [String: [String:String]]
            {
                self.chat = Chat(firstUser: (self.chat?.firstUser)!, secondUser: (self.chat?.secondUser)!, messagesArrayDict: messagesArray, chatId: (self.chat?.chatId)!)
                self.messages = (self.chat?.messages)!
            }
            self.tableView.reloadData()
            self.scrollDownTableView()
        })

    }
    
    
     //MARK: - unwind segue to mainVC
    func backToMainVC(sender: UIBarButtonItem) {
       
        if messages.count != 0 && isNewChat
        {
            performSegue(withIdentifier: "unwindToMainVC", sender: nil)
        }
        else
        {
            _ = self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    
    //MARK: - table
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if !isGroupChat
        {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as? MessageCell
            {
                cell.configureCell(message: messages[indexPath.row])
                return cell
            }
        }
        else
        {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "GroupChatCell", for: indexPath) as? GroupChatCell
            {
                cell.configureCell(message: messages[indexPath.row])
                return cell
            }
        }
        
       return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if messages[indexPath.row].imageUrl != nil
        {
            performSegue(withIdentifier: "FullImageVC", sender:messages[indexPath.row].imageUrl )

        }
    }
    
    //MARK: - ibActions
    @IBAction func sendBtnPressed(_ sender: Any) {
        self.sendMessage()
    }
    
    @IBAction func imageBtnPressed(_ sender: Any){
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    //MARK: - Messages Sending Functions
    func sendMessage()
    {
        if messageInputTextView.text == ""
        {
            return
        }
        let tempMessage = Message()
        tempMessage.message = messageInputTextView.text
        messageInputTextView.text = ""
        tempMessage.userId = currentUser.id
        messages.append(tempMessage)
        tableView.reloadData()
        
        if isGroupChat {
            tempMessage.userName = currentUser.fullName
            let refToMessages = self.ref.child("groupChat")
            refToMessages.childByAutoId().setValue(tempMessage.toGroupChatDict())
        }
        else
        {
            sendMessageOneToOne(tempMessage: tempMessage)
        }
        
    }
    
    func sendMessageOneToOne(tempMessage :Message?)
    {
        //case 0: new chat , init chat in Firebase if the first message is a photo
        if messages.count == 0 && tempMessage == nil
        {
            var chatDict = Dictionary<String,AnyObject>()
            let messagesArray = [Dictionary<String,String>]()
            chatDict["firstUser"] = currentUser.makeDict() as AnyObject
            chatDict["secondUser"] = otherSideUser?.makeDict() as AnyObject
            chatDict["messages"] = messagesArray as AnyObject
            let refrence = self.ref.child("chats").childByAutoId()
            refrence.setValue(chatDict)

            
            chat = Chat(firstUser: currentUser, secondUser: otherSideUser!, messagesArray: messages, chatId: refrence.key)
            self.messagesFromFireBaseRealTime()
        }
        
        //case 1: new chat , init chat in Firebase
        else if messages.count == 1 
        {
            var chatDict = Dictionary<String,AnyObject>()
            let messagesArray = [Dictionary<String,String>]()
            chatDict["firstUser"] = currentUser.makeDict() as AnyObject
            chatDict["secondUser"] = otherSideUser?.makeDict() as AnyObject
            chatDict["messages"] = messagesArray as AnyObject
            let refrence = self.ref.child("chats").childByAutoId()
            refrence.setValue(chatDict)
            let refToMessages = self.ref.child("chats").child(refrence.key).child("messages")
            for obj in messages
            {
                refToMessages.childByAutoId().setValue(obj.toDictonary())
            }
            
            chat = Chat(firstUser: currentUser, secondUser: otherSideUser!, messagesArray: messages, chatId: refrence.key)
            self.messagesFromFireBaseRealTime()
            
        }
        //case 2: existing chat
        else if chat != nil || otherSideUser != nil
        {
            let refToMessages = self.ref.child("chats").child((chat?.chatId)!).child("messages")
            refToMessages.childByAutoId().setValue(tempMessage!.toDictonary())
        }
    }
    
    //MARK: - image picking from gallary
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        
        //send Photo
        if let image =  info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            self.showLoading()
            let tempMessage = Message()
            tempMessage.image = image
            tempMessage.message = ""
            
            // Data in memory
            let data = UIImageJPEGRepresentation(image, 0)
            
            // Create a reference to the file you want to upload
            let storageRef = Storage.storage().reference()
            let imageRef = storageRef.child("chat_photos/photo-\(currentUser.id)-\(messages.count)")
            
            
            // Upload the file to the path "images/rivers.jpg"
            _ = imageRef.putData(data!, metadata: nil) { (metadata, error) in
                guard let metadata = metadata else {
                    // Uh-oh, an error occurred!
                    return
                }
                // Metadata contains file metadata such as size, content-type, and download URL.
                let downloadURL = metadata.downloadURL
                tempMessage.imageUrl = downloadURL()?.absoluteString
                if self.isGroupChat
                {
                    tempMessage.userName = currentUser.fullName
                    let refToMessages = self.ref.child("groupChat")
                    refToMessages.childByAutoId().setValue(tempMessage.toGroupChatDict())
                }
                else
                {
                    //init chat on FireBase
                    if self.messages.count == 0
                    {
                        self.sendMessageOneToOne(tempMessage: nil)
                    }
                    tempMessage.userId = currentUser.id
                    let refToMessages = self.ref.child("chats").child((self.chat?.chatId)!).child("messages")
                    refToMessages.childByAutoId().setValue(tempMessage.toDictonary())
                }
                
                self.messages.append(tempMessage)
                self.hideLoading()
                
            }
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }

    //MARK: - keyboard configs & avoding textView
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if messageInputTextView.textColor == UIColor.gray
        {
            messageInputTextView.text = nil
            messageInputTextView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if messageInputTextView.text.isEmpty
        {
            messageInputTextView.text = "Type a message"
            messageInputTextView.textColor = UIColor.gray
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    {
        if(text == "\n") {
            textView.resignFirstResponder()
            self.sendMessage()
            return false
        }
        return true
    }
    
    @objc func keyboardNotification(notification: NSNotification)
    {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
                self.keyboardHeightLayoutConstraint?.constant = 0.0
            } else {
                self.keyboardHeightLayoutConstraint?.constant = endFrame?.size.height ?? 0.0
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
    
    //MARK: - utilites
    func scrollDownTableView()
    {
        if messages.count != 0
        {
            let numberOfSections = self.tableView.numberOfSections
            let numberOfRows = self.tableView.numberOfRows(inSection: numberOfSections-1)
            let indexPath = IndexPath(row: numberOfRows-1 , section: numberOfSections-1)
            
            self.tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.middle, animated: true)
        }
        
        
    }
    
    func viewConfig()
    {
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "chatBG")!)
        
        messageInputTextView.backgroundColor = UIColor(rgb: 0xFF83EAB6 )
        messageInputTextView.text = "Type a message"
        messageInputTextView.textColor = UIColor.gray
        messageInputTextView.layer.cornerRadius = 15.0
        messageInputTextView.layer.borderWidth = 2.0
        
        let amountOfLinesToBeShown:CGFloat = 6
        let maxHeight:CGFloat = messageInputTextView.font!.lineHeight * amountOfLinesToBeShown
        
        messageInputTextView.sizeThatFits(CGSize(width: messageInputTextView.frame.size.width , height: maxHeight))
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ChatVC.backToMainVC(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
        
        navigationController?.navigationBar.barTintColor = UIColor(red: 24, green: 38, blue: 48, alpha: 1)
    }
    
    func hideKeyboard()
    {
        self.view.endEditing(true)
    }
    
    //MARK: - segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? FullImageVC
        {
            if let imageUrl = sender as? String
            {
                destination.imageUrl = imageUrl
            }
        }
    }

}
