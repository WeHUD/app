//
//  ContactTableViewCell.swift
//  Gzone_App
//
//  Created by Lyes Atek on 04/07/2017.
//  Copyright © 2017 Tracy Sablon. All rights reserved.
//

import UIKit

class ContactTableViewCell : UITableViewCell {
    var tapAction: ((UITableViewCell) -> Void)?
    
    @IBOutlet weak var contactAvatar: UIImageView!
    
    @IBAction func unfollowAction(_ sender: Any) {
        tapAction?(self)
    }

    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var usernamelbl: UILabel!
    
    
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

    
}
