//
//  CategoryCell.swift
//  Happ
//
//  Created by MacBook Pro on 9/27/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit

class InterestCell: UITableViewCell {
    
    // outlets
    @IBOutlet weak var imageCover: UIImageView!
    @IBOutlet weak var labelInterest: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
