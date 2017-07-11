//
//  Game.swift
//  Gzone_App
//
//  Created by Lyes Atek on 22/06/2017.
//  Copyright © 2017 Tracy Sablon. All rights reserved.
//

import Foundation
open class Game : NSObject{
    var _id : String
    var name : String
    var followerId : [String]
    var platforms : [String]
    var developer : String
    var editor : String
    var categories : [String]
    var synopsis : String
    var solo : Bool
    var multiplayer : Bool
    var cooperative : Bool
    var website : String
    var boxart : String
    var datetimeCreated : String
    
    
    init(_id : String,name : String, platforms : [String],developer : String,editor : String,categories : [String],synopsis : String,solo : Bool,multiplayer : Bool,cooperative : Bool,website : String,boxart : String,datetimeCreated : String,followerId : [String]){
        self._id = _id
        self.name = name
        self.platforms = platforms
        self.developer = developer
        self.editor = editor
        self.categories = categories
        self.synopsis = synopsis
        self.solo = solo
        self.multiplayer = multiplayer
        self.cooperative = cooperative
        self.website = website
        self.boxart = boxart
        self.datetimeCreated = datetimeCreated
        self.followerId = followerId
    }
    
}
