//
//  WBComment.swift
//  Gzone_App
//
//  Created by Lyes Atek on 19/06/2017.
//  Copyright © 2017 Tracy Sablon. All rights reserved.
//

import Foundation
class WBComment: NSObject {
    
    func addComment(userId : String,postId : String,text : String,accessToken : String,_ completion: @escaping (_ result: Void) -> Void){
        
        let urlPath :String = "https://g-zone.herokuapp.com/comments?access_token="+accessToken
        
        let url: URL = URL(string: urlPath)!
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        let session = URLSession.shared
        let params = ["userId":userId,"postId" : postId,"text" : text]
        
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
    }
    
    func deleteComment(commentId : String,accessToken : String, _ completion: @escaping (_ result: Void) -> Void){
        
        
        let urlPath :String =  "https://g-zone.herokuapp.com/comments/"+commentId+"?access_token="+accessToken
        
        
        let url: URL = URL(string: urlPath)!
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "DELETE"
        let session = URLSession.shared
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        
        let task = session.dataTask(with: url, completionHandler: {data, response, error -> Void in
            
            if error != nil {
                // If there is an error in the web request, print it to the console
                print(error!.localizedDescription)
            }
            
        })
        task.resume()
    }
    
    func getCommentByUserId(userId : String,accessToken : String,_ completion: @escaping (_ result: [Comment]) -> Void){
        
        var comments : [Comment] = []
        let urlPath :String = "https://g-zone.herokuapp.com/comments/user/"+userId+"?access_token="+accessToken
        
        
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
                comments = self.JSONToCommentArray(jsonResult)
                completion(comments)
            }
            catch{
                print("error")
            }
        })
        task.resume()
    }
    
    func getCommentByPostId(postId : String,accessToken : String ,_ completion: @escaping (_ result: [Comment]) -> Void){
        
        var comments : [Comment] = []
        let urlPath :String = "https://g-zone.herokuapp.com/comments/post/"+postId+"&access_token="+accessToken
        
        
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
                comments = self.JSONToCommentArray(jsonResult)
                completion(comments)
            }
            catch{
                print("error")
            }
        })
        task.resume()
    }

    
    func getCommentById(commentId : String,accessToken : String,_ completion: @escaping (_ result: Comment) -> Void){
        
        
        let urlPath :String = "https://g-zone.herokuapp.com/comments/"+commentId+"&access_token="+accessToken
        
        
        let url: URL = URL(string: urlPath)!
        let session = URLSession.shared
        let task = session.dataTask(with: url, completionHandler: {data, response, error -> Void in
            
            if error != nil {
                // If there is an error in the web request, print it to the console
                print(error!.localizedDescription)
            }
            
            do{
                let jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                
                let comment : Comment = self.JSONToComment(json: jsonResult)!
                completion(comment)
            }
            catch{
                print("error")
            }
        })
        task.resume()
    }
    
    
    
    func JSONToCommentArray(_ jsonEvents : NSArray) -> [Comment]{
        print (jsonEvents)
        var commentsTab : [Comment] = []
        
        for object in jsonEvents{
            let _id = (object as AnyObject).object(forKey: "_id") as! String
            let userId = (object as AnyObject).object(forKey: "userId") as! String
            let postId = (object as AnyObject).object(forKey: "postId") as! String
            let text = (object as AnyObject).object(forKey: "text") as! String
            var video : String
            if((object as AnyObject).object(forKey: "videos") != nil){
                video = (object as AnyObject).object(forKey: "video") as! String
            }else{
                video = ""
            }
            let datetimeCreated = (object as AnyObject).object(forKey: "datetimeCreated") as! Date
            
            let comment : Comment = Comment(_id: _id, userId: userId,postId : postId, text: text, video: video, datetimeCreated: datetimeCreated)
            commentsTab.append(comment);
        }
        return commentsTab;
    }
    func JSONToComment(json : NSDictionary) ->Comment?{
        let _id = json.object(forKey: "_id") as! String
        let userId = json.object(forKey: "userId") as! String
        let postId = json.object(forKey: "postId") as! String
        let text = json.object(forKey: "text") as! String
        var video : String
        if(json.object(forKey: "videos") != nil){
            video = json.object(forKey: "video") as! String
        }else{
            video = ""
        }
        let datetimeCreated = json.object(forKey: "datetimeCreated") as! Date
        
        let comment : Comment = Comment(_id: _id, userId: userId,postId : postId, text: text, video: video, datetimeCreated: datetimeCreated)
        return comment
    }
    
    
}