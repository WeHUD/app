//
//  PageViewController.swift
//  Gzone_App
//
//  Created by Tracy Sablon on 03/05/2017.
//  Copyright © 2017 Tracy Sablon. All rights reserved.
//

import UIKit
import XLPagerTabStrip


class PageGamesViewController: UITableViewController, IndicatorInfoProvider,UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate  {
    var games : [Game] = []
    var topGames : [Game] = []
    var followers : [String] = []
    let cellIdentifier = "GamesCustomCell"
    let categories = ["New","Top Games"]
    
    var refreshCtrl = UIRefreshControl()
    var dateFormatter = DateFormatter()
    var last_index = 0
    var update : Bool = true
    var avatars : [UIImage] = []
    var avatarsTopGames : [UIImage] = []
    
    //var searchController : UISearchController!
    
    //Mock for populate cells
    /* struct Game {
     var title : String?
     }
     
     var games = [[Game(title: "Horizon Zero Dawn"),Game(title: "Resident Evil")],
     [Game(title: "Tekken 7"),Game(title: "Uncharted 4")],
     [Game(title: "Grand Theft Auto V"),Game(title: "Injustice 2")]]
     
     */
    //Initialize the tableView itemInfo
    var itemInfo = IndicatorInfo(title: "View")
    init(style: UITableViewStyle, itemInfo: IndicatorInfo) {
        self.itemInfo = itemInfo
        super.init(style: style)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.getGames()
        print("Games View");
        
        refreshCtrl.backgroundColor = UIColor.clear
        refreshCtrl.tintColor = UIColor.black
        refreshCtrl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        
        refreshCtrl.addTarget(self, action: #selector(PageGamesViewController.PullRefresh), for: UIControlEvents.valueChanged)
        self.tableView.addSubview(refreshCtrl)
        
        
        //Settings for custom table cell
        tableView.register(UINib(nibName: "GamesTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: cellIdentifier)
        /*tableView.allowsSelection = false
        tableView.estimatedRowHeight = UITableViewAutomaticDimension
        tableView.rowHeight = 140.0
        self.tableView.delegate = self
        self.tableView.dataSource = self*/
        
    }
    
    
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return self.categories[section]
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return self.categories.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return self.games.count
        }
        else{
            return self.topGames.count
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! GamesTableViewCell
        if(indexPath.section == 0){
            let game = self.games[indexPath.row]
            _ = indexPath.section
            
            cell.gameTitleLbl.text = game.name
            if(self.avatars.count > indexPath.row){
                cell.imageView?.image = self.avatars[indexPath.row]
            }
            cell.followButton.isHidden = self.isFollower(game: game)
            
            
            
            cell.followAction = {(cell) in self.follow(game: game)}
        }else{
            
            let game = self.topGames[indexPath.row]
            
            
            cell.gameTitleLbl.text = game.name
            if(self.avatarsTopGames.count > indexPath.row){
                cell.imageView?.image = self.avatarsTopGames[indexPath.row]
            }
            cell.followButton.isHidden = self.isFollower(game: game)
            
            
            
            cell.followAction = {(cell) in self.follow(game: game)}
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Game_ID") as! GameViewController
        if(indexPath.section == 0){
            vc.game = self.games[indexPath.row]
            vc.isFollow = self.isFollower(game: self.games[indexPath.row])
        }else{
            vc.game = self.topGames[indexPath.row]
            vc.isFollow = self.isFollower(game: self.games[indexPath.row])
        }
        self.navigationController?.pushViewController(vc, animated: true)
        
        
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
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getGames()->Void{
        
        let gameWB : WBGame = WBGame()
        gameWB.getAllGames(accessToken: AuthenticationService.sharedInstance.accessToken!,offset: last_index.description){
            (result: [Game]) in
            self.topGamesCreate()
            if(self.last_index == 0){
                self.games = result
                self.avatars = self.imageFromUrl(games: self.games)
                
            }else{
                if(result.count == 0){
                    self.update = false
                }else{
                    self.games.append(contentsOf: result)
                    self.avatars = self.imageFromUrl(games: self.games)
                }
                self.refreshTableView()
                
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
    
    func topGamesCreate(){
        self.topGames = self.games.sorted{ $0.followerId.count < $1.followerId.count }
        self.avatarsTopGames = self.imageFromUrl(games: self.topGames)
        self.refreshTableView()
    }
    
    
    
    func refreshTableView(){
        DispatchQueue.main.async {
            self.tableView.reloadData()
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
    func imageFromUrl(games : [Game])->[UIImage]{
        var avatarsGames : [UIImage] = []
        for game in games {
            if(game.boxart != ""){
                let imageUrlString = game.boxart
                let imageUrl:URL = URL(string: imageUrlString)!
                let imageData:NSData = NSData(contentsOf: imageUrl)!
                avatarsGames.append(UIImage(data: imageData as Data)!)
            }else{
                let imageUrlString = "https://vignette3.wikia.nocookie.net/transformers/images/b/b6/Playschool_Go-Bots_G.png/revision/latest?cb=20061127024844"
                let imageUrl:URL = URL(string: imageUrlString)!
                let imageData:NSData = NSData(contentsOf: imageUrl)!
                avatarsGames.append(UIImage(data: imageData as Data)!)
            }
        }
        return avatarsGames
    }
    
    
    
    
}



