//
//  Follower.swift
//  Gzone_App
//
//  Created by Lyes Atek on 18/06/2017.
//  Copyright © 2017 Tracy Sablon. All rights reserved.
//

import Foundation
open class Follower : NSObject{
    
    var userId : String
    var followerId : String
    
    init(userId : String,followerId : String){
        
        self.userId = userId
        self.followerId = followerId
    }
    
}
