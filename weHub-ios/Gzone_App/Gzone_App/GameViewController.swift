//
//  GameViewController.swift
//  Gzone_App
//
//  Created by Lyes Atek on 11/07/2017.
//  Copyright © 2017 Tracy Sablon. All rights reserved.
//

import UIKit

class GameViewController : UIViewController{
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var gameName: UILabel!
    @IBOutlet weak var developper: UILabel!
    @IBOutlet weak var editor: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var synopsis: UITextView!
    @IBOutlet weak var soloImage: UIImageView!
    @IBOutlet weak var solo: UILabel!
    @IBOutlet weak var cooperationImage: UIImageView!
    @IBOutlet weak var cooperation: UILabel!
    @IBOutlet weak var multiAction: UIImageView!
    @IBOutlet weak var multi: UILabel!
    
    var game : Game?
    
      override func viewDidLoad() {
        super.viewDidLoad()
       self.initializeElements()
    }
    func initializeElements(){
        self.gameName.text = self.game?.name
        self.developper.text = self.game?.developer
        self.editor.text = self.game?.editor
        self.date.text = self.game?.datetimeCreated
        self.synopsis.text = self.game?.synopsis
        if(self.game?.solo)!{
            self.soloImage.isHidden = false
        }else{
            self.soloImage.isHidden = true
            self.solo.isHidden = true
        }
        if(self.game?.cooperative)!{
            self.cooperationImage.isHidden = false
        }else{
            self.cooperationImage.isHidden = true
            self.cooperation.isHidden = true
        }
        if(self.game?.multiplayer)!{
            self.multiAction.isHidden = false
        }else{
            self.multiAction.isHidden = true
            self.multi.isHidden = true
        }
    }
       func imageFromUrl(url : String)->UIImage{
        print(url)
        let imageUrlString = url
        let imageUrl:URL = URL(string: imageUrlString)!
        let imageData:NSData = NSData(contentsOf: imageUrl)!
        return UIImage(data: imageData as Data)!
        
        
    }
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
