//
//  ListGameViewController.swift
//  Gzone_App
//
//  Created by Lyes Atek on 09/07/2017.
//  Copyright © 2017 Tracy Sablon. All rights reserved.
//

import UIKit

class ListUserViewController : UIViewController, UITableViewDataSource,UITableViewDelegate{
    
    @IBOutlet var tableView: UITableView!
    
    var users : [User] = []
    var avatars: [UIImage] = []
    var isPost : Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated:true);
        self.getUsers()
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! ListUserTableViewCell
        let user = self.users[indexPath.row]
        cell.username.text = user.username
        cell.avatar.image = self.avatars[indexPath.row]
        return cell
    }
    
    
    func refreshTableView(){
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let vc = segue.destination as! CreatePostViewController
        vc.typePost = 3
        vc.user = self.users[(self.tableView.indexPathForSelectedRow?.row)!]
        vc.isPost = self.isPost
     //   vc.textPost.text = "@" + self.users[(self.tableView.indexPathForSelectedRow?.row)!].username
    }
    
    func getUsers()->Void{
        
        let userWB : WBUser = WBUser()
        userWB.getFollowedUser(accessToken: AuthenticationService.sharedInstance.accessToken!,  userId : AuthenticationService.sharedInstance.currentUser!._id,offset: "0") {
            (result: [User]) in
            self.users = result
            self.imageFromUrl(followers: self.users)
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

