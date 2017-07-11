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
    var isPost : Bool = true
    var note : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated:true);
        self.getGames()
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.games.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! ListGameTableViewCell
        let game = self.games[indexPath.row]
        cell.gameName.text = game.name
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
        vc.typePost = 2
        vc.game = self.games[(self.tableView.indexPathForSelectedRow?.row)!]
        vc.isPost = self.isPost
        vc.note = self.note
        //   vc.textPost.text = "@" + self.games[(self.tableView.indexPathForSelectedRow?.row)!].name
        
    }
    func getGames()->Void{
        
        let gameWB : WBGame = WBGame()
        gameWB.getAllGames(accessToken: AuthenticationService.sharedInstance.accessToken!,offset: "0"){
            (result: [Game]) in
            self.games = result
            self.refreshTableView()
        }
    }
    
    /* func getUsers()->Void{
     
     let userWB : WBUser = WBUser()
     userWB.getFollowedUser(accessToken: AuthenticationService.sharedInstance.accessToken!,  userId : AuthenticationService.sharedInstance.currentUser!._id,offset: "0") {
     (result: [User]) in
     self.followers = result
     self.imageFromUrl(followers: self.followers)
     }
     }*/
    
    
    /* func imageFromUrl(followers : [User]){
     for follower in followers {
     let imageUrlString = follower.avatar
     let imageUrl:URL = URL(string: imageUrlString!)!
     let imageData:NSData = NSData(contentsOf: imageUrl)!
     self.avatars.append(UIImage(data: imageData as Data)!)
     }
     self.refreshTableView()
     }*/
    
    
    
}

