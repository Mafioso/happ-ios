//
//  EventDetailsController.swift
//  Happ
//
//  Created by Aigerim'sMac on 21.09.16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit
import MessageUI


class EventDetailsController: UIViewController {

    var viewModel: EventViewModel! {
        didSet {
            self.bindToViewModel()
        }
    }


    // outlets
    @IBOutlet weak var imageBackground: UIImageView!
    @IBOutlet weak var pageControllImages: UIPageControl!

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
    @IBOutlet weak var buttonUpvote: UIButton!
    @IBOutlet weak var buttonWantToGo: UIButton!

    @IBOutlet weak var tableViewInfo: UITableView!

    // actions
    @IBAction func clickedBackNavItem(sender: UIButton) {
        self.viewModel.navigateBack?()
    }
    @IBAction func clickedWantToGoButton(sender: UIButton) {
    }
    @IBAction func clickedUpvote(sender: UIButton) {
    }
    @IBAction func clickedLocationButton(sender: UIButton) {
        self.viewModel.onClickOpenMap()
    }
    @IBAction func clickedPriceButton(sender: UIButton) {
        
    }
    @IBAction func clickedDateRangeButton(sender: UIButton) {
    }
    @IBAction func clickedExpandImages(sender: UIButton) {
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        self.hidesBottomBarWhenPushed = true

        self.tableViewInfo.dataSource = self
        self.tableViewInfo.delegate = self
        
        self.viewModelDidUpdate()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.extMakeStatusBarWhite()
        self.extMakeNavBarHidden()
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        self.extMakeStatusBarDefault()
        self.extMakeNavBarVisible()
    }
    override func viewDidLayoutSubviews() {
        [buttonInfoDate, buttonInfoPrice, buttonInfoLocation, viewHighlightInfoPrice]
            .forEach { $0.extMakeCircle() }
        [buttonUpvote, buttonWantToGo]
            .forEach { $0.extMakeCircle() }
    }


    func viewModelDidUpdate() {
        if viewModel.event == nil {
            return
        }

        let event = self.viewModel.event
        let color = event.color != nil ? UIColor(hexString: event.color!) : view.backgroundColor
        
        // TODO: change to images slider
        if let image = event.images[0] {
            imageBackground.hnk_setImageFromURL(image)
        }
        pageControllImages.currentPage = 0
        pageControllImages.numberOfPages = 1

        [viewContainerTitle, buttonUpvote, buttonInfoDate, buttonInfoPrice, buttonInfoLocation].forEach { $0.backgroundColor = color }
        [labelPriceMinimum, labelLocation, labelDateRange].forEach { $0.textColor = color }

        labelTitle.text = event.title
        labelDescription.text = event.description_text
        // TODO
        labelDateRange.text = HappDateFormats.EventOnFeed.toString(event.start_datetime!)
        labelLocation.text = event.address
        labelPriceMinimum.text = event.getPrice(.MinPrice)

        buttonUpvote.titleLabel?.text = String(event.votes_num)
        buttonUpvote.selected = event.is_upvoted
        if event.is_in_favourites {
            buttonWantToGo.selected = true
            buttonWantToGo.backgroundColor = color
        } else {
            buttonWantToGo.selected = false
            buttonWantToGo.backgroundColor = UIColor.happOrangeColor()
        }
    }

    private func bindToViewModel() {
        self.viewModel.didUpdate = { [weak self] _ in
            self?.viewModelDidUpdate()
        }
    }


}


extension EventDetailsController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        let event = self.viewModel.event
        var text: String? = nil
        var iconName: String?

        switch indexPath.row {
        case 0:
            text = event.web_site
            iconName = "icon-web"
        case 1:
            text = event.email
            iconName = "icon-email"
        case 2:
            text = event.phones.first
            iconName = "icon-phone"
        default:
            break
        }

        // clear
        cell.viewWithTag(924)?.removeFromSuperview()
        cell.textLabel?.text = ""

        // add
        if iconName != nil {
            let icon = UIImage(named: iconName!)
            let iconView = UIImageView(image: icon)
            iconView.frame = CGRect(x: 36, y: 13, width: 20, height: 20)
            iconView.tag = 924
            cell.addSubview(iconView)
        }
        cell.textLabel?.text = (text == nil || text!.isEmpty) ? "NO DATA" : text!.uppercaseString

        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.row {
        case 0:
            self.openWebPage()
        case 1:
            self.sendEmail()
        case 2:
            self.dialPhone()
        default:
            break
        }
    }

}


extension EventDetailsController: MFMailComposeViewControllerDelegate {

    // EMAIL TO
    func sendEmail() {
        let emails = self.getReceipientsAddresses()
        if emails.isEmpty {
            return
        }

        let event = self.viewModel.event
        let user = ProfileService.getUserProfile()
        let subject = "I have question by \(event.title)"
        let body = "Hi, my name is \(user.fullname)."


        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(self.getReceipientsAddresses())
            mail.setSubject(subject)
            mail.setMessageBody("<p>\(body).</p> <br/>", isHTML: true)

            self.presentViewController(mail, animated: true, completion: nil)

        } else {
            let params = [
                "subject": subject,
                "body": body
            ]

            let query = params.map { NSURLQueryItem(name: $0.0, value: $0.1) }
            let mailTo = NSURLComponents(string: "mailto:\(emails.first!)")!
            mailTo.queryItems = query
            let mailToURL = mailTo.URL!

            UIApplication.sharedApplication().openURL(mailToURL)
        }
    }
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    private func getReceipientsAddresses() -> [String] {
        if let email = self.viewModel.event.email {
            return [email]
        } else {
            return []
        }
    }

    // CALL TO
    func dialPhone() {
        if let number = self.viewModel.event.phones.first {
            let tel = NSURL(string: "tel://\(number)")!
            UIApplication.sharedApplication().openURL(tel)
        }
    }

    // OPEN SITE
    func openWebPage() {
        if let url = self.viewModel.event.web_site {
            // TODO
            UIApplication.sharedApplication().openURL(NSURL(string: url)!)
        }
    }
    
}


