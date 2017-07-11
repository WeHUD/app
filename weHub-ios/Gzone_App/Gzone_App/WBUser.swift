//
//  WBUser.swift
//  GZone
//
//  Created by Lyes Atek on 01/06/2017.
//  Copyright © 2017 Lyes Atek. All rights reserved.
//

import Foundation
import UIKit


class WBUser: NSObject {
    
    func getAllUsers(accessToken : String,offset : String, completion: @escaping (_ result: [User]) -> Void){
        
        var users : [User] = []
        let urlPath :String = "https://g-zone.herokuapp.com/users?access_token="+accessToken+"&offset="+offset
        
        
        let url: URL = URL(string: urlPath)!
        let session = URLSession.shared
        let task = session.dataTask(with: url, completionHandler: {data, response, error -> Void in
            
            if error != nil {
                // If there is an error in the web request, print it to the console
                print(error!.localizedDescription)
            }
            
            do{
                let jsonResult = try JSONSerialization.jsonObject(with: data!,  options: .allowFragments) as! NSArray
                print(jsonResult)
                users = WBUser.JSONToUserArray(jsonResult)
                completion(users)
            }
            catch{
                print("error")
            }
        })
        task.resume()
    }
    
    func getUser(userId : String,accessToken : String, completion: @escaping (_ result: User) -> Void){
        
        
        let urlPath :String = "https://g-zone.herokuapp.com/users/" + userId + "?"+accessToken
        
        let url: NSURL = NSURL(string: urlPath)!
        let session = URLSession.shared
        let task = session.dataTask(with: url as URL, completionHandler: {data, response, error -> Void in
            
            if error != nil {
                // If there is an error in the web request, print it to the console
                print(error!.localizedDescription)
            }
            
            do{
                let jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                
                let user : User = WBUser.JSONToUser(jsonUsers: jsonResult)!
                completion(user)
            }
            catch{
                print("error")
            }
        })
        task.resume()
    }
    func getUserByToken(accessToken : String, completion: @escaping (_ result: User) -> Void){
        
        
        let urlPath :String = "https://g-zone.herokuapp.com/users/token/" + accessToken
        
        let url: NSURL = NSURL(string: urlPath)!
        let session = URLSession.shared
        let task = session.dataTask(with: url as URL, completionHandler: {data, response, error -> Void in
            
            if error != nil {
                // If there is an error in the web request, print it to the console
                print(error!.localizedDescription)
            }
            
            do{
                let jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                
                let user : User = WBUser.JSONToUser(jsonUsers: jsonResult)!
                completion(user)
            }
            catch{
                print("error")
            }
        })
        task.resume()
    }
    
