//
//  PollTableViewCell.swift
//  Greek Life
//
//  Created by Jonah Elbaz on 2017-11-13.
//  Copyright © 2017 ConcordiaDev. All rights reserved.
//

import UIKit

class PollTableViewCell: UITableViewCell {
    
    @IBOutlet weak var Poster: UILabel!
    @IBOutlet weak var Poll: UILabel!
    @IBOutlet weak var PollDate: UILabel!
    
    @IBOutlet weak var PollOption1: UILabel!
    @IBOutlet weak var PollOption2: UILabel!
    @IBOutlet weak var PollOption3: UILabel!
    @IBOutlet weak var PollOption4: UILabel!
    @IBOutlet weak var PollOption5: UILabel!
    @IBOutlet weak var PollOption6: UILabel!
    
    @IBOutlet weak var PollNumbers1: UIButton!
    @IBOutlet weak var PollNumbers2: UIButton!
    @IBOutlet weak var PollNumbers3: UIButton!
    @IBOutlet weak var PollNumbers4: UIButton!
    @IBOutlet weak var PollNumbers5: UIButton!
    @IBOutlet weak var PollNumbers6: UIButton!
    
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
