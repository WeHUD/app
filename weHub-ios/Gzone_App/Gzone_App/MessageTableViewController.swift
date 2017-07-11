//
//  MessageTableViewController.swift
//  Gzone_App
//
//  Created by Lyes Atek on 08/07/2017.
//  Copyright © 2017 Tracy Sablon. All rights reserved.
//

import UIKit

class MessageTableViewController : UIViewController, UITableViewDataSource,UITableViewDelegate{
    
    @IBOutlet var tableView: UITableView!
    
    var posts : [Post] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.getPost()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! MessageTableViewCell
        
        let post = self.posts[indexPath.row]
        cell.username.text = post.author
        cell.reply.text = "@"+post.author
        cell.date.text = post.datetimeCreated.description
        cell.textContent.text = post.text
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
      //  let viewController = segue.destination as! ProfilUserViewController
      //  viewController.user = self.posts[(self.tableView.indexPathForSelectedRow?.row)!]
        
    }
    func getPost()->Void{
        
        let postWB : WBPost = WBPost()
        postWB.getPostByUserId(userId: AuthenticationService.sharedInstance.currentUser!._id, accessToken: AuthenticationService.sharedInstance.accessToken!, offset: "0"){
            (result: [Post]) in
            self.posts = result
            self.refreshTableView()
        }
    }
    
    
}

