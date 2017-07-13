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
    var cellIdentifier = "cell"
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
        
        cellIdentifier = "MyFeedsCustomCell"
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 500.0
        tableView.estimatedRowHeight = 800.0
        tableView.allowsSelection = false
        tableView.scrollsToTop = false
        tableView.register(UINib(nibName: "MyFeedsTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: cellIdentifier)
               
    }
    
    func showYoutubeModal(_ sender : UITapGestureRecognizer){
        
        print("Tap image : ", sender.view?.tag ?? "no media content")
        
        let mediaTag = sender.view?.tag
        let postVideo = posts[mediaTag!].video
        
        if (postVideo != "") {
            // Instantiate a modal view when content media is tapped
            let modalViewController = ModalViewController()
            modalViewController.videoURL = postVideo
            modalViewController.modalPresentationStyle = .popover
            present(modalViewController, animated: true, completion: nil)
        }
        
    }
    
    func imageFromUrl(url : String)->UIImage{
       
            let imageUrlString = url
            let imageUrl:URL = URL(string: imageUrlString)!
            let imageData:NSData = NSData(contentsOf: imageUrl)!
            return UIImage(data: imageData as Data)!
        
    
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return posts.count
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        // Force update of cell height when no media content
        let post = self.posts[indexPath.row]
        
        var postHeight = 300.0
        
        if(post.video != ""){
            postHeight += 150.0
        }
        if(post.mark != nil){
            postHeight += 50.0
        }
        
        return CGFloat(postHeight)
    }
    

     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for:indexPath) as! MyFeedsTableViewCell
        
        let post = self.posts[indexPath.row]
        
        //Initialize cell image to nil for fixing reuse cell issues
        cell.mediaImageView.image = nil
        
        cell.userNameLabel.text = post.author
        cell.userReplyLabel.text = "@" + post.author
        cell.postDescription.text = post.text
        cell.postDate.text = post.datetimeCreated.description
        
        if(post.flagOpinion){
            
            self.fillRates(rates: [cell.rate1,cell.rate2,cell.rate3,cell.rate4,cell.rate5], mark: post.mark!)
            self.ratesHidden( rates: [cell.rate1,cell.rate2,cell.rate3,cell.rate4,cell.rate5],isHidden: false)
            
        }else{
            
            self.ratesHidden( rates: [cell.rate1,cell.rate2,cell.rate3,cell.rate4,cell.rate5],isHidden: true)
        }
        

        if(post.video != ""){
            
            // Extract youtube ID from URL
            let mediaId = post.video.youtubeID!
            let mediaURL = "http://img.youtube.com/vi/"+mediaId+"/mqdefault.jpg"
            
            // Use of Utils extension for downloading youtube thumbnails
            let isSucessMediaDownload = cell.mediaImageView.imageFromYoutube(url: mediaURL)
            
            if isSucessMediaDownload {
                // On tap gesture display presentation view with media content
                cell.mediaImageView.isUserInteractionEnabled = true;
                cell.mediaImageView.tag = indexPath.row
                let tapGesture = UITapGestureRecognizer(target:self, action: #selector(self.showYoutubeModal(_:)))
                cell.mediaImageView.addGestureRecognizer(tapGesture)
            }else {
                
                cell.mediaImageView.isUserInteractionEnabled = false
            }
        }
        cell.numberComment.text = post.comments.count.description
        cell.numberLike.text = post.likes.count.description
        cell.commentAction = { (cell) in self.comment(post: post)}
        
        return cell
    }
    
    func comment(post : Post){
        print(post._id)
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Comment_ID") as! CommentViewController
        vc.post = post
        vc.note = post.mark
        vc.flagOpinion = post.flagOpinion
        self.navigationController?.pushViewController(vc, animated: true)
        
        
        
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
            self.posts.reverse()
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
    
    func fillRates(rates : [UIImageView],mark : Int){
        if(mark == 0)
        {
            return
        }
        for i in 0 ..< mark {
            
            rates[i].image = UIImage(named: "starFill.png")
            
        }
        
    }
    
    func ratesHidden(rates : [UIImageView],isHidden : Bool){
        for i in 0 ..< rates.count {
            rates[i].isHidden = isHidden
        }
    }
    
}

