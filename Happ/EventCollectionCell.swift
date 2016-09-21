//
//  EventCollectionCell.swift
//  Happ
//
//  Created by MacBook Pro on 9/21/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit

class EventCollectionCell: UICollectionViewCell {

    // outlets
    @IBOutlet weak var imageCover: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelCategory: UILabel!
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var labelPrice: UILabel!
    @IBOutlet weak var viewCategory: UIView!
    @IBOutlet weak var labelStatViews: UILabel!
    @IBOutlet weak var labelStatLikes: UILabel!


    // actions
    @IBAction func clickedLikeButton(sender: UIButton) {
        self.onClickLikeButton?(event: self.event!)
    }


    private var event: EventModel?
    var onClickLikeButton: ((event: EventModel) -> (Void))?
    static let nibName = "EventCollectionCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }


    func setup(event: EventModel) {
        labelTitle.text = event.title
        // TODO fetch category
        // viewCategory.backgroundColor = event.type.color
        labelCategory.text = String(event.type)
        labelDate.text = HappDateFormats.EventOnFeed.toString(event.start_datetime!)
        labelPrice.text = event.getPrice(.MinPrice)

        self.event = event
    }
    

    func preferredLayoutSizeFittingSize(targetSize: CGSize)-> CGSize {
        let originalFrame = self.frame
        let originalPreferredMaxLayoutWidth = self.labelTitle.preferredMaxLayoutWidth
        
        
        var frame = self.frame
        frame.size = targetSize
        self.frame = frame
        
        self.setNeedsLayout()
        self.layoutIfNeeded()

        // calling this tells the cell to figure out a size for it based on the current items set
        let computedSize = self.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        
        let newSize = CGSize(width:targetSize.width, height:computedSize.height)

        self.frame = originalFrame
        self.labelTitle.preferredMaxLayoutWidth = originalPreferredMaxLayoutWidth
        
        return newSize
    }
}
