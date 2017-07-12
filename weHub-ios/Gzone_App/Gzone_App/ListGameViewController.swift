//
//  ListGameViewController.swift
//  Gzone_App
//
//  Created by Lyes Atek on 09/07/2017.
//  Copyright © 2017 Tracy Sablon. All rights reserved.
//

import UIKit

class ListGameViewController : UIViewController, UITableViewDataSource,UITableViewDelegate{
    
    @IBOutlet var tableView: UITableView!
    
    var games : [Game] = []
    var isPost : Bool = true
    var note : Int = 0
    
    var refreshCtrl = UIRefreshControl()
    var dateFormatter = DateFormatter()
    var last_index = 0
    var update : Bool = true
    var avatars : [UIImage] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated:true);
        self.getGames()
        refreshCtrl.backgroundColor = UIColor.clear
        refreshCtrl.tintColor = UIColor.black
        refreshCtrl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        
        refreshCtrl.addTarget(self, action: #selector(self.PullRefresh), for: UIControlEvents.valueChanged)
        self.tableView.addSubview(refreshCtrl)
        
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.games.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! ListGameTableViewCell
        let game = self.games[indexPath.row]
        cell.gameName.text = game.name
        if(self.avatars.count > indexPath.row){
            cell.boxart.image = self.avatars[indexPath.row]
        }
        
        return cell
    }
    
    
    func refreshTableView(){
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let vc = segue.destination as! CreatePostViewController
        vc.typePost = 2
        vc.game = self.games[(self.tableView.indexPathForSelectedRow?.row)!]
        vc.isPost = self.isPost
        vc.note = self.note
        //   vc.textPost.text = "@" + self.games[(self.tableView.indexPathForSelectedRow?.row)!].name
        
    }
    func getGames()->Void{
        
        let gameWB : WBGame = WBGame()
        gameWB.getAllGames(accessToken: AuthenticationService.sharedInstance.accessToken!,offset: last_index.description){
            (result: [Game]) in
            if(self.last_index == 0){
                self.games = result
                self.imageFromUrl(games: self.games)
                
                self.refreshTableView()
            }else{
                if(result.count == 0){
                    self.update = false
                }else{
                    self.games.append(contentsOf: result)
                    self.imageFromUrl(games: self.games)
                    
                }
                
                let now = Date()
                
                let updateString = "Last Updated at " + self.dateFormatter.string(from: now)
                
                self.refreshCtrl.attributedTitle = NSAttributedString(string: updateString)
                
                if self.refreshCtrl.isRefreshing
                {
                    self.refreshCtrl.endRefreshing()
                }
                
                
            }
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

