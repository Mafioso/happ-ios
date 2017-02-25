//
//  EventDetailsController.swift
//  Happ
//
//  Created by Aigerim'sMac on 21.09.16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit
import MessageUI


let loc_event_age_since = NSLocalizedString("Restricted to", comment: "on Event Details since some year")
let loc_event_age_and_over = NSLocalizedString(" and over", comment: "final part on Event Details since some year")
let loc_event_age_range = NSLocalizedString("For an audience of", comment: "on Event Details range of suitable ages")
let loc_to = NSLocalizedString("to", comment: "to word")
let loc_years = NSLocalizedString("years", comment: "years word")


class EventDetailsController: UIViewController {

    var viewModel: EventViewModel! {
        didSet {
            self.bindToViewModel()
        }
    }


    // outlets
    @IBOutlet weak var imageBackground: UIImageView!
    @IBOutlet weak var pageControllImages: UIPageControl!
    @IBOutlet weak var viewImagesPlaceholder: UIView!

    @IBOutlet weak var viewContainerTitle: UIView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelPriceMinimum: UILabel!
    @IBOutlet weak var labelDateRange: UILabel!
    @IBOutlet weak var labelLocation: UILabel!
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var labelAuthorName: UILabel!
    @IBOutlet weak var labelAuthorDetails: UILabel!
    @IBOutlet weak var imageAuthorPhoto: UIImageView!

    @IBOutlet weak var buttonInfoDate: UIButton!
    @IBOutlet weak var viewHighlightInfoPrice: UIView!
    @IBOutlet weak var buttonInfoPrice: UIButton!
    @IBOutlet weak var buttonInfoLocation: UIButton!
    @IBOutlet weak var viewHighlightInfoLocation: UIView!
    @IBOutlet weak var buttonUpvote: UIButton!
    @IBOutlet weak var buttonWantToGo: UIButton!

    @IBOutlet weak var viewInterests: UIView!
    @IBOutlet weak var viewContainerInterests: UIView!
    @IBOutlet weak var collectionViewInterests: UICollectionView!

    @IBOutlet weak var labelAgeRange: UILabel!

    @IBOutlet weak var tableViewInfo: UITableView!

    // actions
    @IBAction func clickedBackNavItem(sender: UIButton) {
        self.viewModel.navigateBack?()
    }
    @IBAction func clickedWantToGoButton(sender: UIButton) {
        self.viewModel.onFavourite()
    }
    @IBAction func clickedUpvote(sender: UIButton) {
        self.viewModel.onLike()
    }
    @IBAction func clickedLocationButton(sender: UIButton) {
        self.viewModel.onClickOpenMap()
    }
    @IBAction func clickedPriceButton(sender: UIButton) {
        self.openWebPage()
    }
    @IBAction func clickedDateRangeButton(sender: UIButton) {
    }
    @IBAction func clickedExpandImages(sender: UIButton) {
    }
    @IBAction func clickedShareButton(sender: UIButton) {
        self.shareEvent()
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionViewInterests.dataSource = self
        self.collectionViewInterests.delegate = self

        self.tableViewInfo.dataSource = self
        self.tableViewInfo.delegate = self

        [buttonUpvote, buttonWantToGo].forEach { btn in
            btn.imageEdgeInsets.right = 12
        }

    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.viewModelDidUpdate()

        self.extMakeStatusBarWhite()
        self.extMakeNavBarHidden()

        self.animateInfo()
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        self.extMakeStatusBarDefault()
        self.extMakeNavBarVisible()
    }
    override func viewDidLayoutSubviews() {
        [buttonInfoDate, buttonInfoPrice, buttonInfoLocation]
            .forEach { $0.extMakeCircle() }
        [viewHighlightInfoPrice, viewHighlightInfoLocation]
            .forEach { $0.extMakeCircle() }
        [buttonUpvote, buttonWantToGo]
            .forEach { $0.extMakeCircle() }

        var frame = viewInterests.frame
        frame.size.height = collectionViewInterests.frame.size.height
        viewInterests.frame = frame
        viewInterests.layoutIfNeeded()
    }


    func viewModelDidUpdate() {
        guard let event = self.viewModel.event else { return }
        var color = UIColor.happBlackQuarterTextColor()

        // TODO: change to images slider
        pageControllImages.currentPage = 0
        pageControllImages.numberOfPages = event.images.count

        viewImagesPlaceholder.hidden = false
        if let image = event.images.first {
            imageBackground.hnk_setImageFromURL(
                image.getURL()!,
                success: { img in
                    self.imageBackground.image = img
                    self.viewImagesPlaceholder.hidden = true
            })
            imageBackground.layer.masksToBounds = true

            if let colorCode = image.color {
                color = UIColor(hexString: colorCode)
            }
        }

        [viewContainerTitle, buttonUpvote, buttonInfoDate, buttonInfoPrice, buttonInfoLocation].forEach { $0.backgroundColor = color }
        [viewHighlightInfoLocation, viewHighlightInfoPrice].forEach { v in v.backgroundColor = color; v.alpha = 0.2; }
        [labelPriceMinimum, labelLocation, labelDateRange].forEach { $0.textColor = color }

        labelTitle.text = event.title
        labelDescription.text = event.description_text
        labelAuthorDetails.text = event.author?.fn

        // TODO
        labelDateRange.text = HappEventDateFormats.EventDetails(first_datetime: event.datetimes.first!, last_datetime: event.datetimes.last!).toString()
        labelLocation.text = event.address
        labelPriceMinimum.text = HappEventPriceFormats.EventPriceRange(event: event).toString()

        buttonUpvote.setTitle(String(event.votes_num), forState: .Normal)
        buttonUpvote.selected = event.is_upvoted

        buttonWantToGo.selected = event.is_in_favourites
        buttonWantToGo.backgroundColor = event.is_in_favourites ? color : UIColor.happOrangeColor()

        viewContainerInterests.backgroundColor = color
        
        if  let defaultMaxAge = DefaultParameters.getValue(.MaxAge) as? Int where
            event.max_age == defaultMaxAge
        {
            labelAgeRange.text = loc_event_age_since + " \(event.min_age)" + loc_event_age_and_over
        } else {
            labelAgeRange.text = loc_event_age_range + " \(event.min_age) " + loc_to + " \(event.max_age) " + loc_years
        }
        labelAgeRange.textColor = color
    }

