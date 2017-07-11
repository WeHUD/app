//
//  Post.swift
//  Gzone_App
//
//  Created by Lyes Atek on 18/06/2017.
//  Copyright © 2017 Tracy Sablon. All rights reserved.
//

import Foundation
open class Post : NSObject{
    var _id : String
    var userId : String
    var gameId : String
    var text : String
    var likes : [String]
    var comments : [String]
    var flagOpinion : Bool
    var video : String
    var datetimeCreated : String
    var author : String
    var mark : Int?
    
    init(_id : String,userId : String,gameId : String,text : String, likes : [String], comments : [String],flagOpinion : Bool,video : String, datetimeCreated : String,author : String,mark : Int?){
        self._id = _id
        self.userId = userId
        self.gameId = gameId
        self.text = text
        self.likes = likes
        self.comments = comments
        self.flagOpinion = flagOpinion
        self.video = video
        self.datetimeCreated = datetimeCreated
        self.author = author
        self.mark = mark
    }
    
    
}
