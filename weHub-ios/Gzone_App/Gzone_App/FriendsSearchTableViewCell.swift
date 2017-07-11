//
//  SearchTableViewCell.swift
//  Gzone_App
//
//  Created by Tracy Sablon on 14/06/2017.
//  Copyright © 2017 Tracy Sablon. All rights reserved.
//

import UIKit

class FriendsSearchTableViewCell: UITableViewCell {

    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var userReplyLbl: UILabel!
    @IBOutlet weak var userAvatarImageView: UIImageView!
    @IBOutlet weak var followBtn: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
        followBtn.layer.cornerRadius = 15;
        followBtn.layer.borderWidth = 1;
        followBtn.layer.borderColor = (UIColor(red: 161/255.0, green: 36/255.0, blue: 249/255.0, alpha: 1.0)).cgColor
        followBtn.contentEdgeInsets = UIEdgeInsetsMake(5,10,5,10)
    }

}
