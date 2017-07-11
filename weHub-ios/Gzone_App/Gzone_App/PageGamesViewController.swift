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
    let cellIdentifier = "GamesCustomCell"
    let categories = ["New","Top Games","Coming soon"]
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
        
        //Settings for custom table cell
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 200.0
        tableView.rowHeight = 150.0
        tableView.scrollsToTop = false
        tableView.allowsSelection = false
        tableView.register(UINib(nibName: "GamesTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: cellIdentifier)
        
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
        
        return self.games.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! GamesTableViewCell
        
        let game = self.games[indexPath.row]
        let section = indexPath.section
        
        cell.gameTitleLbl.text = game.name
        
        return cell
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
        gameWB.getAllGames(accessToken: AuthenticationService.sharedInstance.accessToken!,offset: "0"){
            (result: [Game]) in
            self.games = result
            self.refreshTableView()
        }
    }
    
    func refreshTableView(){
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }

    
}



