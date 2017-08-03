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

class ChatVC: ParentViewController , UITableViewDelegate , UITableViewDataSource ,UITextViewDelegate {
    
    var messages = [Message]()
    var chat: Chat?
    var otherSideUser: LinkerUser?
    var ref: DatabaseReference!
    var isNewChat: Bool = true
 
    //@IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var keyboardHeightLayoutConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var messageInputTextView: UITextView!
    @IBOutlet weak var tableView: UITableView!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        messageInputTextView.layer.cornerRadius = 15.0
        messageInputTextView.layer.borderWidth = 2.0
        
        let amountOfLinesToBeShown:CGFloat = 6
        let maxHeight:CGFloat = messageInputTextView.font!.lineHeight * amountOfLinesToBeShown

        messageInputTextView.sizeThatFits(CGSize(width: messageInputTextView.frame.size.width , height: maxHeight))
        
        //messageLabel.sizeToFit()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140
        
        messageInputTextView.delegate = self
        

        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ChatVC.backToMainVC(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
        
        ref = Database.database().reference()
        
        if isNewChat && otherSideUser != nil
        {
            self.navigationItem.title = otherSideUser?.fullName
            self.showLoading()
            self.checkIfChatIsExisted()
        }
        else if !isNewChat && chat != nil
        {
            self.navigationItem.title = chat?.secondUser.fullName
            messages = (chat?.messages)!
            
        }
        
    }
  
    func checkIfChatIsExisted()
    {
        ref.observe(DataEventType.value, with: { (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            // ...
            
            if let dic = postDict["chats"] as?  Dictionary<String,Dictionary<String,AnyObject>>
            {
                for (key,value) in dic
                {
                    if value["firstUser"]?["id"] as? String == currentUser.id
                    {
                        if value["secondUser"]?["id"] as? String == self.otherSideUser?.id
                        {
                            let newRef = self.ref.child("chats").child(key).child("messages")
                            newRef.queryOrderedByKey().observe(DataEventType.value, with: {(snapshot) in
                            
                                self.isNewChat = false
                                print(snapshot.value ?? "none!")
                                if let messagesArray = snapshot.value as? [String: [String:String]]
                                {
                                    self.chat = Chat(firstUser: currentUser, secondUser: self.otherSideUser!, messagesArrayDict: messagesArray, chatId: key)
                                    self.messages = (self.chat?.messages)!
                                }
                                self.tableView.reloadData()
                            })
                            
                            
                                
                            
                        }
                    }
                    
                }
            }
            self.tableView.reloadData()
            self.hideLoading()
        })
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
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
        if let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as? MessageCell
        {
            cell.configureCell(message: messages[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
    
    @IBAction func sendBtnPressed(_ sender: Any) {
        self.sendMessage()
    }
    
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
        scrollDownTableView()
        
        if messages.count == 1
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
            
            //to do work ,,, populate chat var
            chat = Chat(firstUser: currentUser, secondUser: otherSideUser!, messagesArray: messages, chatId: refrence.key)
            
        }
        else if chat != nil || otherSideUser != nil
        {
            let refToMessages = self.ref.child("chats").child((chat?.chatId)!).child("messages")
            refToMessages.childByAutoId().setValue(tempMessage.toDictonary())
        }

    }
    
    func scrollDownTableView()
    {
        let numberOfSections = self.tableView.numberOfSections
        let numberOfRows = self.tableView.numberOfRows(inSection: numberOfSections-1)
        
        let indexPath = IndexPath(row: numberOfRows-1 , section: numberOfSections-1)
        self.tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.middle, animated: true)
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            self.sendMessage()
            return false
        }
        return true
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
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
    
    

}
