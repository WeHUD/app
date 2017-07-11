//
//  CreatePostViewController.swift
//  Gzone_App
//
//  Created by Lyes Atek on 06/07/2017.
//  Copyright © 2017 Tracy Sablon. All rights reserved.
//

import UIKit

class CreatePostViewController : UIViewController, UITableViewDelegate,UITableViewDataSource{
    @IBOutlet weak var rateLbl: UILabel!
    
    @IBOutlet weak var rate1: UIButton!
    
    @IBOutlet weak var rate2: UIButton!
    @IBOutlet weak var rate3: UIButton!
    
    @IBOutlet weak var rate4: UIButton!
    
    @IBOutlet weak var rate5: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var url: UITextField!

    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var typePost: UISegmentedControl!
    
    @IBOutlet weak var textPost: UITextView!
    
    var isGame : Bool = false
    
    var rates : [UIButton] = []
    var note : Int = 0
    var followers : [User] = []
    var type : [String] = ["Photo/Vidéo","Jeux","Utilisateur"]
    
    var games : [Game] = []
    
    var user : User?
    var game : Game?
    var rowSelected : Int = 0
    var isPost : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated:true);
        self.tableView.dataSource = self
        self.tableView.delegate = self
        initializeRates()
      //  self.tableView.selectRowAtIndexPath(index, animated: true, scrollPosition: .middle)
        self.changeViewPost(type: rowSelected)
        
        if(isPost){
            self.typePost.selectedSegmentIndex = 0
        }else{
            self.typePost.selectedSegmentIndex = 1
        }
        
        self.changeViewOpinion(type: self.typePost.selectedSegmentIndex)
        if(self.game != nil){
            rowSelected = 1
            self.textPost.text = "@"+(self.game?.name)!
        }else if(self.user != nil){
            rowSelected = 2
            self.textPost.text = "@"+(self.user?.username)!
        }else{
            rowSelected = 0
            self.textPost.text = ""

        }
        
      
        self.tableView.selectRow(at: self.tableView.indexPathForSelectedRow, animated: true, scrollPosition: .middle)
    }
    
    func inizializeSelectedTableView(row : Int){
        let rowToSelect:IndexPath = IndexPath(row: row, section: 0)  //slecting 0th row with 0th section
        self.tableView.selectRow(at: rowToSelect, animated: true, scrollPosition: UITableViewScrollPosition.none);
    }
    
    func initializeRates(){
        rates.append(rate1)
        rates.append(rate2)
        rates.append(rate3)
        rates.append(rate4)
        rates.append(rate5)
    }
    
    func changeViewPost(type : Int){
        switch type {
        case 0:
            url.isHidden = false
        case 1:
            url.isHidden = true
        case 2:
            url.isHidden = true
        default:
             url.isHidden = false
        }
        
        self.inizializeSelectedTableView(row: self.rowSelected)

    }
    
    func changeViewOpinion(type : Int){
        switch self.typePost.selectedSegmentIndex {
        case 0:
            self.url.isHidden = true
            postTypeChoose(isHidden: true)
            self.type =  ["Photo/Vidéo","Jeux","Utilisateur"]
        case 1:
            self.url.isHidden = true
            postTypeChoose(isHidden: false)
            self.type =  ["Jeux"]
            
        default:
            postTypeChoose(isHidden: true)
        }
        self.refreshTableViewSegmentControlChanged()
        
    }
    
    func setImageRates(){
        for i in 0 ..< self.rates.count {
            
            self.rates[i].setImage(UIImage(named: "star.png"), for: .normal)

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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return self.type.count;
        
       
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(self.type[indexPath.row] != "Photo/Vidéo"){
        let cell:CreatePostTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell")! as! CreatePostTableViewCell
            let gameName = type[indexPath.row]
            cell.gameName.text = gameName
            return cell
        }else{
            let cell:VideoTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "videoCell")! as! VideoTableViewCell
            let gameName = type[indexPath.row]
            cell.username.text = gameName
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.rowSelected = indexPath.row
        self.changeViewPost(type: self.rowSelected)
        if(self.typePost.selectedSegmentIndex == 0){
            switch self.rowSelected  {
            case 0:
                if(self.textPost.text == ""){
                    self.sendButton.isUserInteractionEnabled = false
                }else{
                     self.sendButton.isUserInteractionEnabled  = true
                }
            case 1:
                if(self.game?._id == nil){
                     self.sendButton.isUserInteractionEnabled = false
                }else{
                     self.sendButton.isUserInteractionEnabled = true
                }
            case 2:
                if(self.user?._id == nil){
                    self.sendButton.isUserInteractionEnabled = false
                }else{
                    self.sendButton.isUserInteractionEnabled = true
                }
            default:
                break
            }
        }
        else{
            if(self.game?._id == nil){
                self.sendButton.isEnabled = false
            }else{
                self.sendButton.isEnabled = true
            }
        }
            
    }
    
    func getAllGames(){
        
        let gameWB : WBGame = WBGame()
        gameWB.getAllGames(accessToken: AuthenticationService.sharedInstance.accessToken!, offset: "0"){
            (result: [Game]) in
            self.games = result
            
          
        }
    }

    func refreshTableViewSegmentControlChanged(){
        let group = DispatchGroup()
        group.enter()
        
        DispatchQueue.main.async(execute: {
           
            self.tableView.reloadData()
            group.leave()
        })
        
        group.notify(queue: .main) {
            self.rowSelected = 0

            if(self.typePost.selectedSegmentIndex == 0){

                self.changeViewPost(type: self.rowSelected)
            }else{
                self.inizializeSelectedTableView(row: 0)
            }

        }
    }
    
    func refreshTableView(){
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
        func postTypeChoose(isHidden : Bool){
        for i in 0 ..< self.rates.count{
            self.rates[i].isHidden = isHidden
        }
        self.rateLbl.isHidden = isHidden
    }
    
    @IBAction func indexChanged(_ sender: Any) {
          self.changeViewOpinion(type: self.typePost.selectedSegmentIndex)
        self.textPost.text = ""
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if(segue.identifier != "sendPost"){
            let viewController = segue.destination as! ListGameViewController
            if((self.tableView.indexPathForSelectedRow?.row)! <= 1){
                viewController.isListGame = true
            }else{
                viewController.isListGame = false
            }
            if(self.typePost.selectedSegmentIndex == 0){
                self.isPost = true
                viewController.isPost = self.isPost
            }else{
                self.isPost = false
                viewController.isPost = self.isPost
            }
        }
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
    
    func sendPostVideo(){
        
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
        if(self.typePost.selectedSegmentIndex == 0){
            if(self.rowSelected == 0){
                self.sendPostVideo()
            }else if(self.rowSelected == 1){
                
                self.sendPostGame()
            }else if(self.rowSelected == 2){
                self.sendPostUser()
            }
        }else{
            self.sendOpinion()
        }
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Home_ID") as! UITabBarController
        self.present(vc, animated: true, completion: nil)


    }
    
    func getFollowers()->Void{
        
        let userWB : WBUser = WBUser()
        userWB.getFollowedUser(accessToken: AuthenticationService.sharedInstance.accessToken!,  userId : AuthenticationService.sharedInstance.currentUser!._id,offset: "0") {
            (result: [User]) in
            self.followers = result
        }
    }
    
    
    
}

