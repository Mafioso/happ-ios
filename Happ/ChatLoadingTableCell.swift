//
//  ChatLoadingTableCell.swift
//  Happ
//
//  Created by Aleksei Pugachev on 2/19/17.
//  Copyright © 2017 Sattar Stamkulov. All rights reserved.
//

import UIKit
import Shimmer

class ChatLoadingTableCell: UITableViewCell {
    
    static let nibName = "ChatLoadingTableCell"
    static let estimatedHeight = CGFloat(integerLiteral: 80)
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var nameWrapper: FBShimmeringView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var messageWrapper: FBShimmeringView!
    @IBOutlet weak var message: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatar.extRoundCorners([.AllCorners], radius: 28)
        
        let shimmerViews = [nameWrapper, messageWrapper]
        let contentViews = [name, message]
        
        zip(shimmerViews, contentViews).forEach { shimmer, content in
                shimmer.contentView = content
                shimmer.shimmering = true
        }
        
    }
    
}
