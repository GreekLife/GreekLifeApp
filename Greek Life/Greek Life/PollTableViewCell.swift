//
//  PollTableViewCell.swift
//  Greek Life
//
//  Created by Jonah Elbaz on 2017-11-13.
//  Copyright © 2017 ConcordiaDev. All rights reserved.
//

import UIKit

class PollTableViewCell: UITableViewCell {
    
    @IBOutlet weak var PollerPicture: UIImageView!
    @IBOutlet weak var Poster: UILabel!
    @IBOutlet weak var Poll: UITextView!
    @IBOutlet weak var PollDate: UILabel!
    
    @IBOutlet weak var PollOptionDefault: UITextView!
    @IBOutlet weak var PollVotesDefault: UIButton!
    
    @IBOutlet weak var PollResults: UIButton!
    @IBOutlet weak var SendReminder: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
