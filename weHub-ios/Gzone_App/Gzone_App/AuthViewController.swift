//
//  AuthViewController.swift
//  Gzone_App
//
//  Created by Tracy Sablon on 05/03/2017.
//  Copyright © 2017 Tracy Sablon. All rights reserved.
//

import UIKit


class AuthViewController: UIViewController {
    
    @IBOutlet weak var signInBtn: UIButton!
    @IBOutlet weak var signUpBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Authentication view");
        
        assignbackground()
        
        signInBtn.layer.cornerRadius = 15;
        signInBtn.layer.borderWidth = 0.0;
        signInBtn.backgroundColor = (UIColor(red: 78/255.0, green: 14/255.0, blue: 15/255.0, alpha: 1.0))
        
        signUpBtn.layer.cornerRadius = 15;
        signUpBtn.layer.borderWidth = 1;
        signUpBtn.layer.borderWidth = 0.0;
        signUpBtn.backgroundColor = (UIColor(red: 78/255.0, green: 14/255.0, blue: 15/255.0, alpha: 1.0))
        
        
    }
    
    
    func assignbackground(){
        let background = UIImage(named: "Launchscreen")
        
        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIViewContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        view.addSubview(imageView)
        self.view.sendSubview(toBack: imageView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

