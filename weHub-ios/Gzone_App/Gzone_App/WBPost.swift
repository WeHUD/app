//
//  WBPost.swift
//  Gzone_App
//
//  Created by Lyes Atek on 19/06/2017.
//  Copyright © 2017 Tracy Sablon. All rights reserved.
//

import Foundation
class WBPost: NSObject {
    
    func getPostTendance(accessToken : String,_ completion: @escaping (_ result: [Post]) -> Void){
        
        var posts : [Post] = []
        let urlPath :String = "https://g-zone.herokuapp.com/posts/likes/top?access_token="+accessToken
        
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
                posts = self.JSONToPostArray(jsonResult)
                completion(posts)
            }
            catch{
                print("error")
            }
        })
        task.resume()
    }
    
    func getAllPost(accessToken : String,_ completion: @escaping (_ result: [Post]) -> Void){
        
        var posts : [Post] = []
        let urlPath :String = "https://g-zone.herokuapp.com/posts?access_token="+accessToken
        
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
                posts = self.JSONToPostArray(jsonResult)
                completion(posts)
            }
            catch{
                print("error")
            }
        })
        task.resume()
    }
    
    func getPostOfFollowedUsers(userId : String,accessToken : String,offset : String,_ completion: @escaping (_ result: [Post]) -> Void){
        
        var posts : [Post] = []
        let urlPath :String = "https://g-zone.herokuapp.com/posts/followers/"+userId+"?access_token="+accessToken+"&offset="+offset
        
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
                posts = self.JSONToPostArray(jsonResult)
                completion(posts)
            }
            catch{
                print("error")
            }
        })
        task.resume()
    }

    
    func addPost(userId : String,text : String,author : String,accessToken : String, completion: @escaping (_ status : Bool) -> Void){
        
        let urlPath :String = "https://g-zone.herokuapp.com/posts?access_token="+accessToken
        
        let url: NSURL = NSURL(string: urlPath)!
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        
        let params = ["userId":userId, "text" : text,"author" : author] as Dictionary<String, String>
        
        
        
        
        let options : JSONSerialization.WritingOptions = JSONSerialization.WritingOptions();
        do{
            let requestBody = try JSONSerialization.data(withJSONObject: params, options: options)
            
            request.httpBody = requestBody
            
            let session = URLSession.shared
            _ = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
                
                if error != nil {
                    // If there is an error in the web request, print it to the console
                    print(error!.localizedDescription)
                    completion( false)
                }
                completion(true)
                
            }).resume()
        }
        catch{
            print("error")
            completion(false)
        }
    }
    func addPostVideo(userId : String,text : String,author : String,accessToken : String,video : String, completion: @escaping (_ status : Bool) -> Void){
        
        let urlPath :String = "https://g-zone.herokuapp.com/posts?access_token="+accessToken
        
        let url: NSURL = NSURL(string: urlPath)!
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        
        let params = ["userId":userId, "text" : text,"author" : author,"video" : video] as Dictionary<String, String>
        
        
        
        
        let options : JSONSerialization.WritingOptions = JSONSerialization.WritingOptions();
        do{
            let requestBody = try JSONSerialization.data(withJSONObject: params, options: options)
            
            request.httpBody = requestBody
            
            let session = URLSession.shared
            _ = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
                
                if error != nil {
                    // If there is an error in the web request, print it to the console
                    print(error!.localizedDescription)
                    completion( false)
                }
                completion(true)
                
            }).resume()
        }
        catch{
            print("error")
            completion(false)
        }
    }

    func addPostOpinion(userId : String,text : String,gameId : String,author : String,mark : String,flagOpinion : String,accessToken : String, completion: @escaping (_ status : Bool) -> Void){
        
        let urlPath :String = "https://g-zone.herokuapp.com/posts?access_token="+accessToken
        
        let url: NSURL = NSURL(string: urlPath)!
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        
        let params = ["userId":userId, "text" : text,"author" : author,"mark" : mark,"flagOpinion" : flagOpinion,"gameId":gameId] as Dictionary<String, String>
        
        
        
        
        let options : JSONSerialization.WritingOptions = JSONSerialization.WritingOptions();
        do{
            let requestBody = try JSONSerialization.data(withJSONObject: params, options: options)
            
            request.httpBody = requestBody
            
            let session = URLSession.shared
            _ = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
                
                if error != nil {
                    // If there is an error in the web request, print it to the console
                    print(error!.localizedDescription)
                    completion( false)
                }
                completion(true)
                
            }).resume()
        }
        catch{
            print("error")
            completion(false)
        }
    }
    
  
    
    func addPostGame(userId : String,text : String,author : String,gameId : String,accessToken : String, completion: @escaping (_ status : Bool) -> Void){
        
        let urlPath :String = "https://g-zone.herokuapp.com/posts?access_token="+accessToken
        
        let url: NSURL = NSURL(string: urlPath)!
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        
        let params = ["userId":userId, "text" : text,"author" : author,"gameId" : gameId] as Dictionary<String, String>
        
        
        
        
        let options : JSONSerialization.WritingOptions = JSONSerialization.WritingOptions();
        do{
            let requestBody = try JSONSerialization.data(withJSONObject: params, options: options)
            
            request.httpBody = requestBody
            
            let session = URLSession.shared
            _ = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
                
                if error != nil {
                    // If there is an error in the web request, print it to the console
                    print(error!.localizedDescription)
                    completion( false)
                }
                completion(true)
                
            }).resume()
        }
        catch{
            print("error")
            completion(false)
        }
    }
    
    func addPostUser(userId : String,text : String,author : String,receiverId : String,accessToken : String, completion: @escaping (_ status : Bool) -> Void){
        
        let urlPath :String = "https://g-zone.herokuapp.com/posts?access_token="+accessToken
        
        let url: NSURL = NSURL(string: urlPath)!
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        
        let params = ["userId":userId, "text" : text,"author" : author,"receiverId" : receiverId] as Dictionary<String, String>
        
        
        
        
        let options : JSONSerialization.WritingOptions = JSONSerialization.WritingOptions();
        do{
            let requestBody = try JSONSerialization.data(withJSONObject: params, options: options)
            
            request.httpBody = requestBody
            
            let session = URLSession.shared
            _ = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
                
                if error != nil {
                    // If there is an error in the web request, print it to the console
                    print(error!.localizedDescription)
                    completion( false)
                }
                completion(true)
                
            }).resume()
        }
        catch{
            print("error")
            completion(false)
        }
    }
    
    func getPostByUserId(userId : String,accessToken : String,offset : String,_ completion: @escaping (_ result: [Post]) -> Void){
        
        var posts : [Post] = []
        let urlPath :String = "https://g-zone.herokuapp.com/posts/user/"+userId+"?access_token="+accessToken+"&offset="+offset
        
        
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
                posts = self.JSONToPostArray(jsonResult)
                completion(posts)
            }
            catch{
                print("error")
            }
        })
        task.resume()
    }
    
    func getPostByGameId(gameId : String,accessToken : String,_ completion: @escaping (_ result: [Post]) -> Void){
        
        var posts : [Post] = []
        let urlPath :String = "https://g-zone.herokuapp.com/posts/game/"+gameId+"?access_token="+accessToken
        
        
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
                posts = self.JSONToPostArray(jsonResult)
                completion(posts)
            }
            catch{
                print("error")
            }
        })
        task.resume()
    }
    
    func getPostByReceiverId(receiverId : String,accessToken : String,_ completion: @escaping (_ result: [Post]) -> Void){
        
        var posts : [Post] = []
        let urlPath :String = "https://g-zone.herokuapp.com/posts/received/"+receiverId+"?access_token="+accessToken
        
        
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
                posts = self.JSONToPostArray(jsonResult)
                completion(posts)
            }
            catch{
                print("error")
            }
        })
        task.resume()
    }

    
    func getPostByLike(userId : String,accessToken : String,_ completion: @escaping (_ result: [Post]) -> Void){
        
        var posts : [Post] = []
        let urlPath :String = "https://g-zone.herokuapp.com/posts/user/"+userId+"?access_token="+accessToken
        
        
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
                posts = self.JSONToPostArray(jsonResult)
                completion(posts)
            }
            catch{
                print("error")
            }
        })
        task.resume()
    }
    
    
    func deletePost(postId : String, _ completion: @escaping (_ result: Void) -> Void){
        
        
        let urlPath :String =  "https://g-zone.herokuapp.com/posts/"+postId
        
        
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
    

    
    func JSONToPostArray(_ jsonEvents : NSArray) -> [Post]{
        print (jsonEvents)
        var posts : [Post] = []
        
        for object in jsonEvents{
            let _id = (object as AnyObject).object(forKey: "_id") as! String
            let userId = (object as AnyObject).object(forKey: "userId") as! String
            let text = (object as AnyObject).object(forKey: "text") as! String
            
            let likes = (object as AnyObject).object(forKey: "likes") as! [String]
            var gameId : String
            if((object as AnyObject).object(forKey: "gameId") != nil){
                gameId = (object as AnyObject).object(forKey: "gameId") as! String
            }else{
                gameId = ""
            }
            let comments = (object as AnyObject).object(forKey: "comments") as! [String]
            var flagOpinion : Bool
            if((object as AnyObject).object(forKey: "flagOpinion") != nil){
                flagOpinion = (object as AnyObject).object(forKey: "flagOpinion") as! Bool
            }else{
                flagOpinion = false
            }
            var video : String
            if((object as AnyObject).object(forKey: "video") != nil){
                video = (object as AnyObject).object(forKey: "video") as! String
            }else{
                video = ""
            }
            let datetimeCreated = (object as AnyObject).object(forKey: "datetimeCreated") as! String
            var author : String
            if((object as AnyObject).object(forKey: "author") != nil){
                author = (object as AnyObject).object(forKey: "author") as! String
            }else{
                author = " "
            }
            var mark : Int
            if((object as AnyObject).object(forKey: "mark") != nil){
                mark = (object as AnyObject).object(forKey: "mark") as! Int
            }else{
                mark = 0
            }

            
            //let username = json.object(forKey: "username") as! String
            let post : Post = Post(_id: _id, userId: userId, gameId: gameId, text: text, likes: likes, comments: comments, flagOpinion: flagOpinion, video: video, datetimeCreated: datetimeCreated, author: author, mark: mark)
            posts.append(post);
        }
        print("posts :", posts)
        return posts;
    }
    
    
    func JSONToPost(json : NSDictionary) ->Post?{
        let _id = json.object(forKey: "_id") as! String
        let userId = json.object(forKey: "userId") as! String
        let text = json.object(forKey: "text") as! String
        
        let likes = json.object(forKey: "likes") as! [String]
        var gameId : String
        if(json.object(forKey: "gameId") != nil){
            gameId = json.object(forKey: "gameId") as! String
        }else{
            gameId = ""
        }
        let comments = json.object(forKey: "comments") as! [String]
        var flagOpinion : Bool
        if(json.object(forKey: "flagOpinion") != nil){
            flagOpinion = json.object(forKey: "flagOpinion") as! Bool
        }else{
            flagOpinion = false
        }
        var video : String
        if(json.object(forKey: "video") != nil){
            video = json.object(forKey: "video") as! String
        }else{
            video = ""
        }
        let datetimeCreated = json.object(forKey: "datetimeCreated") as! String
        var author : String
        if(json.object(forKey: "author") != nil){
            author = json.object(forKey: "author") as! String
        }else{
            author = " "
        }
        let mark = json.object(forKey: "mark") as! Int
        
        
        
        //let username = json.object(forKey: "username") as! String
        let post : Post = Post(_id: _id, userId: userId, gameId: gameId, text: text, likes: likes, comments: comments, flagOpinion: flagOpinion, video: video, datetimeCreated: datetimeCreated, author: author,mark: mark)
        return post
    }
    
    func updatePost(post : Post,usersId : [String] , accessToken : String, completion: @escaping (_ status : Bool) -> Void){
        
        let urlPath :String = "https://g-zone.herokuapp.com/posts/" + post._id + "?access_token="+accessToken
        
        let url: NSURL = NSURL(string: urlPath)!
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "PUT"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        
        let userData : NSDictionary = ["likes" : usersId]
        
        
        
        
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
    
    
    
    
}
