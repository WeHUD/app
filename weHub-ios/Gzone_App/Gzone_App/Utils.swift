//
//  Utils.swift
//  Gzone_App
//
//  Created by Tracy Sablon on 27/04/2017.
//  Copyright © 2017 Tracy Sablon. All rights reserved.
//

import Foundation
import UIKit

extension UIView {

    // Close the textField when tap outside
    func closeTextField() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false;
        self.addGestureRecognizer(tap);
    }
}

extension UIImageView {
    
    
    func imageFromYoutube(url: String) ->Bool{
        
        var isSuccess = true
        
        if NSURL(string: url) != nil {
            
            URLSession.shared.dataTask(with: NSURL(string: url)! as URL, completionHandler: { (data, response, error) -> Void in
                
                if error != nil {
                    
                    print("Error downloading Youtube thumbnail")
                    DispatchQueue.main.async(execute: { () -> Void in
                        
                        isSuccess = false
                    })
                    
                } else {
                    
                    if data != nil {
                        DispatchQueue.main.async(execute: { () -> Void in
                            
                            isSuccess = true
                            
                            let imageData = UIImage(data: data!)
                            self.image = imageData
                        })
                    }
                
                }
                
            }).resume()

        }else {
            
            isSuccess = false
        }
        
        return isSuccess
    }
    
    
    func imageFromUrl(url: String){
        let imageUrlString = url
        
        if NSURL(string: imageUrlString) != nil {
            
            let imageUrl:URL = URL(string: imageUrlString)!
            let imageData:NSData = NSData(contentsOf: imageUrl)!
            image = UIImage(data: imageData as Data)
            self.image = image!
        }
    }
}



extension String {
    
    // Getting ID from multiple source of youtube urls
    
    var youtubeID: String? {
        let rule = "((?<=(v|V)/)|(?<=be/)|(?<=(\\?|\\&)v=)|(?<=embed/))([\\w-]++)"
        
        let regex = try? NSRegularExpression(pattern: rule, options: .caseInsensitive)
        let range = NSRange(location: 0, length: self.characters.count)
        guard let checkingResult = regex?.firstMatch(in: self, options: [], range: range) else { return nil }
        
        return (self as NSString).substring(with: checkingResult.range)
    }
    
    
}
