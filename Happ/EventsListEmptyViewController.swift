
//
//  EventsListEmptyVViewController.swift
//  Happ
//
//  Created by MacBook Pro on 11/27/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit


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
            return "Favourite"
        case .Feed:
            return "Feed"
        case .MyEvents:
            return "My Events"
        }
    }
    private func getDescription() -> String {
        switch self.dataSource.getScope() {
        case .Favourite:
            return "You don’t have any favourited event"
        case .Feed:
            return "There are no events for selected interests"
        case .MyEvents:
            return "You have not created any event yet"
        }
    }
    private func getActionTitle() -> String {
        switch self.dataSource.getScope() {
        case .Favourite:
            return "Find Awesome Events"
        case .Feed:
            return "Add More Interests"
        case .MyEvents:
            return "Add First Event"
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



