//
//  ProfilUserViewController.swift
//  Gzone_App
//
//  Created by Lyes Atek on 05/07/2017.
//  Copyright © 2017 Tracy Sablon. All rights reserved.
//
import UIKit

class ProfilUserViewController : UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var reply: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var tableView: UITableView!
     @IBOutlet weak var avatar: UIImageView!
    var user : User?
    
    var posts : [Post] = []
    let cellIdentifier = "cell"
    var followers : [User] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getUsers()
        self.getPostByUserId()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.username.text = self.user?.username
        self.reply.text = self.user?.username
        self.avatar.image = self.imageFromUrl(url: (self.user?.avatar!)!)
       // self.follow.text = AuthenticationService.sharedInstance.followers.count.description
               
    }
    
    func imageFromUrl(url : String)->UIImage{
       
            let imageUrlString = url
            let imageUrl:URL = URL(string: imageUrlString)!
            let imageData:NSData = NSData(contentsOf: imageUrl)!
            return UIImage(data: imageData as Data)!
        
    
    }
    
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count;
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for:indexPath) as! ProfilUserTableViewCell
        
        let post = posts[indexPath.row]
        cell.username.text = post.author
        cell.reply.text = post.author
        cell.date.text = post.datetimeCreated
        cell.like.text = post.likes.count.description
        cell.textView.text = post.text
        cell.avatar.image =  self.imageFromUrl(url: (self.user?.avatar!)!)
        return cell
    }
    
    func refreshTableView(){
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    
    func getPostByUserId(){
       
        let postsWB : WBPost = WBPost()
        postsWB.getPostByUserId(userId: (user?._id)!,accessToken: AuthenticationService.sharedInstance.accessToken!,offset: "0" ){
            (result: [Post]) in
            self.posts = result
            self.refreshTableView()
        }
    }
   
    func getUsers()->Void{
        
        let userWB : WBUser = WBUser()
        userWB.getFollowedUser(accessToken: AuthenticationService.sharedInstance.accessToken!,  userId : AuthenticationService.sharedInstance.currentUser!._id,offset: "0") {
            (result: [User]) in
            self.followers = result
         
            
        }
    }
    
    
}

