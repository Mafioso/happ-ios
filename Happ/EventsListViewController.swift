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
    
    // actions
    @IBAction func clickedMenuNavItem(sender: UIButton) {
        self.viewModel.displaySlideMenu?()
    }
    @IBAction func clickedFiltersNavItem(sender: UIButton) {
        self.viewModel.displaySlideFeedFilters?()
    }



    override func viewDidLoad() {
        super.viewDidLoad()

        self.initTableView()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.extMakeNavBarHidden()
        self.extMakeStatusBarWhite()
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        self.extMakeNavBarVisible()
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
        self.tableView.estimatedRowHeight = EventTableCell.estimatedHeight
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }



    // fill with data
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
        cell.viewModel = {
            let vm = EventViewModel(event: event)
            vm.didUpdate = { [weak self] _ in
                self?.viewModelDidUpdate()
            }
            vm.displayMoreActionList = { [weak self] _ in
                let actionList = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
                
                if let interestName = event.interests.first?.title {
                    let actionUnsubscribe = UIAlertAction(title: "Unsubscribe from \"\(interestName)\"", style: .Default, handler: {_ in
                        vm.onUnsubscribeFromInterest()
                    })
                    actionList.addAction(actionUnsubscribe)
                }
                
                let actionCancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
                actionList.addAction(actionCancel)
                
                self?.presentViewController(actionList, animated: true, completion: nil)
            }
            return vm
        }()

        return cell
    }

    // select event
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let event = self.viewModel.getEventAt(indexPath)
        print(".didSelect", indexPath.row, event.title)
        self.viewModel.onClickEvent(event)
    }
    
    // pagination
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {

        if indexPath.row == self.viewModel.getEventsCount() - 3 {
            self.viewModel.loadNextPage()
        }
    }
    
}








