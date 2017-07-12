//
//  PopularTableViewCell.swift
//  Gzone_App
//
//  Created by Tracy Sablon on 19/06/2017.
//  Copyright © 2017 Tracy Sablon. All rights reserved.
//

import UIKit

class PopularTableViewCell: UITableViewCell {
    
    var tapAction: ((UITableViewCell) -> Void)?
    var commentAction: ((UITableViewCell) -> Void)?
    var followAction: ((UITableViewCell) -> Void)?
    
    
    @IBAction func likePost(_ sender: Any) {
        tapAction?(self)
    }
    
    @IBAction func commentPost(_ sender: Any) {
        commentAction?(self)
    }
    
    @IBAction func followPost(_ sender: Any) {
        followAction?(self)
    }
    
    
    
    
    @IBOutlet weak var numberLike: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userReplyLabel: UILabel!
    @IBOutlet weak var postDescription: UITextView!
    @IBOutlet weak var postDate: UILabel!
    @IBOutlet weak var mediaImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var rate1: UIImageView!
    @IBOutlet weak var rate3: UIImageView!
    @IBOutlet weak var rate2: UIImageView!
    @IBOutlet weak var rate4: UIImageView!
    @IBOutlet weak var rate5: UIImageView!
    @IBOutlet weak var likePostBtn: UIButton!
    @IBOutlet weak var commentPostBtn: UIButton!
    @IBOutlet weak var followBtn: UIButton!
    
    @IBOutlet weak var numberCommentsLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        followBtn.layer.cornerRadius = 15;
        followBtn.layer.borderWidth = 1;
        followBtn.layer.borderColor = (UIColor(red: 161/255.0, green: 36/255.0, blue: 249/255.0, alpha: 1.0)).cgColor
        followBtn.contentEdgeInsets = UIEdgeInsetsMake(5,10,5,10)
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