    private func bindToViewModel() {
        self.viewModel.didUpdate = { [weak self] _ in
            self?.viewModelDidUpdate()
        }
    }

    func animateInfo() {
        var trans: [UIView] = []
        trans.append(viewHighlightInfoLocation)
        if self.viewModel.event.web_site != nil {
            trans.append(self.viewHighlightInfoPrice)
        }
        UIView.animate(duration: 1, delay: 0, options: [UIViewAnimationOptions.Repeat, UIViewAnimationOptions.Autoreverse],
                       animations: { [unowned self] in
                        trans.forEach { $0.transform = CGAffineTransformMakeScale(1.2, 1.2) }
            })
    }

}


extension EventDetailsController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let event = self.viewModel.event
        return event.interests.count + 3
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! EventInterestCollectionViewCell
        let event = self.viewModel.event
        let interest = event.interests[ 0]//indexPath.row]

        cell.title.text = interest.title
        if let image = interest.parent?.image {
            if let url = image.getURL() {
                cell.image.hnk_setImageFromURL(url)
            }
            if let color = image.color {
                cell.viewContainer.backgroundColor = UIColor(hexString: color)
            }
        }
        cell.image.extMakeCircle()
        cell.viewContainer.extMakeCircle()

        switch indexPath.row {
        case 1:
            cell.title.text = interest.title + "ASD"
        case 2:
            cell.title.text = interest.title + "ASDASD"
        default:
            break
        }
        
        return cell
    }
}

extension EventDetailsController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.event_info_types().count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        let info_type = self.viewModel.event_info_types()[indexPath.row]
        let info_type_icon = info_type.icon()

        // clear
        cell.viewWithTag(222)?.removeFromSuperview()
        cell.textLabel?.text = ""

        // add
        let icon = UIImage(named: info_type_icon)
        let iconView = UIImageView(image: icon)
        iconView.frame = CGRect(x: 36, y: 13, width: 20, height: 20)
        iconView.tag = 222
        cell.addSubview(iconView)

        cell.textLabel?.text = self.viewModel.event_info(info_type)!.lowercaseString

        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        let info_type = self.viewModel.event_info_types()[indexPath.row]
        switch info_type {
        case .Site:
            self.openWebPage()
        case .Email:
            self.sendEmail()
        case .Phone:
            self.dialPhone()
        }
    }

}


extension EventDetailsController: MFMailComposeViewControllerDelegate {

    // EMAIL TO
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    func sendEmail() {
        let event = self.viewModel.event
        let user = ProfileService.getUserProfile()

        let receipants = self.getReceipientsAddresses()
        let subject = "I have question by \(event.title)"
        let body = "Hi, my name is \(user.fullname)."
        
        let email = EmailSenderCompose.Simple(subject: subject, body: body, receipants: receipants)
        self.extMailComposeController(sendEmail: email)
    }
    private func getReceipientsAddresses() -> [String] {
        if let email = self.viewModel.event_info(.Email) {
            return [email]
        } else {
            return []
        }
    }

    // CALL TO
    func dialPhone() {
        let number = self.viewModel.event_info(.Phone)!
        let parsed = Utils.parsePhoneNumber(number)
        let tel = NSURL(string: "tel://\(parsed)")!
        UIApplication.sharedApplication().openURL(tel)
    }

    // OPEN SITE
    func openWebPage() {
        guard let url = self.viewModel.event_info(.Site) else { return }
        self.viewModel.openWebPage!(url: url)
    }


    // SHARE
    func shareEvent() {
        let event = self.viewModel.event
        let textToShare = event.title
        guard let imageURL = event.images.first!.getURL() else { return }

        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let imageToShare = UIImage(data: NSData(contentsOfURL: imageURL)!)!

            let objectsToShare: [AnyObject] = [imageToShare, textToShare]
            var excludeTypes: [String] = [UIActivityTypeAddToReadingList, UIActivityTypePostToVimeo]
            if #available(iOS 9.0, *) {
                excludeTypes.append(UIActivityTypeOpenInIBooks)
            }

            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityVC.excludedActivityTypes = excludeTypes
            activityVC.popoverPresentationController?.sourceView = self.view
            self.presentViewController(activityVC, animated: true, completion: nil)
        })
    }
}


