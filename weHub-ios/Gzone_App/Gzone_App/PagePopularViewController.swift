//
//  PagePopularViewController.swift
//  Gzone_App
//
//  Created by Tracy Sablon on 19/06/2017.
//  Copyright © 2017 Tracy Sablon. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class PagePopularViewController: UITableViewController, IndicatorInfoProvider {
    
    var connectedUser : String?
    var posts : [Post] = []
    var users : [User] = []
    var offset : Int = 1
    
    var cellIdentifier = ""
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
        
        self.getFeeds()
        
        cellIdentifier = "PopularCustomCell"
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 500.0
        tableView.estimatedRowHeight = 800.0
        tableView.allowsSelection = false
        tableView.scrollsToTop = false
        tableView.register(UINib(nibName: "PopularTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: cellIdentifier)
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        // Retrieve tableview feed content from webservice
        self.posts.removeAll()
        getFeeds()
        tableView.reloadData()
    }
    
    // Tap Gesture action when tap media content
    func showYoutubeModal(_ sender : UITapGestureRecognizer){
        
        print("Tap image : ", sender.view?.tag ?? "no media content")
        
        let mediaTag = sender.view?.tag
        let postVideo = posts[mediaTag!].video
        
        if (postVideo != "") {
            // Instantiate a modal view when content media is tapped
            let modalViewController = ModalViewController()
            modalViewController.videoURL = postVideo
            modalViewController.modalPresentationStyle = .popover
            present(modalViewController, animated: true, completion: nil)
        }
    }
    
    
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        
        return itemInfo
    }

    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //getFeeds()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension PagePopularViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        // Force update of cell height when no media content
        let post = self.posts[indexPath.row]
        
        var postHeight = 300.0
        
        if(post.video != ""){
            postHeight += 150.0
        }
        if(post.mark != nil){
            postHeight += 50.0
        }
        
        return CGFloat(postHeight)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)as! PopularTableViewCell
        
        let post = self.posts[ indexPath.row]
        
        //Initialize cell image to nil for fixing reuse cell issues
        cell.mediaImageView.image = nil
        
        cell.userNameLabel.text = post.author
        cell.userReplyLabel.text = "@" + post.author
        cell.postDescription.text = post.text
        cell.postDate.text = post.datetimeCreated.description
        
        if(post.flagOpinion){
            self.fillRates(rates: [cell.rate1,cell.rate2,cell.rate3,cell.rate4,cell.rate5], mark: post.mark!)
            self.ratesHidden( rates: [cell.rate1,cell.rate2,cell.rate3,cell.rate4,cell.rate5],isHidden: false)
            
        }else{
            self.ratesHidden( rates: [cell.rate1,cell.rate2,cell.rate3,cell.rate4,cell.rate5],isHidden: true)
        }
        if(post.video != ""){

            // Extract youtube ID from URL
            let mediaId = post.video.youtubeID!
            let mediaURL = "http://img.youtube.com/vi/"+mediaId+"/mqdefault.jpg"
            
            // Use of Utils extension for downloading youtube thumbnails
            let isSucessMediaDownload = cell.mediaImageView.imageFromYoutube(url: mediaURL)
            
            if isSucessMediaDownload {
                // On tap gesture display presentation view with media content
                cell.mediaImageView.isUserInteractionEnabled = true;
                cell.mediaImageView.tag = indexPath.row
                let tapGesture = UITapGestureRecognizer(target:self, action: #selector(self.showYoutubeModal(_:)))
                cell.mediaImageView.addGestureRecognizer(tapGesture)
            }else {
                
                cell.mediaImageView.isUserInteractionEnabled = false
            }
        }
        cell.numberLike.text = post.likes.count.description
        
        return cell
    }

}

extension PagePopularViewController {

    func getFeeds()->Void{
        
        let postsWB : WBPost = WBPost()
        // self.offset += 1
        postsWB.getPostTendance(accessToken: AuthenticationService.sharedInstance.accessToken!) {
            (result: [Post]) in
            if(self.posts.count == 0){
                self.posts = result
            }else if(self.posts.count != 0 && result.count > 0){
                self.posts.append(contentsOf: result)
            }
            self.refreshTableView()
        }
    }
    
    func refreshTableView(){
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    
    func fillRates(rates : [UIImageView],mark : Int){
        if(mark == 0)
        {
            return
        }
        for i in 0 ..< mark {
            
            rates[i].image = UIImage(named: "starFill.png")
            
        }
        
    }
    
    func ratesHidden(rates : [UIImageView],isHidden : Bool){
        for i in 0 ..< rates.count {
            rates[i].isHidden = isHidden
        }
    }

}

