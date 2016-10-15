//
//  EventsListCollectionViewController.swift
//  Happ
//
//  Created by MacBook Pro on 9/19/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit
import Foundation


private let reuseIdentifier = "Cell"
private let segueEmbeddedTableID = "embeddedTable"



class EventsListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {


    var viewModel: EventsListViewModel! {
        didSet {
            self.bindToViewModel()
        }
    }

    
    // outlets
    @IBOutlet weak var tableView: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        /*
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let frame = CGRect(x: 0, y: 20, width: Int(screenSize.width), height: 44)
        let navBar = UIView(frame: frame)
        navBar.backgroundColor = UIColor(white: 1, alpha: 0.7)
        */

        self.initNavigationBarItems()
        self.initTableView()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.extMakeStatusBarWhite()
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.extMakeStatusBarDefault()
    }


    private func bindToViewModel() {
        self.viewModel.didUpdate = { [weak self] _ in
            self?.viewModelDidUpdate()
        }
    }

    func viewModelDidUpdate() {
        self.tableView.reloadData()
    }


    private func initTableView() {
        self.tableView.dataSource = self
        self.tableView.delegate = self

        self.tableView.registerNib(UINib(nibName: EventTableCell.nibName, bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        self.tableView.estimatedRowHeight = 265
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }

    
    // MARK: UITableViewDataSource

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let eventsCount = self.viewModel.getEventsCount()
        print(".numberOfRow", eventsCount)
        return eventsCount
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! EventTableCell

        // configure cell
        let event = self.viewModel.getEventAt(indexPath)
        let eventViewModel = EventViewModel(event: event)
        eventViewModel.didUpdate = { [weak self] _ in
            self?.viewModelDidUpdate()
        }
        eventViewModel.displayMoreActionList = { [weak self] _ in
            let actionList = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)

            if let interestName = event.interests.first?.title {
                let actionUnsubscribe = UIAlertAction(title: "Unsubscribe from \"\(interestName)\"", style: .Default, handler: {_ in
                    eventViewModel.onClickUnsubscribeFromInterest()
                })
                actionList.addAction(actionUnsubscribe)
            }

            let actionCancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            actionList.addAction(actionCancel)

            self?.presentViewController(actionList, animated: true, completion: nil)
        }
        cell.viewModel = eventViewModel


        // paginating
        if indexPath.row == self.viewModel.getEventsCount() - 3 {
            self.viewModel.loadNextPage()
        }

        return cell
    }


    // MARK: UITableViewDelegate

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let event = self.viewModel.getEventAt(indexPath)
        print(".didSelect", indexPath.row, event.title)
        self.viewModel.onClickEvent(event)
    }

}



extension EventsListViewController {
    
    private func initNavigationBarItems() {
        let navBarMenu = HappNavBarItem(position: .Left, icon: "nav-menu")
        navBarMenu.button.addTarget(self, action: #selector(handleClickNavBarMenu), forControlEvents: .TouchUpInside)
        self.view.addSubview(navBarMenu)

        let navBarFilter = HappNavBarItem(position: .Right, icon: "nav-filter")
        navBarFilter.button.addTarget(self, action: #selector(handleClickNavBarFilter), forControlEvents: .TouchUpInside)
        self.view.addSubview(navBarFilter)
    }

    func handleClickNavBarFilter() {
        self.viewModel.displaySlideFeedFilters?()
    }
    func handleClickNavBarMenu() {
        self.viewModel.displaySlideMenu?()
    }
}






