//
//  WBGame.swift
//  Gzone_App
//
//  Created by Lyes Atek on 22/06/2017.
//  Copyright © 2017 Tracy Sablon. All rights reserved.
//

import Foundation
class WBGame: NSObject {
    
    func getAllGames(accessToken : String,offset : String,_ completion: @escaping (_ result: [Game]) -> Void){
        
        var games : [Game] = []
        let urlPath :String = "https://g-zone.herokuapp.com/games?access_token="+accessToken+"&offset="+offset
        
        
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
    
    func updateGame(game : Game,usersId : [String] , accessToken : String, completion: @escaping (_ status : Bool) -> Void){
        
        let urlPath :String = "https://g-zone.herokuapp.com/games/" + game._id + "?access_token="+accessToken
        
        let url: NSURL = NSURL(string: urlPath)!
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "PUT"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        
        let userData : NSDictionary = ["followersId" : usersId]
        
        
        
        
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
    
    func deleteVideo(gameId : String, _ completion: @escaping (_ result: Void) -> Void){
        
        
        let urlPath :String =  "https://g-zone.herokuapp.com/games/"+gameId
        
        
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
    
    func getGamesByCategoryId(categoryId : String,_ completion: @escaping (_ result: [Game]) -> Void){
        
        var games : [Game] = []
        let urlPath :String = "https://g-zone.herokuapp.com/games/category/"+categoryId
        
        
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
    
    func getGameById(gameId : String,accessToken : String,_ completion: @escaping (_ result: Game) -> Void){
        
        
        let urlPath :String = "https://g-zone.herokuapp.com/games/"+gameId+"?access_token="+accessToken
        
        
        let url: URL = URL(string: urlPath)!
        let session = URLSession.shared
        let task = session.dataTask(with: url, completionHandler: {data, response, error -> Void in
            
            if error != nil {
                // If there is an error in the web request, print it to the console
                print(error!.localizedDescription)
            }
            
            do{
                let jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                
                let game : Game = self.JSONToGame(jsonGame: jsonResult)!
                completion(game)
            }
            catch{
                print("error")
            }
        })
        task.resume()
    }
    
    
    
    static func JSONToGameArray(_ jsonEvents : NSArray) -> [Game]{
        print (jsonEvents)
        var games : [Game] = []
        
        for object in jsonEvents{
            let _id  = (object as AnyObject).object(forKey: "_id") as! String
            let name = (object as AnyObject).object(forKey: "name") as! String
            let platforms = (object as AnyObject).object(forKey: "platforms") as! [String]
            let developer = (object as AnyObject).object(forKey: "developer") as! String
            let editor = (object as AnyObject).object(forKey: "editor") as! String
            let categories = (object as AnyObject).object(forKey: "categories") as! [String]
            let synopsis = (object as AnyObject).object(forKey: "synopsis") as! String
            let solo = (object as AnyObject).object(forKey: "solo") as! Bool
            let multiplayer = (object as AnyObject).object(forKey: "multiplayer") as! Bool
            let cooperative = (object as AnyObject).object(forKey: "cooperative") as! Bool
            
            var website : String
            if((object as AnyObject).object(forKey: "website") != nil){
                website = (object as AnyObject).object(forKey: "website") as! String
            }else{
                website = ""
            }
            var boxart : String
            if( (object as AnyObject).object(forKey: "boxart") != nil){
                boxart = (object as AnyObject).object(forKey: "boxart") as! String
            }else{
                boxart = ""
            }
            
            let datetimeCreated = (object as AnyObject).object(forKey: "datetimeCreated") as! String
            let followersId = (object as AnyObject).object(forKey: "followersId") as! [String]
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            
            let datePost = dateFormatter.date(from: datetimeCreated)
            
            dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
            
            
            
            let game : Game = Game(_id: _id, name: name, platforms: platforms, developer: developer, editor: editor, categories: categories, synopsis: synopsis, solo: solo, multiplayer: multiplayer, cooperative: cooperative, website: website, boxart: boxart, datetimeCreated: dateFormatter.string(from: datePost!), followerId: followersId)
            games.append(game);
        }
        return games;
    }
    
    func JSONToGame(jsonGame : NSDictionary) ->Game?{
        let _id  = jsonGame.object(forKey: "_id") as! String
        let name = jsonGame.object(forKey: "name") as! String
        let platforms = jsonGame.object(forKey: "platforms") as! [String]
        let developer = jsonGame.object(forKey: "developer") as! String
        let editor = jsonGame.object(forKey: "editor") as! String
        let categories = jsonGame.object(forKey: "categories") as! [String]
        let synopsis = jsonGame.object(forKey: "synopsis") as! String
        let solo = jsonGame.object(forKey: "solo") as! Bool
        let multiplayer = jsonGame.object(forKey: "multiplayer") as! Bool
        let cooperative = jsonGame.object(forKey: "cooperative") as! Bool
        
        var website : String
        if(jsonGame.object(forKey: "website") != nil){
            website = jsonGame.object(forKey: "website") as! String
        }else{
            website = ""
        }
        let boxart = jsonGame.object(forKey: "boxart") as! String
        let datetimeCreated = jsonGame.object(forKey: "datetimeCreated") as! String
        let followersId = jsonGame.object(forKey: "followersId") as! [String]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        let datePost = dateFormatter.date(from: datetimeCreated)
        
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        
        let game : Game = Game(_id: _id, name: name, platforms: platforms, developer: developer, editor: editor, categories: categories, synopsis: synopsis, solo: solo, multiplayer: multiplayer, cooperative: cooperative, website: website, boxart: boxart, datetimeCreated: dateFormatter.string(from: datePost!), followerId: followersId)
        return game
    }
    
    
}
