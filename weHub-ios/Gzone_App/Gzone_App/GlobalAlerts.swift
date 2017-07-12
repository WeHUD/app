//
//  GlobalAlerts.swift
//  Gzone_App
//
//  Created by Tracy Sablon on 03/07/2017.
//  Copyright © 2017 Tracy Sablon. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func locationServiceDisabledAlert (title: String, message: String ) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func networkServiceDisabledAlert () {
        
        let alertController = UIAlertController(title: "No network", message: "Please check your network.", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func emptyFields (title: String, message: String ) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func followUserAlert (user: User ) {
        
        let alertController = UIAlertController(title: "Want to know more about \(user.username) ?", message: "", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "View Profile", style: UIAlertActionStyle.default, handler: { _ in
            let VC = self.storyboard?.instantiateViewController(withIdentifier: "ProfilUser") as! ProfilUserViewController
            //alertController.user = self.connectedUser
            self.present(VC, animated: true, completion: nil)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func httpErrorStatusAlert (status: Int, errorType: String){
        
        var title : String = ""
        var message : String = ""
        
        switch status {
            
        case 400:
            // Bad Request
            if errorType == "invalid_client" {
                title = "Login failed"
                message = "Please provide username and password."
            }
            else if errorType == "invalid_grant"{
                
                title = "Login failed"
                message = "Please check your credentials."
                
            }
            else {
                title = "Error"
                message = "The request could not be permormed."
            }
            break
            
        case 500:
            // Internal Server Error
            title = "Error"
            message = "Sorry we've had a server error.Please try again."
            break
        default:
            break
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
