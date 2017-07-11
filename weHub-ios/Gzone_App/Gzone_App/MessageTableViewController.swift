//
//  MessageTableViewController.swift
//  Gzone_App
//
//  Created by Lyes Atek on 08/07/2017.
//  Copyright © 2017 Tracy Sablon. All rights reserved.
//

import UIKit

class MessageTableViewController : UIViewController, UITableViewDataSource,UITableViewDelegate{
    
    @IBOutlet weak var typePostSegmentControl: UISegmentedControl!
    @IBOutlet var tableView: UITableView!
    
    var posts : [Post] = []
    var postsGames : [Post] = []
    var postsVideo : [Post] = []
    var postsReceived : [Post] = []
    
    
    var refreshControl = UIRefreshControl()
    var dateFormatter = DateFormatter()
    var last_index = 0
    var update : Bool = true
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dateFormatter.dateStyle = DateFormatter.Style.short
        self.dateFormatter.timeStyle = DateFormatter.Style.long
        
        refreshControl.backgroundColor = UIColor.clear
        refreshControl.tintColor = UIColor.black
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        
        refreshControl.addTarget(self, action: Selector(("PullRefresh")), for: UIControlEvents.valueChanged)
        
        self.tableView.addSubview(refreshControl)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.getPosts()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.typePostSegmentControl.selectedSegmentIndex {
        case 0:
            return self.posts.count
        case 1:
            return self.postsGames.count
        case 2:
            return self.postsVideo.count
        case 3:
            return self.postsReceived.count
        default:
            return self.postsReceived.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let post : Post
        switch self.typePostSegmentControl.selectedSegmentIndex {
            
        case 0:
            post = self.posts[indexPath.row]
            
        case 1:
            post = self.postsGames[indexPath.row]
            
        case 2:
            post = self.postsVideo[indexPath.row]
            
            
        case 3:
            post = self.postsReceived[indexPath.row]
            
            
        default:
            post = self.posts[indexPath.row]
        }
        
        if(self.typePostSegmentControl.selectedSegmentIndex == 2){
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "cellVideo") as! MessageVideoTableViewCell
            cell.username.text = post.author
            cell.reply.text = "@"+post.author
            cell.date.text = post.datetimeCreated.description
            cell.textContent.text = post.text
            if(post.video != ""){
                
                // Extract youtube ID from URL
                let mediaId = post.video.youtubeID!
                let mediaURL = "http://img.youtube.com/vi/"+mediaId+"/mqdefault.jpg"
                
                //Use of extension for downloading youtube thumbnails
                cell.mediaImage.imageFromYoutube(url: mediaURL)
                
                
                //On tap gesture display presentation view with media content
                cell.mediaImage.isUserInteractionEnabled = true;
                cell.mediaImage.tag = indexPath.row
                let tapGesture = UITapGestureRecognizer(target:self, action: #selector(self.showYoutubeModal(_:)))
                cell.mediaImage.addGestureRecognizer(tapGesture)
                
            }else{
                
                cell.mediaImage.isUserInteractionEnabled = false
            }
            return cell
            
        }else{
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! MessageTableViewCell
            cell.username.text = post.author
            cell.reply.text = "@"+post.author
            cell.date.text = post.datetimeCreated.description
            cell.textContent.text = post.text
            return cell
        }
        
        
        
    }
    
    func showYoutubeModal(_ sender : UITapGestureRecognizer){
        
        print("Tap image : ", sender.view?.tag ?? "no media content")
        
        let mediaTag = sender.view?.tag
        
        
        if let postVideo = self.postsVideo[mediaTag!].video as? String {
            
            // Instantiate a modal view when content media view is tapped
            let modalViewController = ModalViewController()
            modalViewController.videoURL = postVideo
            modalViewController.modalPresentationStyle = .popover
            present(modalViewController, animated: true, completion: nil)
        }
        
        
        
    }
    
    
    
    func PullRefresh()
    {
        if(update){
            last_index += 1
            self.getPosts()
        }else{
            let updateString = "Il n'y a pas de nouveaux post"
            
            self.refreshControl.attributedTitle = NSAttributedString(string: updateString)
            
            if self.refreshControl.isRefreshing
            {
                self.refreshControl.endRefreshing()
            }
            
            
        }
    }
    
    
    
    func refreshTableView(){
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    @IBAction func indexChanged(_ sender: Any) {
        self.refreshTableView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        //  let viewController = segue.destination as! ProfilUserViewController
        //  viewController.user = self.posts[(self.tableView.indexPathForSelectedRow?.row)!]
        
    }
    func getPostReceiver()->Void{
        
        let postWB : WBPost = WBPost()
        postWB.getPostByReceiverId(receiverId: AuthenticationService.sharedInstance.currentUser!._id, accessToken: AuthenticationService.sharedInstance.accessToken!){
            (result: [Post]) in
            self.postsReceived = result
            self.postsReceived.reverse()
            self.refreshTableView()
        }
    }
    
    func getPosts()->Void{
        
        let postWB : WBPost = WBPost()
        postWB.getPostByUserId(userId: AuthenticationService.sharedInstance.currentUser!._id, accessToken: AuthenticationService.sharedInstance.accessToken!, offset: last_index.description){
            (result: [Post]) in
            if(self.last_index == 0){
                self.posts = result
                self.posts.reverse()
            }else{
                if(result.count == 0){
                    self.update = false
                }else{
                    self.posts.append(contentsOf: result)
                    self.posts.reverse()
                }
            }
            self.getPostGames()
            self.getPostVideo()
            self.getPostReceiver()
            let now = Date()
            
            let updateString = "Last Updated at " + self.dateFormatter.string(from: now)
            
            self.refreshControl.attributedTitle = NSAttributedString(string: updateString)
            
            if self.refreshControl.isRefreshing
            {
                self.refreshControl.endRefreshing()
            }
            
            self.refreshTableView()
        }
        
    }
    
    func getPostGames()->Void{
        for post in self.posts{
            if(post.gameId != ""){
                self.postsGames.append(post)
            }
        }
        self.postsGames.reverse()
    }
    
    func getPostVideo()->Void{
        for post in self.posts{
            if(post.video != ""){
                self.postsVideo.append(post)
            }
        }
        self.postsVideo.reverse()
    }
    
    
    
    
}

