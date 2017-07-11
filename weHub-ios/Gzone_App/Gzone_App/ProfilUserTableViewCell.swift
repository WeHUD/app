//
//  ProfilUserTableViewCell.swift
//  Gzone_App
//
//  Created by Lyes Atek on 05/07/2017.
//  Copyright © 2017 Tracy Sablon. All rights reserved.
//

import UIKit

class ProfilUserTableViewCell : UITableViewCell {

    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var username: UILabel!
    
    @IBOutlet weak var reply: UILabel!
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var like: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
}

