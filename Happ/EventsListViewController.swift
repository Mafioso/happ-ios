//
//  EventsListCollectionViewController.swift
//  Happ
//
//  Created by MacBook Pro on 9/19/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit
import Foundation


let loc_event_action_unsubscribe = NSLocalizedString("Unsubscribe from", comment: "Title of actionsList action displayed on every event for unsubscribe from event's interest")


enum ReuseIdentifier: String {
    case Cell = "Cell"
    case Loading = "CellLoading"
    case Header = "SectionHeader"
}



class FeedViewController: EventsListViewControllerPrototype<FeedViewModel> {
    init() {
        super.init()
    }
}

class FavouriteViewController: EventsListViewControllerPrototype<FavouritesViewModel> {
    init() {
        super.init()
    }
}



protocol EventsListDelegate {
    func willDisplayItemsEventsList()
}

protocol EventsListSyncWithEmptyList: EventsEmptyListDelegate, EventsEmptyListDataSource  {
    var delegateEmptyList: EventsListDelegate? { get set }
}

class EventsListViewControllerPrototype<T: EventsListSectionedViewModelProtocol>: UIViewController, UITableViewDataSource, UITableViewDelegate,
    FeedFiltersDelegate, EventsListSyncWithEmptyList {

    var viewModel: T! {
        didSet {
            self.updateView()
        }
    }

    var delegateEmptyList: EventsListDelegate?
    
    private let segueEmbeddedTableID = "embeddedTable"


    // outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var statusBarBackground: UIView!

    // actions
    @IBAction func clickedMenuNavItem(sender: UIButton) {
        self.viewModel.displaySlideMenu?()
    }
    @IBAction func clickedFiltersNavItem(sender: UIButton) {
        self.viewModel.displaySlideFilters?()
    }



    init(nibName: String = "EventsListViewController") {
        super.init(nibName: nibName, bundle: nil)
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        self.initTableView()
        self.initDataLoading()
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


    func initDataLoading() {
        if self.viewModel.willLoadNextDataPage() {
            self.viewModel.onLoadFirstDataPage() { state in
                self.viewModel.state = state
            }
        }
    }
    
    func updateView() {
        guard self.isViewLoaded() else { return }

        if  self.viewModel.isLoadingFirstDataPage() ||
            !self.viewModel.state.items.isEmpty
        {
            self.delegateEmptyList?.willDisplayItemsEventsList() // close placeholder
            self.tableView.reloadData() // display loading cells or event cells

            if self.viewModel.isLoadingFirstDataPage() {
                self.statusBarBackground.backgroundColor = UIColor.clearColor()
            } else {
                self.statusBarBackground.backgroundColor = UIColor.happOrangeColor()
            }

        } else {
            self.viewModel.displayEmptyList?()
        }
    }


    private func initTableView() {
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.tableView.registerNib(
            UINib(nibName: EventTableCell.nibName, bundle: nil),
            forCellReuseIdentifier: ReuseIdentifier.Cell.rawValue)
        self.tableView.registerNib(
            UINib(nibName: EventLoadingTableCell.nibName, bundle: nil),
            forCellReuseIdentifier: ReuseIdentifier.Loading.rawValue)
        self.tableView.registerNib(
            UINib(nibName: EventsListSectionHeader.nibName, bundle: nil),
            forCellReuseIdentifier: ReuseIdentifier.Header.rawValue)

        self.tableView.estimatedRowHeight = EventTableCell.estimatedHeight
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.separatorStyle = .None
    }



    // delegate FeedFiltersDelegate
    func didChangeFilters(filters: EventsListFiltersState) {
        self.viewModel.onChangeFilters(filters) // it clear state
        self.initDataLoading() // fetch items into state
        self.delegateEmptyList?.willDisplayItemsEventsList()
    }


    // delegate EventsEmptyListDelegate & EventsEmptyListDataSource
    func eventsEmptyList(clickNavItemLeft sender: UIButton) {
        self.viewModel.onClickNavItemLeftEmptyList()
    }
    func eventsEmptyList(clickNavItemRight sender: UIButton) {
        self.viewModel.onClickNavItemRightEmptyList()
    }
    func eventsEmptyList(clickAction sender: UIButton) {
        self.viewModel.onClickActionEmptyList()
    }
    func getScope() -> EventsEmptyListScope {
        return self.viewModel.getScopeEmptyList()
    }



    // header
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard !self.viewModel.isLoadingFirstDataPage() else { return nil }

        let cell = self.tableView.dequeueReusableCellWithIdentifier(ReuseIdentifier.Header.rawValue) as! EventsListSectionHeader
        cell.title.text = self.viewModel.state.getSectionTitle(section)
        return cell
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(56)
    }


    // fill with data
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if self.viewModel.isLoadingFirstDataPage() {
            return 1
        } else {
            return self.viewModel.state.getSectionsCount()
        }
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.viewModel.isLoadingFirstDataPage() {
            return 3
        } else {
            return self.viewModel.state.getSectionEventsCount(section)
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        if self.viewModel.isLoadingFirstDataPage() {
            let cell = self.tableView.dequeueReusableCellWithIdentifier(ReuseIdentifier.Loading.rawValue, forIndexPath: indexPath) as! EventLoadingTableCell
            return cell

        } else {
            let cell = self.tableView.dequeueReusableCellWithIdentifier(ReuseIdentifier.Cell.rawValue, forIndexPath: indexPath) as! EventTableCell

            // configure cell
            let event = self.viewModel.state.getSectionEvent(indexPath)
            cell.viewModel = {
                let vm = EventViewModel(event: event)
                vm.didUpdate = { [weak self] _ in
                    self?.updateView()
                }
                vm.displayMoreActionList = { [weak self] _ in
                    let actionList = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)

                    if let interestName = event.interests.first?.title {
                        let actionUnsubscribe = UIAlertAction(title: loc_event_action_unsubscribe + " " + interestName.uppercaseString, style: .Default, handler: {_ in
                            vm.onUnsubscribeFromInterest()
                        })
                        actionList.addAction(actionUnsubscribe)
                    }

                    let actionCancel = UIAlertAction(title: loc_action_list_action_cancel, style: .Cancel, handler: nil)
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
        guard !self.viewModel.isLoadingFirstDataPage() else { return }

        let event = self.viewModel.state.getSectionEvent(indexPath)
        print(".didSelect", indexPath.row, event.title)
        self.viewModel.onClickEvent(event)
    }

    // pagination
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        print(indexPath)
        if  indexPath.section == self.viewModel.state.getSectionsCount() - 1 &&
            self.viewModel.willLoadNextDataPage() == true
        {
            print("next page", indexPath.section)
            self.viewModel.onLoadNextDataPage { asyncState in
                self.viewModel.state = asyncState
            }
        }

    }
    
}