    func register(username : String, reply : String,email : String,password : String,completion: @escaping (_ result: String) -> Void){
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://g-zone.herokuapp.com/users")! as URL)
        let session = URLSession.shared
        request.httpMethod = "POST"
        
        let params = ["username" : username, "reply" : "@"+username , "dateOfBirth": "2017-05-08T17:01:53.000Z" , "email": email, "password": password]
        
        do{
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions())
            print("request is : \(String(describing: request.httpBody))")
        }
        catch{
            print("NSJSONSerialization error for register webservice")
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            
            do{
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableLeaves)
                print(json)
                let id : String  = (json as AnyObject).object(forKey: "_id") as! String
                completion(id)
            }
            catch{
                print("Error could not parse JSON")
            }
        })
        task.resume()
    }
    
    func updateUser(user : User,accessToken : String, completion: @escaping (_ status : Bool) -> Void){
        
        let urlPath :String = "https://g-zone.herokuapp.com/users/" + user._id + "?"+accessToken
        
        let url: NSURL = NSURL(string: urlPath)!
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "PUT"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        
        let userData : NSDictionary = ["username" : user.username,"reply" : user.reply,"dateOfBirth" : user.dateOfBirth,"password" : user.password,"longitude" : (user.longitude?.description)!,"latitude" : (user.latitude?.description)!,"followedUsers" : user.followedUsers,"followedGames" : user.followedGames,"score" : user.score,"connected" : user.connected,"avatar" : user.avatar,"datetimeRegister" : user.datetimeRegister?.description,"email" : user.email]
        

        
        
        let options : JSONSerialization.WritingOptions = JSONSerialization.WritingOptions();
        do{
            let requestBody = try JSONSerialization.data(withJSONObject: userData, options: options)
            
            request.httpBody = requestBody
            
            let session = URLSession.shared
            _ = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
                
                if error != nil {
                    // If there is an error in the web request, print it to the console
                    print(error!.localizedDescription)
                    completion(false)
                }
                completion(true)
                
            }).resume()
        }
        catch{
            print("error")
            completion(false)
        }
    }
    
    func login(userMail : String, userPassword : String,completion: @escaping (_ result: Token) -> Void){
        var accessToken : String = ""
        let request = NSMutableURLRequest(url: NSURL(string: "https://g-zone.herokuapp.com/oauth/token")! as URL)
        let session = URLSession.shared
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let clientId = "Xa3fBc74Zn1hKOZNafZWpVtjbyP30v"
        let clientSecret = "LhqGhPuVgDKafI"
        let loginString = String(format: "%@:%@", clientId, clientSecret)
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()
        
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        
        let bodyStr:String = "grant_type=password&username="+userMail+"&password="+userPassword
        request.httpBody = bodyStr.data(using: String.Encoding.utf8)
        
        //  let jsonData = try? JSONSerialization.data(withJSONObject: params)
        //  request.httpBody = jsonData
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            
            do{
                let jsonResult = try JSONSerialization.jsonObject(with: data!, options: .mutableLeaves) as! NSDictionary
                print(jsonResult)
                
                if (jsonResult["access_token"] as? String) != nil {
                    
                    let token = self.JSONToToken(json: jsonResult)
                    completion(token!)
                }else{
                    
                    if let codeStatus = jsonResult["code"] as? Int {
                        print(codeStatus)
                        
                        let status = codeStatus
                        
                        if status != 200 {
                            
                            DispatchQueue.main.async(execute: {
                                
                                let topViewController = UIApplication.shared.keyWindow?.rootViewController
                                topViewController?.httpErrorStatusAlert(status: status, errorType: (jsonResult["error"] as! String))
                            })
                            
                        }
                    }
                }
            }
            catch{
                print("error")
            }
        })
        task.resume()
    }

    func getFollowedUser(accessToken : String,userId : String,offset : String, completion: @escaping (_ result: [User]) -> Void){
        
        var users : [User] = []
        let urlPath :String = "https://g-zone.herokuapp.com/users/followed-users/"+userId+"?access_token="+accessToken+"&offset="+offset
        
        
        let url: URL = URL(string: urlPath)!
        let session = URLSession.shared
        let task = session.dataTask(with: url, completionHandler: {data, response, error -> Void in
            
            if error != nil {
                // If there is an error in the web request, print it to the console
                print(error!.localizedDescription)
            }
            
            do{
                let jsonResult = try JSONSerialization.jsonObject(with: data!,  options: .allowFragments) as! NSArray
                print(jsonResult)
                users = WBUser.JSONToUserArray(jsonResult)
                completion(users)
            }
            catch{
                print("error")
            }
        })
        task.resume()
    }

    func getFollowedGames(accessToken : String,userId : String,offset : String, completion: @escaping (_ result: [Game]) -> Void){
        
        var games : [Game] = []
        let urlPath :String = "https://g-zone.herokuapp.com/users/followed-games/"+userId+"?"+accessToken+"&"+offset
        
        
        let url: URL = URL(string: urlPath)!
        let session = URLSession.shared
        let task = session.dataTask(with: url, completionHandler: {data, response, error -> Void in
            
            if error != nil {
                // If there is an error in the web request, print it to the console
                print(error!.localizedDescription)
            }
            
            do{
                let jsonResult = try JSONSerialization.jsonObject(with: data!,  options: .allowFragments) as! NSArray
                print(jsonResult)
                
                games = WBGame.JSONToGameArray(jsonResult)
                completion(games)
            }
            catch{
                print("error")
            }
        })
        task.resume()
    }
    

    
    
   static func JSONToUserArray(_ jsonEvents : NSArray) -> [User]{
        print (jsonEvents)
        var users : [User] = []
        
        for object in jsonEvents{
            let _id = (object as AnyObject).object(forKey: "_id") as! String
            let dateOfBirth = (object as AnyObject).object(forKey: "dateOfBirth") as! String
            let email = (object as AnyObject).object(forKey: "email") as! String
            let username = (object as AnyObject).object(forKey: "username") as! String
            let reply = (object as AnyObject).object(forKey: "reply") as! String
            var avatar : String
            if((object as AnyObject).object(forKey: "avatar") != nil){
                avatar = (object as AnyObject).object(forKey: "avatar") as! String
            }else{
                avatar = " "
            }
            var longitude: Int
            if((object as AnyObject).object(forKey: "longitude") != nil){
                longitude = (object as AnyObject).object(forKey: "longitude") as! Int
            }else{
                longitude = 0
            }
            
            var latitude : Int
            if((object as AnyObject).object(forKey: "latitude") != nil){
                latitude = (object as AnyObject).object(forKey: "latitude") as! Int
            }else{
                latitude = 0
            }
            let connected = (object as AnyObject).object(forKey: "connected") as! Bool
            let score = (object as AnyObject).object(forKey: "score") as! Int
            
            let datetimeRegister = (object as AnyObject).object(forKey: "datetimeRegister") as! String
            
            let password = (object as AnyObject).object(forKey: "password") as! String
            let followedUsers = (object as AnyObject).object(forKey: "followedUsers") as! [String]
            let followedGames = (object as AnyObject).object(forKey: "followedGames") as! [String]
            let newUser : User = User(id: _id, dateOfBirth: dateOfBirth, email: email, username: username, reply: reply, password: password, avatar: avatar, datetimeRegister: datetimeRegister, longitude: longitude, latitude: latitude, followedUsers: followedUsers, followedGames: followedGames, score: score, connected: connected)
            users.append(newUser);
        }
        return users;
    }
    
    static func JSONToUser(jsonUsers : NSDictionary) ->User?{
        let _id = jsonUsers.object(forKey: "_id") as! String
        let dateOfBirth = jsonUsers.object(forKey: "dateOfBirth") as! String
        let email = jsonUsers.object(forKey: "email") as! String
        let username = jsonUsers.object(forKey: "username") as! String
        let reply = jsonUsers.object(forKey: "reply") as! String
        var avatar : String
        if(jsonUsers.object(forKey: "avatar") != nil){
            avatar = jsonUsers.object(forKey: "avatar") as! String
        }else{
            avatar = " "
        }
        var longitude: Int
        if(jsonUsers.object(forKey: "longitude") != nil){
            longitude = jsonUsers.object(forKey: "longitude") as! Int
        }else{
            longitude = 0
        }
        
        var latitude : Int
        if(jsonUsers.object(forKey: "latitude") != nil){
            latitude = jsonUsers.object(forKey: "latitude") as! Int
        }else{
            latitude = 0
        }
        let connected = jsonUsers.object(forKey: "connected") as! Bool
        let score = jsonUsers.object(forKey: "score") as! Int
        
        let datetimeRegister = jsonUsers.object(forKey: "datetimeRegister") as! String
        
        let password = jsonUsers.object(forKey: "password") as! String
        let followedUsers = jsonUsers.object(forKey: "followedUsers") as! [String]
        let followedGames = jsonUsers.object(forKey: "followedGames") as! [String]
        let newUser : User = User(id: _id, dateOfBirth: dateOfBirth, email: email, username: username, reply: reply, password: password, avatar: avatar, datetimeRegister: datetimeRegister, longitude: longitude, latitude: latitude, followedUsers: followedUsers, followedGames: followedGames, score: score, connected: connected)
        print(newUser)
        return newUser
    }
    
     func JSONToToken(json : NSDictionary) ->Token?{
        let accessToken = json.object(forKey: "access_token") as! String
        let expire = json.object(forKey: "expires_in") as! Int
        let token : Token = Token(accessToken: accessToken, expire: expire)
        return token
    }



}
