//
//  CreatePostViewController.swift
//  Gzone_App
//
//  Created by Lyes Atek on 06/07/2017.
//  Copyright © 2017 Tracy Sablon. All rights reserved.
//

import UIKit

class CreatePostViewController : UIViewController,UITextViewDelegate{
    @IBOutlet weak var rateLbl: UILabel!
    
    @IBOutlet weak var rate1: UIButton!
    
    @IBOutlet weak var rate2: UIButton!
    @IBOutlet weak var rate3: UIButton!
    
    @IBOutlet weak var rate4: UIButton!
    
    @IBOutlet weak var rate5: UIButton!
    
    
    @IBOutlet weak var videoBtn: UIButton!
    @IBOutlet weak var gameBtn: UIButton!
    @IBOutlet weak var userBtn: UIButton!
    
    @IBOutlet weak var url: UITextField!
    
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var viewSegmentControl: UISegmentedControl!
    
    @IBOutlet weak var textPost: UITextView!
    
    var placeHolderUserComment : String = "Ajouter un commentaire"
    var isGame : Bool = false
    var rates : [UIButton] = []
    var note : Int = 0
    var user : User?
    var game : Game?
    var typePost : Int = 0
    var isPost : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeViewSegmentControl(isPost: isPost)
        
        self.initializeRates()
        self.initializeRatting(note: note)
        self.displayPostView(display: isPost)
        self.selectTypePost(typePost: typePost)
        self.view.closeTextField()
    }
    
    func initializeRatting(note : Int){
        if(note == 0){
            return
        }
        for i in 0 ..< (note) {
            self.rates[i].setImage(UIImage(named: "starFill.png"), for: .normal)
            
        }
    }
    
    func initializeViewSegmentControl(isPost : Bool){
        if(isPost){
            self.viewSegmentControl.selectedSegmentIndex = 0
        }else{
            self.viewSegmentControl.selectedSegmentIndex = 1
        }
    }
    
    func selectTypePost(typePost : Int){
        switch typePost {
        case 0:
            self.videoBtn.isSelected = false
            self.gameBtn.isSelected = false
            self.userBtn.isSelected = false
        case 1:
            self.videoBtn.isSelected = true
            self.gameBtn.isSelected = false
            self.userBtn.isSelected = false
        case 2:
            self.videoBtn.isSelected = false
            self.gameBtn.isSelected = true
            self.userBtn.isSelected = false
        case 3:
            self.videoBtn.isSelected = false
            self.gameBtn.isSelected = false
            self.userBtn.isSelected = true
        default:
            break
        }
    }
    func initializeRates(){
        rates.append(rate1)
        rates.append(rate2)
        rates.append(rate3)
        rates.append(rate4)
        rates.append(rate5)
    }
    
    func setImageRates(){
        for i in 0 ..< self.rates.count {
            
            self.rates[i].setImage(UIImage(named: "star.png"), for: .normal)
            
        }
        
    }
    //Function for placeHolder
    func createPlaceHolder(){
        self.textPost.text = "Aujouter un commentaire"
        self.textPost.textColor = UIColor.lightGray
        
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            self.createPlaceHolder()
        }
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if self.textPost.textColor == UIColor.lightGray {
            self.textPost.text = nil
            self.textPost.textColor = UIColor.black
        }
    }
    
    @IBAction func rattingAction(_ sender: UIButton) {
        setImageRates()
        for i in 0 ..< self.rates.count {
            
            if(sender != self.rates[i]){
                self.rates[i].setImage(UIImage(named: "starFill.png"), for: .normal)
                
            }else if(sender == self.rates[i]){
                self.rates[i].setImage(UIImage(named: "starFill.png"), for: .normal)
                self.note = i + 1
                return
            }
            
        }
    }
    @IBAction func indexChanged(_ sender: Any) {
        if(self.viewSegmentControl.selectedSegmentIndex == 0){
            self.displayPostView(display: true)
        }else{
            self.displayPostView(display: false)
        }
    }
    
    func displayPostView(display : Bool){
        self.rate1.isHidden = display
        self.rate2.isHidden = display
        self.rate3.isHidden = display
        self.rate4.isHidden = display
        self.rate5.isHidden = display
        self.rateLbl.isHidden = display
        self.url.isHidden = !display
        self.videoBtn.isHidden = !display
        self.userBtn.isHidden = !display
        self.textPost.text = ""
        self.isPost = display
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if(segue.identifier == "ListGame"){
            let viewController = segue.destination as! ListGameViewController
            if(self.viewSegmentControl.selectedSegmentIndex == 0){
                viewController.isPost = true
            }else{
                viewController.isPost = false
            }
            viewController.note = self.note
        }else{
            let viewController = segue.destination as! ListUserViewController
            if(self.viewSegmentControl.selectedSegmentIndex == 0){
                viewController.isPost = true
            }else{
                viewController.isPost = false
            }
            
        }
    }
    
    
    //Button Action
    
    
    @IBAction func VideoBtnClick(_ sender: Any) {
        self.url.isHidden = false
        self.typePost = 1
        self.selectTypePost(typePost: typePost)
    }
    
    
    
    
    
    
    
    func sendPostGame(){
        
        let postsWB : WBPost = WBPost()
        postsWB.addPostGame(userId: AuthenticationService.sharedInstance.currentUser!._id, text: self.textPost.text, author: AuthenticationService.sharedInstance.currentUser!.username, gameId: (self.game?._id)!, accessToken: AuthenticationService.sharedInstance.accessToken!){
            (result: Bool) in
            if(result){
                print(result)
            }
        }
    }
    
    func sendPost(){
        
        let postsWB : WBPost = WBPost()
        if(self.url.text == ""){
            postsWB.addPost(userId: AuthenticationService.sharedInstance.currentUser!._id, text: self.textPost.text, author: AuthenticationService.sharedInstance.currentUser!.username,accessToken: AuthenticationService.sharedInstance.accessToken!){
                (result: Bool) in
                print(result)
            }
        }else {
            postsWB.addPostVideo(userId: AuthenticationService.sharedInstance.currentUser!._id, text: self.textPost.text, author: AuthenticationService.sharedInstance.currentUser!.username, accessToken: AuthenticationService.sharedInstance.accessToken!, video: self.url.text!){
                (result: Bool) in
                print(result)
            }
            
        }
    }
    
    func sendPostUser(){
        let postsWB : WBPost = WBPost()
        postsWB.addPostUser(userId: AuthenticationService.sharedInstance.currentUser!._id, text: self.textPost.text, author: AuthenticationService.sharedInstance.currentUser!.username, receiverId:(self.user?._id)!, accessToken: AuthenticationService.sharedInstance.accessToken!){
            (result: Bool) in
            print(result)
        }
    }
    
    func sendOpinion(){
        let postsWB : WBPost = WBPost()
        postsWB.addPostOpinion(userId: AuthenticationService.sharedInstance.currentUser!._id, text: self.textPost.text, gameId: (self.game?._id)!, author: AuthenticationService.sharedInstance.currentUser!.username, mark: self.note.description, flagOpinion: "true", accessToken: AuthenticationService.sharedInstance.accessToken!){
            (result: Bool) in
            print(result)
        }
    }
    
    @IBAction func sendPost(_ sender: Any) {
        if(self.textPost.text == ""){
            emptyFields(title: "Post", message: "Please write a post")
            return;
        }
        if(self.viewSegmentControl.selectedSegmentIndex == 0){
            switch self.typePost {
            case 0:
                self.sendPost()
            case 1:
                self.sendPost()
            case 2:
                self.sendPostGame()
            case 3:
                self.sendPostUser()
                
            default:
                break
            }
        }else{
            self.sendOpinion()
        }
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Home_ID") as! UITabBarController
        let topViewController = UIApplication.shared.keyWindow?.rootViewController
        topViewController?.present(vc, animated: true, completion: nil)
        self.present(vc, animated: true, completion: nil)
        
        
    }
    
}

