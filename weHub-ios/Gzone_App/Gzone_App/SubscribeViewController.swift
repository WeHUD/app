//
//  SubscribeViewController.swift
//  Gzone_App
//
//  Created by Tracy Sablon on 05/03/2017.
//  Copyright © 2017 Tracy Sablon. All rights reserved.
//

import UIKit

class SubscribeViewController: UIViewController {
    
    @IBOutlet weak var dateBirth: UIDatePicker!
    @IBOutlet weak var confirmPasswordTxtFld: UITextField!
    @IBOutlet weak var passwordTxtFld: UITextField!
    @IBOutlet weak var emailTxtFld: UITextField!
    @IBOutlet weak var usernameTxtFld: UITextField!
    @IBOutlet weak var closeSubcriptionBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let now = Date()
        self.dateBirth.maximumDate = now
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func log(_ sender: Any) {
        
        //Check if subscription is valid before saving data
        if(self.usernameTxtFld.text! == "" || self.emailTxtFld.text == "" || self.passwordTxtFld.text! == "" || self.confirmPasswordTxtFld.text! == ""){
            locationServiceDisabledAlert(title: "Subscribe" , message: "Please enter all fields")
            return
        }
        if(self.passwordTxtFld.text != self.confirmPasswordTxtFld.text){
            locationServiceDisabledAlert(title: "Subscribe" , message: "Passwords do not match")
            return
        }
        
        //Call WS for sign up
        self.register()
        
    }
    
    func register(){
        let userWB : WBUser = WBUser()
        userWB.register(username: self.usernameTxtFld.text!, reply: "@"+self.usernameTxtFld.text!, email: self.emailTxtFld.text!, password: self.passwordTxtFld.text!, dateOfBirth: dateBirth.date.description){
            (result : String)in
            AuthenticationService.sharedInstance.getUserInfoByCredentials(userLogin: self.usernameTxtFld.text, userPassword: self.passwordTxtFld.text)
            
            
        }
    }
    
    
    
    @IBAction func valueChanged(_ sender: Any) {
        print(self.dateBirth.date.description)
    }
}
