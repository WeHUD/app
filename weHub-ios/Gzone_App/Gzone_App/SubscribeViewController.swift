//
//  SubscribeViewController.swift
//  Gzone_App
//
//  Created by Tracy Sablon on 05/03/2017.
//  Copyright © 2017 Tracy Sablon. All rights reserved.
//

import UIKit

class SubscribeViewController: UIViewController {

    @IBOutlet weak var closeSubcriptionBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func log(_ sender: Any) {
        
        //Switch to storyboard Home
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Home_ID") as UIViewController
        present(vc, animated: true, completion: nil)
        
        
        
        //Check if subscription is valid before saving data
        
        //Call WS for sign up
        
        //Save user settings when subscribe
        let defaults = UserDefaults.standard
        defaults.set("", forKey: "email")
        defaults.set("", forKey: "username")
        defaults.set("", forKey: "token")

    }

}
