//
//  ProfileViewController.swift
//  Gzone_App
//
//  Created by Tracy Sablon on 20/06/2017.
//  Copyright © 2017 Tracy Sablon. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var username: UIButton!

    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var reply: UILabel!
   
    var connectedUser : User?
    var currentUser : User?

    
    private let myArray: NSArray = ["Voir mon profile","Message","Contacts","Settings","Log off"]
    private var myTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height - 20
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        
        myTableView = UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight - barHeight))
        myTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        myTableView.rowHeight = 80.0
        myTableView.dataSource = self
        myTableView.delegate = self
        myTableView.tableFooterView = UIView()
        myTableView.allowsSelection = true
        self.view.addSubview(myTableView)
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("Num: \(indexPath.row)")
        print("Value: \(myArray[indexPath.row])")
        
        if (indexPath.row == 0) {
            
            let storyboard = UIStoryboard(name: "Home", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "ProfilUser") as! ProfilUserViewController
            controller.user = AuthenticationService.sharedInstance.currentUser
            navigationController?.pushViewController(controller, animated: true)
        }

        
        if (indexPath.row == 1) {
            
            let storyboard = UIStoryboard(name: "Home", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "MessageVC_ID")
            navigationController?.pushViewController(controller, animated: true)
        }
        
        if (indexPath.row == 2) {
            
            let storyboard = UIStoryboard(name: "Home", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "ContactVC_ID")
            navigationController?.pushViewController(controller, animated: true)
        }
        if (indexPath.row == 3) {
            
            let storyboard = UIStoryboard(name: "Home", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "SettingVC_ID")
            navigationController?.pushViewController(controller, animated: true)
        }
        if (indexPath.row == 4) {
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "authentVC_ID")
            
            self.dismiss(animated: true, completion: {});
            self.navigationController?.popViewController(animated: true);
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return myArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath as IndexPath)
        
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        cell.selectionStyle = .none
        
        cell.textLabel!.text = "\(myArray[indexPath.row])"
        cell.textLabel?.textColor = UIColor.lightGray
        cell.textLabel?.textAlignment = .left
        cell.textLabel?.font = cell.textLabel?.font.withSize(20)
        
        cell.textLabel?.textColor = UIColor.lightGray
        cell.detailTextLabel?.textAlignment = .right
        cell.detailTextLabel?.text = "sqnSKNDKNNDSKQNDKS"
        cell.textLabel?.font = cell.textLabel?.font.withSize(20)
        
        return cell
    }
    

    override func viewWillAppear(_ animated: Bool) {
        
        if(connectedUser != nil){
            connectedUser = AuthenticationService.sharedInstance.currentUser!
            username.setTitle(connectedUser?.username, for: .normal)
            reply.text = "@" + (connectedUser?.username)!
            avatar.image = self.imageFromUrl(url : (connectedUser?.avatar)!)
        }
    }
    
    func imageFromUrl(url : String)->UIImage{
        
        let imageUrlString = url
        let imageUrl:URL = URL(string: imageUrlString)!
        let imageData:NSData = NSData(contentsOf: imageUrl)!
        return UIImage(data: imageData as Data)!
        
        
    }
}
