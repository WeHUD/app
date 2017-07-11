//
//  SearchTableViewCell.swift
//  Gzone_App
//
//  Created by Tracy Sablon on 14/06/2017.
//  Copyright © 2017 Tracy Sablon. All rights reserved.
//

import UIKit

class GamesSearchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var gameIconImageView: UIImageView!
  
    @IBOutlet weak var GameNameLbl: UILabel!
    @IBOutlet weak var FollowBtn: UIButton!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
        FollowBtn.layer.cornerRadius = 15;
        FollowBtn.layer.borderWidth = 1;
        FollowBtn.layer.borderColor = (UIColor(red: 161/255.0, green: 36/255.0, blue: 249/255.0, alpha: 1.0)).cgColor
        FollowBtn.contentEdgeInsets = UIEdgeInsetsMake(5,10,5,10)
    }

}
