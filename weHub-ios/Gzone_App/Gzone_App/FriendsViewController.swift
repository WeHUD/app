//
//  FriendsViewController.swift
//  Gzone_App
//
//  Created by Tracy Sablon on 11/07/2017.
//  Copyright © 2017 Tracy Sablon. All rights reserved.
//

import UIKit

class FriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    
    var myTableView: UITableView!
    var searchController : UISearchController!
    var filteredFriends: [User] = []
    var users: [User] = []
    var avatars: [UIImage] = []
    let cellIdentifier = "FriendsSearchCustomCell"
    var last_index = 0


    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.getUsers()
        let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height - 20
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        self.getUsers()
        myTableView = UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight - barHeight))
        myTableView.register(UINib(nibName: "FriendsSearchTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: cellIdentifier)
       
        
        

       myTableView.allowsSelection = false
        myTableView.estimatedRowHeight = 150.0
        myTableView.rowHeight = 100.0
        myTableView.dataSource = self
        myTableView.delegate = self
        
        //Sort list by ascending alphabet order
        self.filteredFriends.sort {
            $0.username.localizedCaseInsensitiveCompare($1.username) == ComparisonResult.orderedAscending
        }
        
        // Initializing with searchResultsController
        self.searchController = UISearchController(searchResultsController:  nil)
        
        self.searchController.delegate = self
        self.searchController.searchBar.delegate = self
        
        // SearchController will use this view controller to display the search results
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        
        // Add a searchbar to navigation bar
        self.navigationItem.titleView = searchController.searchBar
        
        // Add a searchbar to table view
        myTableView.tableHeaderView = searchController.searchBar
        
        // Change back item title
        self.navigationController?.navigationBar.backItem?.title = " "
        
        // Force the UITabbar to be displayed at the bottom of the UIscrollView
        let tabBarHeight = self.tabBarController?.tabBar.bounds.height
        self.edgesForExtendedLayout = UIRectEdge.all
        myTableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: tabBarHeight!, right: 0.0)
        
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(myTableView)
        
    }
    func updateSearchResults(for searchController: UISearchController) {
        
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            filteredFriends = users.filter { friend in
                return (friend.username.lowercased().contains(searchText.lowercased()))
            }
            
        } else {
            filteredFriends = users
        }
        
        myTableView.reloadData()
        
    }
    

    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        searchController.dismiss(animated: false, completion: nil)
    }
 
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return filteredFriends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! FriendsSearchTableViewCell
        
        let row = indexPath.row
        
        cell.userNameLbl.text = self.filteredFriends[row].username
        cell.userReplyLbl.text = self.filteredFriends[row].reply
        cell.userAvatarImageView.image = self.avatars[row]
        
        cell.followBtn.isHidden = self.isFollower(user: self.filteredFriends[row])
        cell.UnfollowAction = {(cell) in self.follow(user: self.filteredFriends[row])}
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "ProfilUser") as! ProfilUserViewController
        controller.user = self.filteredFriends[(self.myTableView.indexPathForSelectedRow?.row)!]
        
        navigationController?.pushViewController(controller, animated: true)
        
    }
    
    
    
    func follow(user : User){
        AuthenticationService.sharedInstance.currentUser?.followedUsers?.append(user._id)
        
        self.followUser(followerId: user._id)
        
        
    }
    
    func isFollower(user : User)->Bool{
        for follower in (AuthenticationService.sharedInstance.currentUser?.followedUsers)!{
            if(user._id == follower){
                return true
            }
        }
        return false
    }
    
    func followUser(followerId : String){
        
        let followerWB  = WBFollower()
        followerWB.addFollowerUser(userId: AuthenticationService.sharedInstance.currentUser!._id, followerId: followerId,accessToken: AuthenticationService.sharedInstance.accessToken!){
            (result: Bool) in
                self.refreshTableView()

        }
    }
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func getUsers()->Void{
        let userWB : WBUser = WBUser()
        userWB.getAllUsers( accessToken: AuthenticationService.sharedInstance.accessToken!, offset: last_index.description){
            (result: [User]) in

                self.filteredFriends = result
                self.users = result
                self.imageFromUrl(users: self.filteredFriends)
           
                self.refreshTableView()
        }
    }
    

    
    func imageFromUrl(users : [User]){
        
        for user in users {
                let imageUrlString = user.avatar
                let imageUrl:URL = URL(string: imageUrlString!)!
                let imageData:NSData = NSData(contentsOf: imageUrl)!
                self.avatars.append(UIImage(data: imageData as Data)!)
            
        }
        self.refreshTableView()
    }
    func refreshTableView(){
        self.myTableView.reloadData()
    }

  

}



