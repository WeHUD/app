//
//  WBFollower.swift
//  Gzone_App
//
//  Created by Lyes Atek on 19/06/2017.
//  Copyright © 2017 Tracy Sablon. All rights reserved.
//

import Foundation
class WBFollower: NSObject {
    
    /*  func addFollower(userId : String,followerId : String,_ completion: @escaping (_ result: Void) -> Void){
     
     
     let urlPath :String = "https://g-zone.herokuapp.com/followers"
     
     let url: URL = URL(string: urlPath)!
     let request = NSMutableURLRequest(url: url as URL)
     request.httpMethod = "POST"
     let session = URLSession.shared
     let params = ["userId":userId, "followerId" : followerId] as Dictionary<String, String>
     
     do{
     request.httpBody = try JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions())
     print("request is : \(String(describing: request.httpBody))")
     }
     catch{
     print("NSJSONSerialization error for register webservice")
     }
     
     request.addValue("application/json", forHTTPHeaderField: "Content-Type")
     request.addValue("application/json", forHTTPHeaderField: "Accept")
     
     
     let task = session.dataTask(with: url, completionHandler: {data, response, error -> Void in
     
     if error != nil {
     // If there is an error in the web request, print it to the console
     print(error!.localizedDescription)
     }
     
     })
     task.resume()
     }*/
    
    func addFollowerUser(userId : String,followerId : String,accessToken : String, completion: @escaping (_ status : Bool) -> Void){
        
        let urlPath :String = "https://g-zone.herokuapp.com/users/follow-user/"+userId+"/"+followerId+"?access_token="+accessToken
        
        
        let url: NSURL = NSURL(string: urlPath)!
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "PUT"
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            
            if error != nil {
                // If there is an error in the web request, print it to the console
                print(error!.localizedDescription)
                completion(false)
            }else{
                completion(true)
                
            }
            
        })
        task.resume()
    }
    func deleteFollowerUser(userId : String,followerId : String,accessToken : String,completion: @escaping (_ status : Bool) -> Void){
        
        let urlPath :String = "https://g-zone.herokuapp.com/users/unfollow-user/"+userId+"/"+followerId+"?access_token="+accessToken
        let url: NSURL = NSURL(string: urlPath)!
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "PUT"
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            
            if error != nil {
                // If there is an error in the web request, print it to the console
                print(error!.localizedDescription)
                completion(false)
            }else{
                completion(true)
                
            }
            
        })
        task.resume()
    }
    
    
    func addFollowerGame(userId : String,gameId : String,accessToken : String, completion: @escaping (_ status : Bool) -> Void){
        
        let urlPath :String = "https://g-zone.herokuapp.com/games/follow-game/"+userId+"/"+gameId+"?access_token="+accessToken
        
        
        let url: NSURL = NSURL(string: urlPath)!
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "PUT"
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            
            if error != nil {
                // If there is an error in the web request, print it to the console
                print(error!.localizedDescription)
                completion(false)
            }else{
                completion(true)
                
            }
            
        })
        task.resume()
    }
    
    func deleteFollowerGame(userId : String,gameId : String,accessToken : String, completion: @escaping (_ status : Bool) -> Void){
        
        let urlPath :String = "https://g-zone.herokuapp.com/users/unfollow-user+"+userId+"/"+gameId+"?access_token="+accessToken
        let url: NSURL = NSURL(string: urlPath)!
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "PUT"
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            
            if error != nil {
                // If there is an error in the web request, print it to the console
                print(error!.localizedDescription)
                completion(false)
            }else{
                completion(true)
                
            }
            
        })
        task.resume()
    }
    
    
    
    
    
    
    
}
