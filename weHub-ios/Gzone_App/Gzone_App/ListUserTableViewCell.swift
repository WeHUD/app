//
//  ListUserTableViewCell.swift
//  Gzone_App
//
//  Created by Lyes Atek on 09/07/2017.
//  Copyright © 2017 Tracy Sablon. All rights reserved.
//

import UIKit

class ListUserTableViewCell : UITableViewCell {
    
    @IBOutlet weak var username: UILabel!

    @IBOutlet weak var avatar: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
}


