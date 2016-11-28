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
            // self.bindToViewModel()
            self.viewModelDidUpdate()
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


/*
    private func bindToViewModel() {
        let superViewModel = self.viewModel.didUpdate
        self.viewModel.didUpdate = { [weak self] _ in
            superViewModel?()
            self?.viewModelDidUpdate()
        }
    }
*/
    func viewModelDidUpdate() {
        let event = self.viewModel.event

        labelTitle.text = event.title
        labelCategory.text = event.interests.first?.title
        labelPlace.text = event.address
        labelPrice.text = event.getPrice(.MinPrice)
        labelUpvotesCount.text = formatStatValue(event.votes_num)
        labelDateTime.text = "\(HappDateFormats.OnlyTime.toString(event.start_datetime!)) — \(HappDateFormats.OnlyTime.toString(event.end_datetime!))"

        buttonUpvote.titleLabel!.text = String(event.votes_num)
        buttonUpvote.selected = event.is_upvoted
        buttonFavourite.selected = event.is_in_favourites

        if let color = event.color {
            viewDetailsContainer.backgroundColor = UIColor(hexString: color)
        }

        viewImagePlaceholder.hidden = false
        if let imageURL = event.images.first?.getURL() {
            imageCover.hnk_setImageFromURL(
                imageURL,
                success: { img in
                    self.imageCover.image = img
                    self.viewImagePlaceholder.hidden = true
            })
            imageCover.layer.masksToBounds = true
        }
    }


}
