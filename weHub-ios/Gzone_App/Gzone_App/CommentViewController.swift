//
//  CommentViewController.swift
//  Gzone_App
//
//  Created by Lyes Atek on 10/07/2017.
//  Copyright © 2017 Tracy Sablon. All rights reserved.
//

import UIKit

class CommentViewController : UIViewController, UITableViewDataSource,UITableViewDelegate,UITextViewDelegate{
    
    @IBOutlet weak var avatarUser: UIImageView!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var viewComment: UIView!
    
    @IBOutlet weak var username: UILabel!
    
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var reply: UILabel!
    @IBOutlet weak var rate1: UIImageView!
    @IBOutlet weak var rate2: UIImageView!
    @IBOutlet weak var rate3: UIImageView!
    @IBOutlet weak var rate4: UIImageView!
    @IBOutlet weak var rate5: UIImageView!
    
    @IBOutlet weak var textPost: UITextView!
    
    @IBOutlet weak var mediaImage: UIImageView!
    
    @IBOutlet weak var userComment: UITextView!
    
    
    @IBOutlet var tableView: UITableView!
    
    var rates :[UIImageView] = []
    var comments : [Comment] = []
    var users : [User] = []
    var avatars : [UIImage] = []
    var user : User?
    var post : Post?
    var flagOpinion : Bool?
    var note : Int?
    var placeHolderUserComment : String = "Ajouter un commentaire"
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createPlaceHolder()
        self.getUserById(id: (post?._id)!)
        self.getCommentByPostId()
        self.initializeRates()
        initializeRatting(note: self.note!)
        self.userComment.delegate = self
        self.navigationItem.setHidesBackButton(true, animated:true);
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    //Function for placeHolder
    func createPlaceHolder(){
        self.userComment.text = "Ajouter un commentaire"
        self.userComment.textColor = UIColor.lightGray

    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            self.createPlaceHolder()
        }
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if self.userComment.textColor == UIColor.lightGray {
            self.userComment.text = nil
            self.userComment.textColor = UIColor.black
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! CommentTableViewCell
        let comment = self.comments[indexPath.row]
        cell.textComment.text = comment.text
        cell.date.text = comment.datetimeCreated.description
        if(self.avatars.count > indexPath.row && self.users.count > indexPath.row){
            cell.avatar.image = self.avatars[indexPath.row]
            cell.username.text = self.users[indexPath.row].username
            cell.reply.text = self.users[indexPath.row].reply


        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func refreshTableView(){
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    
    func hiddenRates(){
        
        for i in 0 ..< (self.rates.count ) {
            self.rates[i].isHidden = true
            
        }
        
    }
    func initializeElements(){
        self.avatar.imageFromUrl(url: (self.user?.avatar)!)
        self.username.text = self.user?.username
        self.reply.text = self.user?.reply
        self.date.text = post?.datetimeCreated
        self.textPost.text = post?.text
        if(self.flagOpinion)!{
            self.initializeRatting(note: (post?.mark!)!)
        }else{
            self.hiddenRates()
        }
        if(post?.video != ""){
            
            // Extract youtube ID from URL
            let mediaId = post?.video.youtubeID!
            let mediaURL = "http://img.youtube.com/vi/"+mediaId!+"/mqdefault.jpg"
            
            //Use of extension for downloading youtube thumbnails
            self.mediaImage.imageFromYoutube(url: mediaURL)
            
            
            //On tap gesture display presentation view with media content
            self.mediaImage.isUserInteractionEnabled = true;
            //self.mediaImage.tag = indexPath.row
            let tapGesture = UITapGestureRecognizer(target:self, action: #selector(self.showYoutubeModal(_:)))
            self.mediaImage.addGestureRecognizer(tapGesture)
            
        }else{
            
            self.mediaImage.isUserInteractionEnabled = false
        }
        self.avatarUser.imageFromUrl(url: (self.user?.avatar)!)
    }
    
    func initializeRates(){
        rates.append(self.rate1)
        rates.append(rate2)
        rates.append(rate3)
        rates.append(rate4)
        rates.append(rate5)
    }
    
    func getCommentByPostId()->Void{
     
     let commentWB : WBComment = WBComment()
     commentWB.getCommentByPostId(postId: (post?._id)!, accessToken: AuthenticationService.sharedInstance.accessToken!, offset: "0") {
     (result: [Comment]) in
        self.comments = result
        self.refreshTableView()
        self.getUsersComment()
        }
     }
    
    func initializeRatting(note : Int){
        if(note == 0){
            return
        }
      
        for i in 0 ..< (note ) {
            self.rates[i].image = UIImage(named: "selectedStarIcon.png")
            
        }
    }
    
    func getUsersComment(){
        if((post?.comments.count)! > 0){
            var index : Int = 0
            for _ in (post?.comments)!{
               let userComment = User()
                getUser(id: self.comments[index].userId, user : userComment)
                index += 1
                
            }
        }


    }
    func getUser(id : String,user:User){
        let userWB : WBUser = WBUser()
        userWB.getUser(userId: id, accessToken: AuthenticationService.sharedInstance.accessToken!){
            (result: User) in
            self.users.append(result)
            self.imageFromUrl(url: result.avatar!)
            self.refreshTableView()
        }
    }

    func getUserById(id : String){
        let userWB : WBUser = WBUser()
        userWB.getUser(userId: (post?.userId)!, accessToken: AuthenticationService.sharedInstance.accessToken!){
            (result: User) in
            DispatchQueue.main.async {
                self.user = result
                self.initializeElements()
            }
            
        }
    }
    @IBAction func sendComment(_ sender: Any) {
        if(self.userComment.text == self.placeHolderUserComment && self.userComment.textColor == UIColor.lightGray){
            emptyFields(title: "Comments", message: "Your messsage field is empty")
        }else{
            let commentWB : WBComment = WBComment()
            commentWB.addComment(userId: (AuthenticationService.sharedInstance.currentUser?._id)!, postId: (post?._id)!, text: self.userComment.text, accessToken: AuthenticationService.sharedInstance.accessToken!){
                (result: Bool) in
                DispatchQueue.main.async {
                    let storyboard = UIStoryboard(name: "Home", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "Home_ID") as! UITabBarController
                    self.present(vc, animated: true, completion: nil)

                }
                
            }
            
        }

    }
    
    func showYoutubeModal(_ sender : UITapGestureRecognizer){
        
        print("Tap image : ", sender.view?.tag ?? "no media content")
        
        
        
        
        if let postVideo = post?.video {
            
            // Instantiate a modal view when content media view is tapped
            let modalViewController = ModalViewController()
            modalViewController.videoURL = postVideo
            modalViewController.modalPresentationStyle = .popover
            present(modalViewController, animated: true, completion: nil)
        }
        
        
        
    }
    

    
    func imageFromUrl(url : String) {
        let imageUrlString = url
        let imageUrl:URL = URL(string: imageUrlString)!
        let imageData:NSData = NSData(contentsOf: imageUrl)!
        self.avatars.append(UIImage(data: imageData as Data)!)
  
    }
    
    @IBAction func cancelBtn(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Home_ID") as! UITabBarController
        self.present(vc, animated: true, completion: nil)
    }
    
}

