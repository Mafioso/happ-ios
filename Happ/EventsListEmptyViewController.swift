
//
//  EventsListEmptyVViewController.swift
//  Happ
//
//  Created by MacBook Pro on 11/27/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit

let loc_favourite = NSLocalizedString("Favourite", comment: "Title of NavBar for one of EventsListViewController")
let loc_feed = NSLocalizedString("Feed", comment: "Title of NavBar for one of EventsListViewController")
let loc_my_events = NSLocalizedString("My Events", comment: "Title of NavBar for one of EventsListViewController")
let loc_empty_list_help_favourite = NSLocalizedString("You don’t have any favourited event", comment: "Help message displayed when there is no events in Favourites")
let loc_empty_list_help_feed = NSLocalizedString("There are no events for selected interests", comment: "Help message displayed when there is no events in Feed")
let loc_empty_list_help_my_events = NSLocalizedString("You have not created any event yet", comment: "Help message displayed when there is no events in My Events")
let loc_empty_list_action_favourite = NSLocalizedString("Find Awesome Events", comment: "Title of button displayed when there is no events in Favourites")
let loc_empty_list_action_feed = NSLocalizedString("Add More Interests", comment: "Title of button displayed when there is no events in Feed")
let loc_empty_list_action_my_events = NSLocalizedString("Add First Event", comment: "Title of button displayed when there is no events in My Events")


enum EventsEmptyListScope {
    case Feed
    case Favourite
    case MyEvents
}


protocol EventsEmptyListDelegate {
    func eventsEmptyList(clickAction sender: UIButton)
    func eventsEmptyList(clickNavItemLeft sender: UIButton)
    func eventsEmptyList(clickNavItemRight sender: UIButton)
}

protocol EventsEmptyListDataSource {
    func getScope() -> EventsEmptyListScope
}


class EventsListEmptyViewController: UIViewController, EventsListDelegate {
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var buttonAction: UIButton!
    
    @IBAction func clickedActionButton(sender: UIButton) {
        self.delegate.eventsEmptyList(clickAction: sender)
    }


    var delegate:   EventsEmptyListDelegate!
    var dataSource: EventsEmptyListDataSource!


    override func viewDidLoad() {
        super.viewDidLoad()

        self.extMakeNavBarWhite()
        self.initNavBarItems()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        buttonAction.extMakeCircle()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        buttonAction.setTitle(self.getActionTitle(), forState: .Normal)
        buttonAction.setImage(self.getActionIcon(), forState: .Normal)
        labelDescription.text = self.getDescription()
    }



    // delegate EventsList
    func willDisplayItemsEventsList() {
        if self.navigationController?.viewControllers.indexOf(self) != nil {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }


    private func getNavTitle() -> String {
        switch self.dataSource.getScope() {
        case .Favourite:
            return loc_favourite
        case .Feed:
            return loc_feed
        case .MyEvents:
            return loc_my_events
        }
    }
    private func getDescription() -> String {
        switch self.dataSource.getScope() {
        case .Favourite:
            return loc_empty_list_help_favourite
        case .Feed:
            return loc_empty_list_help_feed
        case .MyEvents:
            return loc_empty_list_help_my_events
        }
    }
    private func getActionTitle() -> String {
        switch self.dataSource.getScope() {
        case .Favourite:
            return loc_empty_list_action_favourite
        case .Feed:
            return loc_empty_list_action_feed
        case .MyEvents:
            return loc_empty_list_action_my_events
        }
    }
    private func getActionIcon() -> UIImage {
        switch self.dataSource.getScope() {
        case .Favourite:
            return UIImage(named: "icon-star")!
        case .Feed:
            return UIImage(named: "icon-search")!
        case .MyEvents:
            return UIImage(named: "icon-add")!
        }
    }


    private func initNavBarItems() {
        self.navigationItem.title = self.getNavTitle()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "nav-menu"), style: .Plain, target: self, action: #selector(handleClickNavItemMenu(withSender:)))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "nav-filter-gray"), style: .Plain, target: self, action: #selector(handleClickNavItemFilter(withSender:)))
    }
    func handleClickNavItemMenu(withSender sender: UIButton) {
        self.delegate.eventsEmptyList(clickNavItemLeft: sender)
    }
    func handleClickNavItemFilter(withSender sender: UIButton) {
        self.delegate.eventsEmptyList(clickNavItemRight: sender)
    }
}



