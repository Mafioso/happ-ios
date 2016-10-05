//
//  EventTableCell.swift
//  Happ
//
//  Created by MacBook Pro on 9/21/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit
import Haneke



class EventTableCell: UITableViewCell {

    // outlets

    @IBOutlet weak var imageCover: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelCategory: UILabel!
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var labelPrice: UILabel!
    @IBOutlet weak var labelStatViews: UILabel!


    // actions
    @IBAction func clickedLikeButton(sender: UIButton) {
        self.onClickLikeButton?(event: self.event!)
    }


    static let nibName = "EventTableCell"
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
        labelCategory.text = event.interests.first?.title
        labelDate.text = HappDateFormats.EventOnFeed.toString(event.start_datetime!)
        labelPrice.text = event.getPrice(.MinPrice)
        labelStatViews.text = formatStatValue(event.votes_num)

        if let imageURL = event.images[0] {
            imageCover.hnk_setImageFromURL(imageURL)
        }

        self.event = event
    }

}
