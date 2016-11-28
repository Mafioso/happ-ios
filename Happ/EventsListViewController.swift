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
private let reuseIdentifierLoading = "CellLoading"
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
        print(".list.\(self.viewModel.state.scope).didLoad")
        
        
        self.initTableView()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print(".list.\(self.viewModel.state.scope).willAppear")
        
        //self.viewModelDidUpdate()

        self.extMakeNavBarHidden()
        self.extMakeStatusBarWhite()
    }
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        print(".list.\(self.viewModel.state.scope).didDisappear")

        self.extMakeNavBarVisible()
        self.extMakeStatusBarDefault()
    }


    private func bindToViewModel() {
        let superDidUpdate = self.viewModel.didUpdate
        self.viewModel.didUpdate = { [weak self] _ in
            superDidUpdate?()
            self?.viewModelDidUpdate()
        }
    }

    func viewModelDidUpdate() {
        let state = self.viewModel.state
        if  state.fetchingState == .FinishRequest &&
            state.events.isEmpty  {
            self.viewModel.displayEmptyList?()
        } else {
            self.tableView.reloadData() // display loading cells or events
        }
    }


    private func initTableView() {
        self.tableView.dataSource = self
        self.tableView.delegate = self

        self.tableView.registerNib(UINib(nibName: EventTableCell.nibName, bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        self.tableView.registerNib(UINib(nibName: EventLoadingTableCell.nibName, bundle: nil), forCellReuseIdentifier: reuseIdentifierLoading)
        self.tableView.estimatedRowHeight = EventTableCell.estimatedHeight
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }

    // fill with data
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let state = self.viewModel.state
        if state.fetchingState == .StartRequest {
            return 3

        } else {
            return state.events.count
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let state = self.viewModel.state

        if state.fetchingState == .StartRequest {
            let cell = self.tableView.dequeueReusableCellWithIdentifier(reuseIdentifierLoading, forIndexPath: indexPath) as! EventLoadingTableCell
            return cell

        } else {
            let cell = self.tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! EventTableCell
            
            // configure cell
            let event = state.events[indexPath.row]
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
    }

    // select event
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let state = self.viewModel.state
        if state.fetchingState == .StartRequest {
            return // do nothing
        }

        let event = state.events[indexPath.row]
        print(".didSelect", indexPath.row, event.title)
        self.viewModel.onClickEvent(event)
    }
    
    // pagination
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {

        if indexPath.row == self.viewModel.state.events.count - 3 {
            self.viewModel.loadNextPage()
        }
    }
    
}








