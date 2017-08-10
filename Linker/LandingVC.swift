//
//  ViewController.swift
//  Linker
//
//  Created by Bassyouni on 7/31/17.
//  Copyright © 2017 Bassyouni. All rights reserved.
//

import UIKit
import Firebase
import FacebookLogin
import FacebookCore


class LandingVC: ParentViewController {

    var ref: DatabaseReference!
    
   @IBOutlet weak var facebookLoginBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        self.facebookLoginBtn.addTarget(self, action: #selector(self.loginButtonClicked), for: UIControlEvents.touchUpInside)
        //AccessToken.current = nil
        if let accsesToken = AccessToken.current
        {
            self.showLoading()
            self.fetchUser(userID: accsesToken.userId!, userName: nil, userImageUrl: nil)
        }
        
        
        
    }

    @objc func loginButtonClicked() {
        showLoading()
        let loginManager = LoginManager()
        loginManager.logIn([ .publicProfile ], viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
                self.hideLoading()
            case .cancelled:
                print("User cancelled login.")
                self.hideLoading()
            case .success( _, _, _):
                // self.showLoading()
                print("Logged in!")
                
                let connection = GraphRequestConnection()
                connection.add(GraphRequest(graphPath: "/me" , parameters: ["fields": "name,email,first_name,last_name,picture.type(small)"])) { httpResponse, result in
                    switch result {
                    case .success(let response):
                        // taking data from Facebook
                        let dic = response.dictionaryValue!
                        if let pictureDic = dic["picture"] as? Dictionary<String ,AnyObject>
                        {
                            if let dataDic = pictureDic["data"] as? Dictionary<String ,AnyObject>
                            {
                                currentUser.imageUrl = dataDic["url"]! as? String
                            }
                        }
                        
                        currentUser.id = dic["id"]! as! String
                        currentUser.fullName = dic["name"]! as! String
                        
                        self.fetchUser(userID: currentUser.id, userName: currentUser.fullName, userImageUrl: currentUser.imageUrl)
                        

                    case .failed(let error):
                        print("Graph Request Failed: \(error)")
                    }
                }
                connection.start()
            }
        }
    }
    
    func fetchUser(userID: String, userName: String?, userImageUrl: String? )
    {
        let userRef = ref.child("users").child(userID)
        userRef.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            // ...
            
            if userName == nil
            {
                currentUser.id = userID
                currentUser.fullName = postDict["fullName"]! as? String
                currentUser.imageUrl = postDict["imageUrl"]! as? String
            }
            else
            {
                currentUser.id = userID
                currentUser.fullName = userName
                currentUser.imageUrl = userImageUrl
                self.ref.child("users").child(currentUser.id!).setValue(currentUser.makeDict())
            }
            
            
            
            self.hideLoading()
            self.makeSegueToMainVC()
            
            
        })
    }
    
    func makeSegueToMainVC()
    {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        let homeNav = self.storyboard?.instantiateViewController(withIdentifier: "MainVC")

        delegate?.window?.rootViewController = homeNav
    }


}

