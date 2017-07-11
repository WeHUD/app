//
//  SearchAllViewController.swift
//  Gzone_App
//
//  Created by Tracy Sablon on 11/07/2017.
//  Copyright © 2017 Tracy Sablon. All rights reserved.
//

import UIKit

class SearchAllViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let myArray: NSArray = ["Friends","Games"]
    private var myTableView: UITableView!
    
    override func viewDidLoad() {
    super.viewDidLoad()
    
        let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height - 20
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
    
        myTableView = UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight - barHeight))
        myTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        myTableView.rowHeight = 180.0
        myTableView.dataSource = self
        myTableView.delegate = self
        let backgroundImage = UIImage(named: "WeHubBack")
        let imageView = UIImageView(image: backgroundImage)
        imageView.contentMode = .scaleAspectFill
        myTableView.backgroundView = imageView
        myTableView.separatorColor = UIColor.black
        myTableView.tableFooterView = UIView()
        self.view.addSubview(myTableView)
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("Num: \(indexPath.row)")
        print("Value: \(myArray[indexPath.row])")
        
        if (indexPath.row == 0) {
            
            let friendVC = FriendsViewController()
            navigationController?.pushViewController(friendVC, animated: true)
        }
        
        if (indexPath.row == 1) {
            
            let gameVC = GamesViewController()
            navigationController?.pushViewController(gameVC, animated: true)
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
         cell.backgroundColor = UIColor(red: 78/255.0, green: 14/255.0, blue: 20/255.0, alpha: 0.5)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath as IndexPath)
        
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        cell.selectionStyle = .none
        
        cell.textLabel!.text = "\(myArray[indexPath.row])"
        cell.textLabel?.textColor = UIColor.white
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.font = cell.textLabel?.font.withSize(25)
        return cell
    }
}
