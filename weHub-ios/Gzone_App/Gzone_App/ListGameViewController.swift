//
//  ListGameViewController.swift
//  Gzone_App
//
//  Created by Lyes Atek on 09/07/2017.
//  Copyright © 2017 Tracy Sablon. All rights reserved.
//

import UIKit

class ListGameViewController : UIViewController, UITableViewDataSource,UITableViewDelegate{
    
    @IBOutlet var tableView: UITableView!
    
    var games : [Game] = []
    var followers :[User] = []
    var isListGame : Bool = false
    var avatars : [UIImage] = []
    var isPost : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated:true);
        self.tableView.delegate = self
        self.tableView.dataSource = self
        if(isListGame){
            self.getGames()
        }else{
            self.getUsers()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(self.isListGame){
            return self.games.count
        }else{
            return self.followers.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(isListGame){
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "listGame") as! ListGameTableViewCell
            
            let game = self.games[indexPath.row]
            cell.gameName.text = game.name
            return cell
        }else{
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "listFollower") as! ListUserTableViewCell
            let follower = self.followers[indexPath.row]
            cell.username.text = follower.username
            cell.avatar.image = self.avatars[indexPath.row]
            return cell
        
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
        let vc = segue.destination as! CreatePostViewController
       // viewController.user = self.games[(self.tableView.indexPathForSelectedRow?.row)!]
        let row = self.tableView.indexPathForSelectedRow?.row
        if(self.isListGame){
            vc.game = self.games[row!]
            vc.user = nil
        }else{
            vc.user = self.followers[row!]
            vc.game = nil
        }
        vc.isPost = self.isPost
        
    }
    func getGames()->Void{
        
        let gameWB : WBGame = WBGame()
        gameWB.getAllGames(accessToken: AuthenticationService.sharedInstance.accessToken!,offset: "0"){
            (result: [Game]) in
            self.games = result
            self.refreshTableView()
        }
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

