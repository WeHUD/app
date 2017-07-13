//
//  AuthenticationService.swift
//  Gzone_App
//
//  Created by Tracy Sablon on 09/07/2017.
//  Copyright © 2017 Tracy Sablon. All rights reserved.
//

import UIKit

class AuthenticationService: NSObject {

    static let sharedInstance = AuthenticationService()
    var accessToken : String?
    var currentUser : User?
    var loginIsConfirmed = false
    
    func initUserAuthentication(){
        
        // Retrieve user token into UserDefault interface if exist
        if(UserDefaults.standard.array(forKey: "token") != nil){
            let token = UserDefaults.standard.object(forKey: "token") as? [String] ?? [String]()
            self.accessToken = token[0]
            print(self.accessToken ?? "no token")
            print(token[0])
            
            self.getUser(accessToken: token[0])
            
        }
        
    }
    
    func logOffUser(){
        
        // Retrieve user token into UserDefault interface if exist
        if(UserDefaults.standard.array(forKey: "token") != nil){
            
            UserDefaults.standard.removeObject(forKey: "token")
            
        }
    
    }
    
    func getUserInfoByCredentials(userLogin : String!, userPassword : String!){
        
    
        let userWB : WBUser = WBUser()
        
        // With users credentials (username, pass)
        // Retrieve user token and user information
        userWB.login(userMail: userLogin, userPassword: userPassword){
            (token: Token) in
            
            if(token == nil){
                print("Email ou mot de passe incorrect")
            }
            else{
                DispatchQueue.main.async(execute: {
                    self.getUser(accessToken: token.accessToken)
                    let array = [token.accessToken,token.expire.description]
                    UserDefaults.standard.set(array,forKey: "token")
                    self.accessToken = token.accessToken
                    
                    
                    
                })
            }

        }
    }
    
    func getUser(accessToken : String) {
        
        let userWB : WBUser = WBUser()
        userWB.getUserByToken(accessToken: accessToken){
            (result : User) in
            self.currentUser = result
            // If user token exist
            // go to Home view directly
            
         /*   if NetworkReachability.shared.isNetworkAvailable == false {
                let topViewController = UIApplication.shared.keyWindow?.rootViewController
                topViewController?.networkServiceDisabledAlert()
            }
            else {
            
                let storyboard = UIStoryboard(name: "Home", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "Home_ID") as! UITabBarController
                let topViewController = UIApplication.shared.keyWindow?.rootViewController
                topViewController?.present(vc, animated: true, completion: nil)
            }*/
            DispatchQueue.main.async() {
                let storyboard = UIStoryboard(name: "Home", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "Home_ID") as! UITabBarController
                let topViewController = UIApplication.shared.keyWindow?.rootViewController
                topViewController?.present(vc, animated: true, completion: nil)
            }

        }
    }
    
    
}
