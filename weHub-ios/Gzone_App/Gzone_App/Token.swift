//
//  Token.swift
//  Gzone_App
//
//  Created by Lyes Atek on 08/07/2017.
//  Copyright © 2017 Tracy Sablon. All rights reserved.
//

import Foundation
open class Token : NSObject{
    var accessToken : String
    var expire : Int
    
    
    init(accessToken : String,expire : Int){
        self.accessToken = accessToken
        self.expire = expire
    }
    
    override init(){
        self.accessToken = ""
        self.expire = 0
    }
    
}

