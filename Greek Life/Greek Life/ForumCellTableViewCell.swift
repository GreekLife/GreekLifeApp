//
//  ForumCellTableViewCell.swift
//  Greek Life
//
//  Created by Jonah Elbaz on 2017-10-29.
//  Copyright © 2017 ConcordiaDev. All rights reserved.
//

import UIKit

class ForumCellTableViewCell: UITableViewCell {
    
    @IBOutlet weak var PostCommentList: UIButton!
    @IBOutlet weak var PostTitle: UILabel!
    @IBOutlet weak var Post: UITextView!
    @IBOutlet weak var PosterName: UILabel!
    @IBOutlet weak var PosterImage: UIImageView!
    @IBOutlet weak var PostDate: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

