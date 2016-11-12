//
//  EventCompactTableCell.swift
//  Happ
//
//  Created by MacBook Pro on 11/11/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit

class EventCompactTableCell: UITableViewCell {

    
    // outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var viewDetailsContainer: UIView!
    @IBOutlet weak var viewStatisticContainer: UIView!
    @IBOutlet weak var viewStatusContainer: UIView!
    @IBOutlet weak var viewDetailsNormalContainer: UIView!
    @IBOutlet weak var viewDetailsDeniedContainer: UIView!

    @IBOutlet weak var imageCover: UIImageView!
    @IBOutlet weak var labelUpvoteCount: UILabel!
    @IBOutlet weak var imageUpvoteIcon: UIImageView!
    @IBOutlet weak var labelFavCount: UILabel!
    @IBOutlet weak var imageFavIcon: UIImageView!
    @IBOutlet weak var imageStatusIcon: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelInterest: UILabel!
    @IBOutlet weak var labelAddress: UILabel!
    @IBOutlet weak var labelDateTime: UILabel!
    @IBOutlet weak var labelPrice: UILabel!
    @IBOutlet weak var buttonActionShowHide: UIButton!


    // actions
    @IBAction func clickedShowDeniedDetails(sender: UIButton) {
        
    }
    @IBAction func clickedActionDelete(sender: UIButton) {
    }
    @IBAction func clickedActionShowHide(sender: UIButton) {
    }
    @IBAction func clickedActionEdit(sender: UIButton) {
    }

    

    static let nibName = "EventCompactTableCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        /*
        scrollView.contentSize = self.bounds.size
        scrollView.contentInset = UIEdgeInsetsMake(0, 160, 0, 0)
        scrollView.scrollsToTop = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        */
        //scrollView.delegate = self
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
