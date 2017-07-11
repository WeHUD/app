//
//  GamesTableViewCell.swift
//  Gzone_App
//
//  Created by Tracy Sablon on 14/06/2017.
//  Copyright © 2017 Tracy Sablon. All rights reserved.
//

import UIKit

class GamesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var gameTitleLbl: UILabel!
    @IBOutlet weak var gameImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
