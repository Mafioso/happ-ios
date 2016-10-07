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
            self.bindToViewModel()
            self.viewModelDidUpdate()
        }
    }


    // outlets
    @IBOutlet weak var imageCover: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelCategory: UILabel!
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var labelPrice: UILabel!
    @IBOutlet weak var labelUpvotesCount: UILabel!


    // actions
    @IBAction func clickedUpvote(sender: UIButton) {
        self.viewModel.onClickLike()
    }
    @IBAction func clickedFavourite(sender: UIButton) {
        self.viewModel.onClickFavourite()
    }
    @IBAction func clickedMoreButton(sender: UIButton) {
        self.viewModel.onClickDisplayMoreActions()
    }

    // constants
    static let nibName = "EventTableCell"


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        //self.viewModelDidUpdate()
    }


    private func bindToViewModel() {
        self.viewModel.didUpdate = { [weak self] _ in
            self?.viewModelDidUpdate()
        }
    }

    func viewModelDidUpdate() {
        let event = self.viewModel.event

        labelTitle.text = event.title
        // TODO viewCategory.backgroundColor = event.type.color
        labelCategory.text = event.interests.first?.title
        labelDate.text = HappDateFormats.EventOnFeed.toString(event.start_datetime!)
        labelPrice.text = event.getPrice(.MinPrice)
        labelUpvotesCount.text = formatStatValue(event.votes_num)

        if let imageURL = event.images[0] {
            imageCover.hnk_setImageFromURL(imageURL)
        }
    }


}
