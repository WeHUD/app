//
//  MyFeedsTableViewCell.swift
//  Gzone_App
//
//  Created by Tracy Sablon on 19/06/2017.
//  Copyright © 2017 Tracy Sablon. All rights reserved.
//

import UIKit

class MyFeedsTableViewCell: UITableViewCell {
     var tapAction: ((UITableViewCell) -> Void)?
     var commentAction: ((UITableViewCell) -> Void)?
    
    @IBOutlet weak var numberComment: UILabel!
    @IBAction func likePost(_ sender: Any) {
        tapAction?(self)
    }

    @IBAction func commentPost(_ sender: Any) {
        commentAction?(self)
    }
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userReplyLabel: UILabel!
    @IBOutlet weak var postDescription: UITextView!
    @IBOutlet weak var numberLike: UILabel!
    @IBOutlet weak var postDate: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var mediaImageView: UIImageView!
    @IBOutlet weak var rate1: UIImageView!
    @IBOutlet weak var rate2: UIImageView!
    @IBOutlet weak var rate3: UIImageView!
    @IBOutlet weak var rate4: UIImageView!
    @IBOutlet weak var rate5: UIImageView!
    @IBOutlet weak var likePostBtn: UIButton!
    @IBOutlet weak var commentPostBtn: UIButton!
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
