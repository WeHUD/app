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
    var filteredFriends: [User]?
    let cellIdentifier = "FriendsSearchCustomCell"
    
    //Mock for populate cells
    struct User {
        var name : String?
        var reply : String?
    }
    
    var users = [User(name: "Tracy", reply:"@user1"),User(name: "Lyes",reply:"@user2"),User(name: "Olivier",reply:"@user3"),User(name: "Theo",reply:"@user4"),User(name: "Lara",reply:"@user5"),User(name: "Lionel",reply:"@user6")]
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height - 20
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        
        myTableView = UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight - barHeight))
        myTableView.register(UINib(nibName: "FriendsSearchTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: cellIdentifier)
        myTableView.allowsSelection = false
        myTableView.estimatedRowHeight = 150.0
        myTableView.rowHeight = 100.0
        myTableView.dataSource = self
        myTableView.delegate = self
        
        //Sort list by ascending alphabet order
        users.sort {
            $0.name?.localizedCaseInsensitiveCompare($1.name!) == ComparisonResult.orderedAscending
        }
        // Initialize data for list
        filteredFriends = users
        
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
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        searchController.dismiss(animated: false, completion: nil)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            filteredFriends = users.filter { friend in
                return (friend.name?.lowercased().contains(searchText.lowercased()))!
            }
            
        } else {
            filteredFriends = users
        }
        
        myTableView.reloadData()
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return filteredFriends!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! FriendsSearchTableViewCell
        
        let row = indexPath.row
        
        cell.userNameLbl.text = self.filteredFriends?[row].name
        cell.userReplyLbl.text = self.filteredFriends?[row].reply
        
        return cell
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}



