//
//  ChatTableCell.swift
//  Happ
//
//  Created by Aleksei Pugachev on 2/19/17.
//  Copyright © 2017 Sattar Stamkulov. All rights reserved.
//

import UIKit

class ChatTableCell: UITableViewCell {
    
    static let nibName = "ChatTableCell"
    static let estimatedHeight = CGFloat(integerLiteral: 80)

    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var newMessages: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatar.extRoundCorners([.AllCorners], radius: 28)
        newMessages.extRoundCorners([.AllCorners], radius: 5)
    }
    
}
