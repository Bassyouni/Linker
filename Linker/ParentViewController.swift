//
//  ParentViewController.swift
//  Marriage
//
//  Created by ZooZoo on 12/17/16.
//  Copyright © 2016 ZooZoo. All rights reserved.
//

import UIKit

class ParentViewController: UIViewController {

    var hud : MBProgressHUD!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
