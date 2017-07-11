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
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.getUsers()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.followers.count;
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! ContactTableViewCell
        
        let follower = followers[indexPath.row]
        cell.label.text = follower.username
        cell.usernamelbl.text = "@" + follower.username
        cell.contactAvatar.image = self.avatars[indexPath.row]
        cell.tapAction = { (cell) in self.unfollowAction(followerId: follower._id, row: tableView.indexPath(for: cell)!.row, indexPath: indexPath)
        }
        return cell
    }

 
   
    func unfollowAction(followerId : String, row : Int,indexPath : IndexPath){
        
        let followerWB  = WBFollower()
        followerWB.deleteFollowerUser(userId: AuthenticationService.sharedInstance.currentUser!._id, followerId: followerId,accessToken: AuthenticationService.sharedInstance.accessToken!){
            (result: Bool) in
            DispatchQueue.main.async(execute: {
                self.followers.remove(at: row)
                self.refreshTableView()
            })
            print(result)
        }
    }
    
    func refreshTableView(){
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let viewController = segue.destination as! ProfilUserViewController
        viewController.user = self.followers[(self.tableView.indexPathForSelectedRow?.row)!]

    }
    func getUsers()->Void{
        
        let userWB : WBUser = WBUser()
        userWB.getFollowedUser(accessToken: AuthenticationService.sharedInstance.accessToken!,  userId : AuthenticationService.sharedInstance.currentUser!._id,offset: "0") {
            (result: [User]) in
            self.followers = result
            self.imageFromUrl(followers: self.followers)
            
        }
    }
    
      func imageFromUrl(followers : [User]){
        for follower in followers {
            let imageUrlString = follower.avatar
            let imageUrl:URL = URL(string: imageUrlString!)!
            let imageData:NSData = NSData(contentsOf: imageUrl)!
            self.avatars.append(UIImage(data: imageData as Data)!)
        }
        self.refreshTableView()
    }
    
    
}
