//
//  ProfileViewController.swift
//  Gzone_App
//
//  Created by Tracy Sablon on 20/06/2017.
//  Copyright © 2017 Tracy Sablon. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var username: UIButton!

    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var reply: UILabel!
   
      var connectedUser : User?
    var currentUser : User?
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func viewWillAppear(_ animated: Bool) {
        if(connectedUser == nil){
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
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.`
        if(segue.identifier == "PU"){
            let viewController = segue.destination as! ProfilUserViewController
            viewController.user = self.connectedUser
        }
        
    }

}
