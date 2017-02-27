//
//  EventDatetimesTableViewCell.swift
//  Happ
//
//  Created by MacBook Pro on 2/27/17.
//  Copyright © 2017 Sattar Stamkulov. All rights reserved.
//

import UIKit

class EventDatetimesTableViewCell: UITableViewCell {

    
    @IBOutlet weak var labelDateRange: UILabel!
    @IBOutlet weak var labelTimeRange: UILabel!
    @IBOutlet weak var labelCloseOnStart: UILabel!
    @IBOutlet weak var imageCloseOnStartIcon: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
