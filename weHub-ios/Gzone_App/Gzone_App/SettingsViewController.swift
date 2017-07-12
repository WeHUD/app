//
//  SettingsViewController.swift
//  Gzone_App
//
//  Created by Lyes Atek on 05/07/2017.
//  Copyright © 2017 Tracy Sablon. All rights reserved.
//

import UIKit

class SettingsViewController : UIViewController{
    
    
    @IBOutlet weak var username: UILabel!
    
    @IBOutlet weak var reply: UILabel!
    
    @IBOutlet weak var numberOfFollower: UILabel!
    
    @IBOutlet weak var usernameTxtFld: UITextField!
    
    @IBOutlet weak var replyTxtFld: UITextField!
    
    @IBOutlet weak var validBtn: UIButton!
    @IBOutlet weak var mailTxtFld: UITextField!
    @IBOutlet weak var avatarUser: UIImageView!
    @IBOutlet weak var avatar1: UIButton!
    @IBOutlet weak var avatar4: UIButton!
    @IBOutlet weak var avatar3: UIButton!
    @IBOutlet weak var avatar2: UIButton!
    
    @IBOutlet weak var loaderAvatar: UIActivityIndicatorView!
    
    
    var indexAvatar : Int?
    var connectedUser : User?
    var followers : [User] = []
    var avatars : [String] = [ "https://s3.ca-central-1.amazonaws.com/g-zone/images/profile01.png", "https://s3.ca-central-1.amazonaws.com/g-zone/images/profile02.png", "https://s3.ca-central-1.amazonaws.com/g-zone/images/profile03.png", "https://s3.ca-central-1.amazonaws.com/g-zone/images/profile04.png"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connectedUser = AuthenticationService.sharedInstance.currentUser!
        self.getUsers()
        loaderAvatar.isHidden  = false
        loaderAvatar.startAnimating()
    }
    
    
    func initializeAvatars(){
        
        var img1 : UIImage?
        var img2 : UIImage?
        var img3 : UIImage?
        var img4 : UIImage?
        
        
        img1 = imageFromUrl(url: "https://s3.ca-central-1.amazonaws.com/g-zone/images/profile01.png")
        img2 = imageFromUrl(url: "https://s3.ca-central-1.amazonaws.com/g-zone/images/profile02.png")
        img3 = imageFromUrl(url: "https://s3.ca-central-1.amazonaws.com/g-zone/images/profile03.png")
        img4 = imageFromUrl(url: "https://s3.ca-central-1.amazonaws.com/g-zone/images/profile04.png")
        
        if img1 != nil {
            self.avatar1.setImage(img1, for: .normal)
        }
        if img2 != nil {
            self.avatar2.setImage(img2, for: .normal)
        }
        if img3 != nil {
            self.avatar3.setImage(img3, for: .normal)
        }
        if img4 != nil {
            self.avatar4.setImage(img4, for: .normal)
        }
    }
    
    func imageFromUrl(url : String)->UIImage{
        print(url)
        let imageUrlString = url
        let imageUrl:URL = URL(string: imageUrlString)!
        let imageData:NSData = NSData(contentsOf: imageUrl)!
        
        var imageLoaded  = UIImage(data: imageData as Data)
        
        if imageLoaded == nil {
             imageLoaded = UIImage(named: "userDefault")
        }
        else {
            loaderAvatar.stopAnimating()
            loaderAvatar.isHidden  = true
        }
        return imageLoaded!
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func avatar1Click(_ sender: Any) {
        self.avatarUser.image = self.avatar1.image(for: .normal)
        self.indexAvatar = 0
    }
    
    
    @IBAction func avatar2Click(_ sender: Any) {
        self.avatarUser.image = self.avatar2.image(for: .normal)
        self.indexAvatar = 1
    }
   
    @IBAction func avatar3Click(_ sender: Any) {
        self.avatarUser.image = self.avatar3.image(for: .normal)
        self.indexAvatar = 2
    }

    @IBAction func avatar4Click(_ sender: Any) {
        self.avatarUser.image = self.avatar4.image(for: .normal)
        self.indexAvatar = 3
    }
    
    @IBAction func editUser(_ sender: Any) {
        updateUser()
        
    }
    
    func updateUser(){
      
        let user : User = User(id: (connectedUser?._id)!, dateOfBirth: (connectedUser?.dateOfBirth)!, email: mailTxtFld.text!, username: usernameTxtFld.text!, reply: replyTxtFld.text!, password: (connectedUser?.password)!, avatar: avatars[indexAvatar!], datetimeRegister: (connectedUser?.datetimeRegister)!, longitude: (connectedUser?.longitude)!, latitude: (connectedUser?.latitude)!, followedUsers: (connectedUser?.followedUsers)!, followedGames: (connectedUser?.followedGames)!, score: (connectedUser?.score)!, connected: (connectedUser?.connected)!)
        let userWB : WBUser = WBUser()
        userWB.updateUser(user: user, accessToken: AuthenticationService.sharedInstance.accessToken!){
            (result: Bool) in
            AuthenticationService.sharedInstance.currentUser! = user
            print(result)
            
            DispatchQueue.main.async {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    func searchAvatar()->Int{
        for i in 0 ..< avatars.count {
            if(avatars[i] == (connectedUser?.avatar)!){
                return i
            }
        }
        return 0
    }

    func getUsers()->Void{
        
        let userWB : WBUser = WBUser()
        userWB.getFollowedUser(accessToken: AuthenticationService.sharedInstance.accessToken!,  userId : AuthenticationService.sharedInstance.currentUser!._id,offset: "0") {
            (result: [User]) in
            self.followers = result
            
            DispatchQueue.main.async {
                self.username.text = self.connectedUser?.username
                self.reply.text = "@" + (self.connectedUser?.username)!
                self.avatarUser.image = self.imageFromUrl(url: (self.connectedUser?.avatar)!)
                self.usernameTxtFld.text = self.connectedUser?.username
                self.mailTxtFld.text = self.connectedUser?.email
                self.replyTxtFld.text = self.connectedUser?.reply
                self.indexAvatar = self.searchAvatar()
               self.numberOfFollower.text = self.followers.count.description
                
            }
            
        }
    }

       
}
