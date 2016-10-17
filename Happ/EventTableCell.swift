//
//  EventTableCell.swift
//  Happ
//
//  Created by MacBook Pro on 9/21/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit
import Haneke


enum EventColors: String {
    case A = "57ea237de93ff50030ff22ba"
    case B = "57ea237de93ff50030ff22df"
    case C = "57ea237de93ff50030ff22b2"
    case D = "57ea237de93ff50030ff22b3"
    case E = "57ea237de93ff50030ff22d4"

    func color() -> UIColor {
        var hex: String
        switch self {
        case A:
            hex = "3E3E3E"
        case B:
            hex = "7C7670"
        case C:
            hex = "0F1624"
        case D:
            hex = "7A8290"
        case E:
            hex = "DBCEBE"
        }
        return UIColor(hexString: "#"+hex)
    }
}



class EventTableCell: UITableViewCell {

    var viewModel: EventViewModel! {
        didSet {
            self.bindToViewModel()
            self.viewModelDidUpdate()
        }
    }


    // outlets
    @IBOutlet weak var imageCover: UIImageView!
    @IBOutlet weak var viewDetailsContainer: UIView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelCategory: UILabel!
    @IBOutlet weak var labelDateTime: UILabel!
    @IBOutlet weak var labelPlace: UILabel!
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
    static let estimatedHeight = CGFloat(integerLiteral: 420)


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
        labelCategory.text = event.interests.first?.title
        // TODO viewDetailsContainer.backgroundColor =
        labelPlace.text = event.address
        labelPrice.text = event.getPrice(.MinPrice)
        labelUpvotesCount.text = formatStatValue(event.votes_num)
        labelDateTime.text = "\(HappDateFormats.OnlyTime.toString(event.start_datetime!)) — \(HappDateFormats.OnlyTime.toString(event.end_datetime!))"

        if let eventColor = EventColors(rawValue: event.id) {
            viewDetailsContainer.backgroundColor = eventColor.color()
        }
        if let imageURL = event.images[0] {
            imageCover.hnk_setImageFromURL(imageURL)
        }
    }


}
