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
}
