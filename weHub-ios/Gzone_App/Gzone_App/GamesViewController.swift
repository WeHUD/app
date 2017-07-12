//
//  PageViewController.swift
//  Gzone_App
//
//  Created by Tracy Sablon on 03/05/2017.
//  Copyright © 2017 Tracy Sablon. All rights reserved.
//

import UIKit

class GamesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    
    var myTableView: UITableView!
    var searchController : UISearchController!
    let cellIdentifier = "GamesSearchCustomCell"
    
    var filteredGames: [Game] = []
    var games : [Game] = []
    var offset : Int = 0
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        print("Games View");
        
        let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height - 20
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        
        myTableView = UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight - barHeight))
        myTableView.register(UINib(nibName: "GamesSearchTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: cellIdentifier)
        myTableView.allowsSelection = false
        myTableView.estimatedRowHeight = UITableViewAutomaticDimension
        myTableView.rowHeight = 140.0
        myTableView.dataSource = self
        myTableView.delegate = self
        
        // Sort list by ascending alphabet order
        /*games.sort {
            $0.name.localizedCaseInsensitiveCompare($1.name) == ComparisonResult.orderedAscending
        }*/


        // Initializing with searchResultsController
        self.searchController = UISearchController(searchResultsController:  nil)
        
        self.searchController.delegate = self
        self.searchController.searchBar.delegate = self
        
        // SearchController will use this view controller to display the search results
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        self.definesPresentationContext = true
        searchController.searchBar.sizeToFit()
        
        // Add a searchbar to navigation bar
        self.navigationItem.titleView = searchController.searchBar
        
        // Force the UITabbar to be displayed at the bottom of the UIscrollView
        let tabBarHeight = (self.tabBarController?.tabBar.bounds.height)! + searchController.searchBar.bounds.height
        self.edgesForExtendedLayout = UIRectEdge.all
        myTableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: tabBarHeight, right: 0.0)
        
        self.edgesForExtendedLayout = UIRectEdge.init(rawValue: 0)
        self.navigationItem.title = "Search games" 
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(myTableView)
        
        
        // Retrieve tableview game content from webservice
        //self.games.removeAll()
        // Initialize data for list
        self.getGames()
        self.myTableView.reloadData()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        myTableView.reloadData()
        
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        searchController.dismiss(animated: false, completion: nil)
        searchController.searchBar.text = "";
    }
    
    
    func updateSearchResults(for searchController: UISearchController) {
        
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            filteredGames = games.filter { game in
                return (game.name.lowercased().contains(searchText.lowercased()))
            }
            
        } else {
            filteredGames = games
        }
        
        myTableView.reloadData()
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    

   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        return filteredGames.count

    }
    
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! GamesSearchTableViewCell
        
        let row = indexPath.row
        
        cell.GameNameLbl.text = self.filteredGames[row].name
        
        return cell
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension GamesViewController {
    
    func getGames(){
        
        let gamesWB : WBGame = WBGame()
        var gamesArr = [Game]()
        self.offset += 1
        
        
        gamesWB.getAllGames(accessToken: (AuthenticationService.sharedInstance.accessToken!),offset: self.offset.description) {
            (result: [Game]) in
            
            gamesArr = result
            print("WB : \(gamesArr.count)")
            print(result)
            
            DispatchQueue.main.async(execute: {
                
                self.games = gamesArr
                self.filteredGames = self.games
                self.myTableView.reloadData()
            })
        }
    }
}




