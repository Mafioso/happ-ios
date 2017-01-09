//
//  EventLoadingTableCell.swift
//  Happ
//
//  Created by MacBook Pro on 11/28/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit
import Shimmer

class EventManageLoadingTableCell: UITableViewCell {

    // constants
    static let nibName = "EventManageLoadingTableCell"
    static let estimatedHeight = CGFloat(integerLiteral: 123)

   
    @IBOutlet weak var viewShimmerTitle: FBShimmeringView!
    @IBOutlet weak var viewContentTitle: UIView!

    @IBOutlet weak var viewShimmerBottomLeftOne: FBShimmeringView!
    @IBOutlet weak var viewContentBottomLeftOne: UIView!
    
    @IBOutlet weak var viewShimmerBottomLeftTwo: FBShimmeringView!
    @IBOutlet weak var viewContentBottomLeftTwo: UIView!
    
    @IBOutlet weak var viewShimmerBottomRight: FBShimmeringView!
    @IBOutlet weak var viewContentBottomRight: UIView!
    

    override func awakeFromNib() {
        super.awakeFromNib()

        let shimmerViews = [viewShimmerTitle, viewShimmerBottomLeftOne, viewShimmerBottomLeftTwo, viewShimmerBottomRight]
        let contentViews = [viewContentTitle, viewContentBottomLeftOne, viewContentBottomLeftTwo, viewContentBottomRight]

        zip(shimmerViews, contentViews)
            .forEach { shimmer, content in
                shimmer.contentView = content
                shimmer.shimmering = true
            }

    }

}




