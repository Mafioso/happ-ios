//
//  EventsManageViewController.swift
//  Happ
//
//  Created by Aleksei Pugachev on 12/22/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit

let loc_my_events_warning_copy_failed = NSLocalizedString("Copying of event wasn't successful, try again please", comment: "Body of alert displayed after event copying was failed")
let loc_my_events_warning_delete_failed = NSLocalizedString("Deletion of event wasn't successful, try again please", comment: "Body of alert displayed after event deleting was failed")
let loc_my_events_warning_activation_failed = NSLocalizedString("Activation of event wasn't successful, try again please", comment: "Body of alert displayed after event activating was failed")
let loc_my_events_warning_deactivation_failed = NSLocalizedString("Deactivation of event wasn't successful, try again please", comment: "Body of alert displayed after event deactivating was failed")


private let segueEmbeddedTableID = "embeddedTable"

class EventsManageViewController: EventsManageViewControllerPrototype<EventsManageViewModel> {
    init() {
        super.init()
    }
}

protocol EventsManageDelegate {
    func willDisplayItemsEventsList()
}


protocol EventsManageSyncWithEmptyList: EventsEmptyListDelegate, EventsEmptyListDataSource  {
    var delegateEmptyList: EventsManageDelegate? { get set }
}



class EventsManageViewControllerPrototype<T: EventsListSectionedViewModelProtocol>: UIViewController, UITableViewDataSource, UITableViewDelegate,
FeedFiltersDelegate, EventsListSyncWithEmptyList {
    
    var viewModel: T! {
        didSet {
            self.updateView()
        }
    }
    
    var delegateEmptyList: EventsListDelegate?
    
    
    // outlets
    @IBOutlet weak var tableView: UITableView!
    
    
    
    init(nibName: String = "EventsManageViewController") {
        super.init(nibName: nibName, bundle: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initTableView()
        self.initDataLoading()
        self.extMakeNavBarWhite()
        self.initNavBarItems()
    }
    
    private func initDataLoading() {
        if self.viewModel.willLoadNextDataPage() {
            self.viewModel.onLoadFirstDataPage() { state in
                self.viewModel.state = state
            }
        }
    }
    
    private func updateView() {
        guard self.isViewLoaded() else { return }
        
        if  self.viewModel.isLoadingFirstDataPage() ||
            !self.viewModel.state.items.isEmpty
        {
            self.delegateEmptyList?.willDisplayItemsEventsList() // close placeholder
            self.tableView.reloadData() // display loading cells or event cells
            
        } else {
            self.viewModel.displayEmptyList?()
        }
    }
    
    private func initTableView() {
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.tableView.registerNib(
            UINib(nibName: EventManageLoadingTableCell.nibName, bundle: nil),
            forCellReuseIdentifier: ReuseIdentifier.Loading.rawValue)
        self.tableView.registerNib(
            UINib(nibName: EventManageTableCell.nibName, bundle: nil),
            forCellReuseIdentifier: ReuseIdentifier.Cell.rawValue)
    }
    
    private func initNavBarItems() {
        self.navigationItem.title = loc_my_events
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "nav-menu"), style: .Plain, target: self, action: #selector(handleClickNavItemMenu(withSender:)))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "nav-filter-gray"), style: .Plain, target: self, action: #selector(handleClickNavItemFilter(withSender:)))
    }

    func handleClickNavItemMenu(withSender sender: UIButton) {
        self.viewModel.displaySlideMenu?()
    }
    
    func handleClickNavItemFilter(withSender sender: UIButton) {
        self.viewModel.displaySlideFilters?()
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
            return 10
        } else {
            return self.viewModel.state.getSectionEventsCount(section)
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if self.viewModel.isLoadingFirstDataPage() {
            let cell = self.tableView.dequeueReusableCellWithIdentifier(ReuseIdentifier.Loading.rawValue, forIndexPath: indexPath) as! EventManageLoadingTableCell
            
            return cell
        } else {
            let cell = self.tableView.dequeueReusableCellWithIdentifier(ReuseIdentifier.Cell.rawValue, forIndexPath: indexPath) as! EventManageTableCell
            
            cell.event = self.viewModel.state.getSectionEvent(indexPath)
            
            cell.onCopy = {
                cell.indicatorCopy.startAnimating()
                self.viewModel.onCopyEvent(cell.event, onFinish: { copied in
                    cell.indicatorCopy.stopAnimating()
                    if !copied {
                        self.extDisplayAlertView(loc_my_events_warning_copy_failed)
                    }
                })
            }
            cell.onShowDeniedDetails = {
                self.viewModel.onDeniedDetailsEvent(cell.event)
            }
            cell.onClick = {
                self.viewModel.onClickEvent(cell.event)
            }
            cell.onEdit = {
                self.viewModel.onEditEvent(cell.event)
            }
            cell.onDelete = {
                cell.indicatorDelete.startAnimating()
                self.viewModel.onDeleteEvent(cell.event, onFinish: { deleted in
                    cell.indicatorDelete.stopAnimating()
                    if !deleted {
                        self.extDisplayAlertView(loc_my_events_warning_delete_failed)
                    }
                })
            }
            cell.onActivateDeactivate = {
                cell.indicatorActivateDeactivate.startAnimating()
                self.viewModel.onActivateEvent(cell.event, activated: cell.activated, onFinish: { activated in
                    cell.indicatorActivateDeactivate.stopAnimating()
                    if activated {
                        cell.activated = !cell.activated
                    }else{
                        self.extDisplayAlertView(!cell.activated ? loc_my_events_warning_activation_failed: loc_my_events_warning_deactivation_failed)
                    }
                })
            }

            return cell
        }
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return EventManageTableCell.estimatedHeight
    }
    
    // pagination
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if  indexPath.section == self.viewModel.state.getSectionsCount() - 1 &&
            self.viewModel.willLoadNextDataPage() == true
        {
            self.viewModel.onLoadNextDataPage { asyncState in
                self.viewModel.state = asyncState
            }
        }
    }
}
