//
//  EventDetailsController.swift
//  Happ
//
//  Created by Aigerim'sMac on 21.09.16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit

class EventDetailsController: UIViewController {

    var viewModel: EventViewModel! {
        didSet {
            self.bindToViewModel()
        }
    }


    // outlets
    @IBOutlet weak var imageBackground: UIImageView!

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
    @IBAction func clickedWantToGoButton(sender: UIButton) {
    }
    @IBAction func clickedUpvote(sender: UIButton) {
    }



    override func viewDidLoad() {
        super.viewDidLoad()

        self.initNavigationBarItems()
        self.tableViewInfo.dataSource = self

        self.viewModelDidUpdate()
    }
    override func viewDidLayoutSubviews() {
        [buttonInfoDate, buttonInfoPrice, buttonInfoLocation, viewHighlightInfoPrice]
            .forEach { circle in
                circle.layer.cornerRadius = 0.5 * circle.bounds.size.width
                circle.layer.borderWidth = 0.0
                circle.clipsToBounds = true
        }
        [buttonUpvote, buttonWantToGo]
            .forEach { button in
                button.layer.cornerRadius = 20
                button.layer.masksToBounds = true
        }
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.extMakeStatusBarWhite()
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        self.extMakeStatusBarDefault()
    }


    func viewModelDidUpdate() {
        if let event = viewModel.event {

            if let image = event.images[0] {
                imageBackground.hnk_setImageFromURL(image)
            }
            if let eventColor = EventColors(rawValue: event.id)?.color() {
                [viewContainerTitle, buttonUpvote, buttonInfoDate, buttonInfoPrice, buttonInfoLocation].forEach { view in
                    view.backgroundColor = eventColor
                }
                [labelPriceMinimum, labelLocation, labelDateRange].forEach { label in
                    label.textColor = eventColor
                }
            }

            labelTitle.text = event.title
            labelDescription.text = event.description_text
            // TODO
            labelDateRange.text = HappDateFormats.EventOnFeed.toString(event.start_datetime!)
            labelLocation.text = event.address
            labelPriceMinimum.text = event.getPrice(.MinPrice)
        }
    }

    private func bindToViewModel() {
        self.viewModel.didUpdate = { [weak self] _ in
            self?.viewModelDidUpdate()
        }
    }


    private func initNavigationBarItems() {
        let navBarBack = HappNavBarItem(position: .Left, icon: "nav-arrow-back")
        navBarBack.button.addTarget(self, action: #selector(handleClickNavBarBack), forControlEvents: .TouchUpInside)
        self.view.addSubview(navBarBack)

        let navBarFavourite = HappNavBarItem(position: .Right, icon: "icon-star-shadow")
        navBarFavourite.button.addTarget(self, action: #selector(handleClickNavBarFavourite), forControlEvents: .TouchUpInside)
        self.view.addSubview(navBarFavourite)
    }
    func handleClickNavBarFavourite() {
        // todo
    }
    func handleClickNavBarBack() {
        self.viewModel.navigateBack?()
    }
}


extension EventDetailsController: UITableViewDataSource {

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        let event = self.viewModel.event
        var text: String?
        var iconName: String?

        switch indexPath.row {
        case 0:
            text = event?.web_site
            iconName = "icon-web"
        case 1:
            text = event?.email
            iconName = "icon-email"
        case 2:
            text = event?.phones.first
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
        cell.textLabel?.text = text?.uppercaseString

        return cell
    }

}




