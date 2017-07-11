//
//  MessageTableViewCell.swift
//  Gzone_App
//
//  Created by Lyes Atek on 08/07/2017.
//  Copyright © 2017 Tracy Sablon. All rights reserved.
//

import UIKit

class MessageTableViewCell : UITableViewCell {
    @IBOutlet weak var textContent: UITextView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var reply: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
}
