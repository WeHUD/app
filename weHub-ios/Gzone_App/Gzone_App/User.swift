//
//  User.swift
//  GZone
//
//  Created by Lyes Atek on 01/06/2017.
//  Copyright © 2017 Lyes Atek. All rights reserved.
//

import Foundation
open class User : NSObject{
    
    
    var _id : String = ""
    var dateOfBirth : String
    var email : String
    var username : String
    var reply : String
    var password : String
    var avatar : String? = "https://s3.ca-central-1.amazonaws.com/g-zone/images/profile01.png"
    var datetimeRegister : String?
    var longitude : Double?
    var latitude : Double?
    var followedUsers : [String]?
    var followedGames : [String]?
    var score : Int?
    var connected : Bool?
    
    init(id : String,dateOfBirth : String,email : String,username : String,reply : String,password : String,avatar : String,datetimeRegister : String,longitude : Double,latitude : Double,followedUsers : [String],followedGames : [String],score : Int,connected : Bool){
        self.dateOfBirth = dateOfBirth
        self.email = email
        self.username = username
        self.password = password
        self.avatar = avatar
        self.datetimeRegister = datetimeRegister
        self._id = id
        self.reply = reply
        self.followedGames = followedGames
        self.followedUsers = followedUsers
        self.score = score
        self.connected = connected
        self.longitude = longitude
        self.latitude = latitude
        
    }
    override init(){
        self.dateOfBirth = " "
        self.email = " "
        self.username = " "
        self.reply = " "
        self.password = " "
        
    }
    
    
}
