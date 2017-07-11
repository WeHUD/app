//
//  ForgotPassViewController.swift
//  Gzone_App
//
//  Created by Tracy Sablon on 05/03/2017.
//  Copyright © 2017 Tracy Sablon. All rights reserved.
//

import UIKit

class ForgotPassViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var mailTxtField: UITextField!

    @IBOutlet weak var SendMailBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        SendMailBtn.layer.cornerRadius = 15;
        SendMailBtn.layer.borderWidth = 0.0;
        SendMailBtn.layer.borderColor = UIColor.white.cgColor
        SendMailBtn.backgroundColor = (UIColor(red: 78/255.0, green: 14/255.0, blue: 15/255.0, alpha: 1.0))

        self.mailTxtField.delegate = self
        
        //extension Utils
        self.view.closeTextField()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.mailTxtField.resignFirstResponder()
        
        return true
    }
    
    @IBAction func closeForgotPass(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }

}
