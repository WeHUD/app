//
//  LoginViewController.swift
//  Gzone_App
//
//  Created by Tracy Sablon on 05/03/2017.
//  Copyright © 2017 Tracy Sablon. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController,UITextFieldDelegate{
    
    @IBOutlet weak var accountTxtField: UITextField!
    @IBOutlet weak var passTxtField: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var signInBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        signInBtn.layer.cornerRadius = 15;
        signInBtn.layer.borderWidth = 0.0;
        signInBtn.layer.borderColor = UIColor.white.cgColor
        signInBtn.backgroundColor = (UIColor(red: 78/255.0, green: 14/255.0, blue: 15/255.0, alpha: 1.0))
        
        self.accountTxtField.delegate = self
        self.passTxtField.delegate = self
        
        //extension Utils
        self.view.closeTextField()
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.accountTxtField.resignFirstResponder()
        self.passTxtField.resignFirstResponder()
        
        print("return")
        
        return true
    }
    
    @IBAction func closeLogin(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func log(_ sender: Any) {
        
        
        AuthenticationService.sharedInstance.getUserInfoByCredentials(userLogin: self.accountTxtField.text, userPassword: self.passTxtField.text)
        
    }
    
}
