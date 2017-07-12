//
//  WBFollower.swift
//  Gzone_App
//
//  Created by Lyes Atek on 19/06/2017.
//  Copyright © 2017 Tracy Sablon. All rights reserved.
//

import Foundation
class WBFollower: NSObject {
    
    
    
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
