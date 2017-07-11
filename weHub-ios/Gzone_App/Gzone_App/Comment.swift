//
//  Comment.swift
//  Gzone_App
//
//  Created by Lyes Atek on 18/06/2017.
//  Copyright © 2017 Tracy Sablon. All rights reserved.
//

import Foundation
open class Comment : NSObject{
    var _id : String
    var userId : String
    var postId : String
    var text : String
    var video : String
    var datetimeCreated : Date
    
    
    
    init(_id : String,userId : String,postId : String,text : String,video : String, datetimeCreated : Date){
        self._id = _id
        self.userId = userId
        self.postId = postId
        self.text = text
        self.video = video
        self.datetimeCreated = datetimeCreated
    }
    
}
