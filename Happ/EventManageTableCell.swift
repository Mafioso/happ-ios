//
//  EventCompactTableCell.swift
//  Happ
//
//  Created by MacBook Pro on 11/11/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit


struct EventManageTableCellInflator {
    enum StatusIconTypes: String {
        case Active = "icon-status-active"
        case Inactive = "icon-status-inactive"
        case OnReview = "icon-status-onreview"
        case Rejected = "icon-status-rejected"
    }
    enum StyleFilterTypes {
        case None
        case BlackAndWhite
        case Red
    }

    var status: Bool
    var statusImageIcon: StatusIconTypes?
    var statistic: Bool
    var detailsDenied: Bool
    var detailsNormal: Bool
    var styleFilter: StyleFilterTypes


    func updateCell(cell: EventManageTableCell) {
        cell.viewStatusContainer.hidden = !self.status
        if let iconType = self.statusImageIcon {
            cell.imageStatusIcon.hidden = false
            cell.imageStatusIcon.image = UIImage(named: iconType.rawValue)
        } else {
            cell.imageStatusIcon.hidden = true
        }
        cell.viewStatisticContainer.hidden = !self.statistic
        cell.viewDetailsDeniedContainer.hidden = !self.detailsDenied
        cell.viewDetailsNormalContainer.hidden = !self.detailsNormal
        switch self.styleFilter {
        case .BlackAndWhite:
            cell.viewDetailsContainer.backgroundColor = UIColor(hexString: "5C5C5C")
            cell.viewStatusBackground.backgroundColor = UIColor(hexString: "2C2C2C")
            let image = cell.imageCover.image
            let blackImage = image?.blackAndWhiteCopy()
            print("...", image, blackImage)
            cell.imageCover.image = blackImage
        case .Red:
            cell.viewDetailsContainer.backgroundColor = UIColor(hexString: "C78080")
            cell.viewStatusBackground.backgroundColor = UIColor(hexString: "9A1B1B")
            let image = cell.imageCover.image
            let blackImage = image?.blackAndWhiteCopy()
            cell.imageCover.image = blackImage
        case .None:
            break
        }
    }
}


class EventManageTableCell: UITableViewCell, UIScrollViewDelegate {

    var viewModel: EventsManageViewModel!
    
    // outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var viewContentContainer: UIView!
    @IBOutlet weak var viewDetailsContainer: UIView!
    @IBOutlet weak var viewStatisticContainer: UIView!
    @IBOutlet weak var viewStatusContainer: UIView!
    @IBOutlet weak var viewStatusBackground: UIView!
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
        self.onShowDeniedDetails?()
    }
    @IBAction func clickedActionDelete(sender: UIButton) {
        self.onDelete?()
    }
    @IBAction func clickedActionShowHide(sender: UIButton) {
        self.onShowHide?()
    }
    @IBAction func clickedActionEdit(sender: UIButton) {
        self.onEdit?()
    }


    // signals
    var onClick: (() -> Void)?
    var onShowDeniedDetails: (() -> Void)?
    var onDelete: (() -> Void)?
    var onEdit: (() -> Void)?
    var onShowHide: (() -> Void)?


    static let nibName = "EventManageTableCell"
    let sizeOfActionView = 109

    override func awakeFromNib() {
        super.awakeFromNib()

        // Initialization code
        scrollView.delegate = self
        scrollView.frame = self.bounds
        scrollView.contentSize = self.bounds.size
        scrollView.setContentOffset(CGPoint(x: self.sizeOfActionView, y: 0), animated: false)
        scrollView.scrollsToTop = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        
        // init events
        let clickEvent = UITapGestureRecognizer(target: self, action: #selector(self.handleClick))
        self.viewContentContainer.addGestureRecognizer(clickEvent)
    }

    func handleClick() {
        self.onClick?()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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



