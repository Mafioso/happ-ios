//
//  EventExploreLoadingCollectionViewCell.swift
//  Happ
//
//  Created by MacBook Pro on 11/29/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit
import Shimmer



class EventExploreLoadingCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var viewShimmerTitle: FBShimmeringView!
    @IBOutlet weak var viewContentTitle: UIView!
    
    @IBOutlet weak var viewShimmerInterest: FBShimmeringView!
    @IBOutlet weak var viewContentInterest: UIView!



    override func awakeFromNib() {
        super.awakeFromNib()

        viewShimmerTitle.contentView = viewContentTitle
        viewShimmerTitle.shimmering = true

        viewShimmerInterest.contentView = viewContentInterest
        viewShimmerInterest.shimmering = true
    }
    
}
