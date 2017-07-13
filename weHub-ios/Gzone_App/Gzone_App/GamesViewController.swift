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
    var avatars : [UIImage] = []
    var filteredGames: [Game] = []
    var games : [Game] = []
    var offset : Int = 0
    var refreshCtrl = UIRefreshControl()
    var dateFormatter = DateFormatter()
    var last_index = 0
    var update : Bool = true

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.getGames()
 
        print("Games View");
        
        let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height - 20
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        
        myTableView = UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight - barHeight))
        myTableView.register(UINib(nibName: "GamesSearchTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: cellIdentifier)
        refreshCtrl.backgroundColor = UIColor.clear
        refreshCtrl.tintColor = UIColor.black
        refreshCtrl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        
        refreshCtrl.addTarget(self, action: #selector(self.PullRefresh), for: UIControlEvents.valueChanged)
        self.myTableView.addSubview(refreshCtrl)

       // myTableView.allowsSelection = false
       myTableView.estimatedRowHeight = UITableViewAutomaticDimension
       myTableView.rowHeight = 100
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
        if(self.avatars.count > indexPath.row){
            cell.imageView?.image = self.avatars[indexPath.row]
        }
    
        cell.FollowBtn.isHidden = self.isFollower(game:  self.filteredGames[row])
        cell.followAction = {(cell) in self.follow(game:  self.filteredGames[row])}
        return cell
    }
    
    func follow(game : Game){
        game.followerId.append((AuthenticationService.sharedInstance.currentUser?._id)!)
        self.games[self.games.index(of: game)!] = game
        
        self.followGame(game: game)
        
        
    }
    
    func isFollower(game : Game)->Bool{
        for follower in game.followerId{
            if(follower == AuthenticationService.sharedInstance.currentUser?._id){
                return true
            }
        }
        return false
    }
    
    func followGame(game : Game){
        let gameWB : WBGame = WBGame()
        // self.offset += 1
        gameWB.updateGame(game: game, usersId: game.followerId, accessToken: AuthenticationService.sharedInstance.accessToken!){
            (result: Bool) in
            if(result){
                self.refreshTableView()
            }
        }
        
    }

    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension GamesViewController {
    func refreshTableView(){
            self.myTableView.reloadData()
        
    }

    func getGames()->Void{
        
        let gameWB : WBGame = WBGame()
        gameWB.getAllGames(accessToken: AuthenticationService.sharedInstance.accessToken!,offset: last_index.description){
            (result: [Game]) in
            if(self.last_index == 0){
                self.games = result
                self.filteredGames = self.games
                self.imageFromUrl(games: self.games)
                
               self.refreshTableView()
            }else{
                if(result.count == 0){
                    self.update = false
                }else{
                    self.games.append(contentsOf: result)
                    self.filteredGames = self.games
                    self.imageFromUrl(games: self.filteredGames)
                    
                }

                let now = Date()
                
                let updateString = "Last Updated at " + self.dateFormatter.string(from: now)
                
                self.refreshCtrl.attributedTitle = NSAttributedString(string: updateString)
                
                if self.refreshCtrl.isRefreshing
                {
                    self.refreshCtrl.endRefreshing()
                }
                
                
            }
            self.refreshTableView()
        }
    }
    func PullRefresh()
    {
        if(update){
            last_index += 1
            self.getGames()
        }else{
            let updateString = "Il n'y a pas de nouveaux jeux"
            
            self.refreshCtrl.attributedTitle = NSAttributedString(string: updateString)
            
            if self.refreshCtrl.isRefreshing
            {
                self.refreshCtrl.endRefreshing()
            }
        }
    }
    
    func imageFromUrl(games : [Game]){
        self.avatars.removeAll()
        for game in games {
            if(game.boxart != ""){
                let imageUrlString = game.boxart
                let imageUrl:URL = URL(string: imageUrlString)!
                let imageData:NSData = NSData(contentsOf: imageUrl)!
                self.avatars.append(UIImage(data: imageData as Data)!)
            }else{
                let imageUrlString = "https://vignette3.wikia.nocookie.net/transformers/images/b/b6/Playschool_Go-Bots_G.png/revision/latest?cb=20061127024844"
                let imageUrl:URL = URL(string: imageUrlString)!
                let imageData:NSData = NSData(contentsOf: imageUrl)!
                self.avatars.append(UIImage(data: imageData as Data)!)
            }
        }
        self.refreshTableView()
    }
    

}




