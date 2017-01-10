//
//  EventCompactTableCell.swift
//  Happ
//
//  Created by MacBook Pro on 11/11/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit
import Haneke

class EventManageTableCell: UITableViewCell, UIScrollViewDelegate {

    var event: EventModel! {
        didSet {
            self.updateView()
        }
    }
    
    var iconTypes: [EventModelStatusTypes:String] = [
        .OnReview: "icon-status-onreview",
        .Active: "icon-status-active",
        .Rejected: "icon-status-rejected",
        .Inactive: "icon-status-inactive"
    ]
    
    func updateView() {
        labelTitle.text = event.title
        labelInterest.text = event.interests.first?.title
        labelPrice.text = HappEventPriceFormats.EventPriceRangeWithoutBreak(event: event).toString()
        labelAddress.text = event.address
        labelUpvoteCount.text = "\(event.votes_num)"
        labelFavCount.text = "\(event.views_count)"
        labelDateTime.text = HappEventDateFormats.EventManage(first_datetime: event.datetimes.first, last_datetime: event.datetimes.last).toString()
        
        imageCover.image = nil
        scrollView.backgroundColor = UIColor.happBlackHalfTextColor()
        if let image = event.images.first {
            if let url = image.getURL() {
                imageCover.image = nil
                imageCover.hnk_setImageFromURL(
                    url,
                    success: { img in
                        self.imageCover.image = self.event.getStatus() == .Rejected || self.event.getStatus() == .Finished ? img.blackAndWhiteCopy() : img
                })
                imageCover.layer.masksToBounds = true
            }
            if let color = image.color {
                scrollView.backgroundColor = UIColor(hexString: color)
            }
        }
        
        if let iconType = iconTypes[event.getStatus(activated)] {
            imageStatusIcon.hidden = false
            imageStatusIcon.image = UIImage(named: iconType)
        } else {
            imageStatusIcon.hidden = true
        }
        
        switch event.getStatus(activated) {
            case .Finished:
                scrollView.backgroundColor = UIColor(hexString: "2C2C2C")
            case .Rejected:
                scrollView.backgroundColor = UIColor(hexString: "C33838")
                viewDetailsNormalContainer.hidden = true
                viewDetailsDeniedContainer.hidden = false
            default: break
        }
    }
    
    // outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var viewContentContainer: UIView!
    @IBOutlet weak var viewDetailsContainer: UIView!
    @IBOutlet weak var viewStatisticContainer: UIView!
    @IBOutlet weak var viewStatusContainer: UIView!
    @IBOutlet weak var viewStatusBackground: UIView!
    @IBOutlet weak var viewDetailsNormalContainer: UIView!
    @IBOutlet weak var viewDetailsDeniedContainer: UIView!
    @IBOutlet weak var viewWidth: NSLayoutConstraint!

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
    @IBOutlet weak var buttonActionActivateDeactivate: UIButton!
    @IBOutlet weak var indicatorActivateDeactivate: UIActivityIndicatorView!
    @IBOutlet weak var indicatorDelete: UIActivityIndicatorView!
    @IBOutlet weak var indicatorCopy: UIActivityIndicatorView!

    // actions
    @IBAction func clickedShowDeniedDetails(sender: UIButton) {
        self.onShowDeniedDetails?()
    }
    
    @IBAction func clickedActionDelete(sender: UIButton) {
        self.onDelete?()
    }
    
    @IBAction func clickedActionActivateDeactivate(sender: UIButton) {
        self.onActivateDeactivate?()
    }
    
    @IBAction func clickedActionEdit(sender: UIButton) {
        self.onEdit?()
    }
    
    @IBAction func clickedActionCopy(sender: UIButton) {
        self.onCopy?()
    }

    // signals
    var onClick: (() -> Void)?
    var onShowDeniedDetails: (() -> Void)?
    var onDelete: (() -> Void)?
    var onEdit: (() -> Void)?
    var onActivateDeactivate: (() -> Void)?
    var onCopy: (() -> Void)?

    static let nibName = "EventManageTableCell"
    static let estimatedHeight = CGFloat(integerLiteral: 123)
    let sizeOfActionView = 109
    var activated = true {
        didSet {
            UIView.animateWithDuration(0.33, animations: {
                if self.activated {
                    self.buttonActionActivateDeactivate.setTitle("DEACTIVATE", forState: .Normal)
                    self.buttonActionActivateDeactivate.backgroundColor = UIColor(hexString: "BFBFBF")
                    self.indicatorActivateDeactivate.backgroundColor = UIColor(hexString: "BFBFBF")
                }else{
                    self.buttonActionActivateDeactivate.setTitle("ACTIVATE", forState: .Normal)
                    self.buttonActionActivateDeactivate.backgroundColor = UIColor(hexString: "5F902C")
                    self.indicatorActivateDeactivate.backgroundColor = UIColor(hexString: "5F902C")
                }
            })
            dispatch_after(dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), Int64(NSEC_PER_SEC/3)), dispatch_get_main_queue()) {
                self.indicatorActivateDeactivate.stopAnimating()
                self.updateView()
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        scrollView.delegate = self
        scrollView.frame = self.bounds
        scrollView.contentSize = self.bounds.size
        scrollView.setContentOffset(CGPoint(x: self.sizeOfActionView, y: 0), animated: false)
        scrollView.scrollsToTop = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        
        viewWidth.constant = ScreenSize.SCREEN_WIDTH
        
        let clickEvent = UITapGestureRecognizer(target: self, action: #selector(self.handleClick))
        self.viewContentContainer.addGestureRecognizer(clickEvent)
    }

    func handleClick() {
        self.onClick?()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let leftBound = CGFloat(self.sizeOfActionView / 2)
        let rightBound = CGFloat(self.sizeOfActionView) * 1.5

        if scrollView.contentOffset.x < leftBound {
            targetContentOffset.initialize(CGPoint(x: 0, y: 0))

        } else if scrollView.contentOffset.x > rightBound {
            targetContentOffset.initialize(CGPoint(x: CGFloat(self.sizeOfActionView * 2), y: 0))

        } else {
            targetContentOffset.initialize(CGPoint(x: self.sizeOfActionView, y: 0))
        }
    }
}
