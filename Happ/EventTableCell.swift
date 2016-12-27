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

    var viewModel: EventViewModel! {
        didSet {
            self.updateView()
        }
    }


    // outlets
    @IBOutlet weak var imageCover: UIImageView!
    @IBOutlet weak var viewImagePlaceholder: UIView!
    @IBOutlet weak var viewDetailsContainer: UIView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelCategory: UILabel!
    @IBOutlet weak var labelDateTime: UILabel!
    @IBOutlet weak var labelPlace: UILabel!
    @IBOutlet weak var labelPrice: UILabel!
    @IBOutlet weak var labelUpvotesCount: UILabel!
    @IBOutlet weak var buttonUpvote: UIButton!
    @IBOutlet weak var buttonFavourite: UIButton!


    // actions
    @IBAction func clickedUpvote(sender: UIButton) {
        self.viewModel.onLike()
    }
    @IBAction func clickedFavourite(sender: UIButton) {
        self.viewModel.onFavourite()
    }
    @IBAction func clickedMoreButton(sender: UIButton) {
        self.viewModel.onClickDisplayMoreActions()
    }

    // constants
    static let nibName = "EventTableCell"
    static let estimatedHeight = CGFloat(integerLiteral: 420)


    func updateView() {
        let event = self.viewModel.event

        labelTitle.text = event.title
        labelCategory.text = event.interests.first?.title
        labelPlace.text = event.address
        labelPrice.text = HappEventPriceFormats.EventMinPrice(event: event).toString()
        labelUpvotesCount.text = formatStatValue(event.votes_num)
        labelDateTime.text = HappEventDateFormats.EventTimeRange(datetime: event.datetimes.first!).toString()
        buttonUpvote.titleLabel!.text = String(event.votes_num)
        buttonUpvote.selected = event.is_upvoted
        buttonFavourite.selected = event.is_in_favourites

        viewImagePlaceholder.hidden = false
        if let image = event.images.first {
            if let url = image.getURL() {
                imageCover.hnk_setImageFromURL(
                    url,
                    success: { img in
                        self.imageCover.image = img
                        self.viewImagePlaceholder.hidden = true
                })
                imageCover.layer.masksToBounds = true
            }
            if let color = image.color {
               viewDetailsContainer.backgroundColor = UIColor(hexString: color)
            }
        }

    }

}
