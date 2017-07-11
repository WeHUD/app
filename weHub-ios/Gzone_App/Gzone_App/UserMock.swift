//
//  User.swift
//  GZone
//
//  Created by Lyes Atek on 01/06/2017.
//  Copyright © 2017 Lyes Atek. All rights reserved.
//

import Foundation
open class UserMock : NSObject{
    
    var _id : String = ""
    var username : String
    
    
    init(id : String, username : String){
        self.username = username
        self._id = id
    
    }
}
