//
//  ContactViewController.swift
//  Gzone_App
//
//  Created by Lyes Atek on 04/07/2017.
//  Copyright © 2017 Tracy Sablon. All rights reserved.
//

import UIKit

class ContactViewController : UIViewController, UITableViewDataSource,UITableViewDelegate{
    
    @IBOutlet var tableView: UITableView!
    
    var followers : [User] = []
    var avatars : [UIImage] = []
    let cellIdentifier = "FriendsSearchCustomCell"
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: "FriendsSearchTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: cellIdentifier)
        self.tableView.estimatedRowHeight = UITableViewAutomaticDimension
        self.tableView.rowHeight = 90.0
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.getUsers()
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "ProfilUser") as! ProfilUserViewController
        controller.user = self.followers[(self.tableView.indexPathForSelectedRow?.row)!]
        
        navigationController?.pushViewController(controller, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return self.followers.count;
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "FriendsSearchCustomCell") as! FriendsSearchTableViewCell
        
        let follower = followers[indexPath.row]
        
        
        cell.userNameLbl.text = follower.username
        cell.userReplyLbl.text = "@" + follower.username
        cell.userAvatarImageView.image = self.avatars[indexPath.row]
        cell.UnfollowAction = { (cell) in self.unfollowAction(followerId: follower._id, row: tableView.indexPath(for: cell)!.row, indexPath: indexPath)}
      //  cell.followBtn = { (cell) in self.unfollowAction(followerId: follower._id, row: tableView.indexPath(for: cell)!.row, indexPath: indexPath)

        
        return cell
    }

    func unfollowAction(followerId : String, row : Int,indexPath : IndexPath){
        
        let followerWB  = WBFollower()
        followerWB.deleteFollowerUser(userId: AuthenticationService.sharedInstance.currentUser!._id, followerId: followerId,accessToken: AuthenticationService.sharedInstance.accessToken!){
            (result: Bool) in
            DispatchQueue.main.async(execute: {
                self.getUsers()
                           })
            print(result)
        }
    }
    
    func refreshTableView(){
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    
    
    func getUsers()->Void{
        
        let userWB : WBUser = WBUser()
        
        userWB.getFollowedUser(accessToken: AuthenticationService.sharedInstance.accessToken!,  userId : AuthenticationService.sharedInstance.currentUser!._id,offset: "0") {
            (result: [User]) in
            
            self.followers = result
            self.imageFromUrl(followers: self.followers)
            self.refreshTableView()

            
        }
    }
    
    func imageFromUrl(followers : [User]){
        self.avatars.removeAll()
        for follower in followers {
            let imageUrlString = follower.avatar
            let imageUrl:URL = URL(string: imageUrlString!)!
            let imageData:NSData = NSData(contentsOf: imageUrl)!
            self.avatars.append(UIImage(data: imageData as Data)!)
        }

    }
 
}
