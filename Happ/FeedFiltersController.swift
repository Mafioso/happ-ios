//
//  FeedFiltersController.swift
//  Happ
//
//  Created by MacBook Pro on 10/4/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit

class FeedFiltersController: UIViewController {

    var viewModel: EventsListViewModel!

    
    // outlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var segmentSortBy: UISegmentedControl!
    @IBOutlet weak var radioIsFree: UISwitch!
    @IBOutlet weak var tableDateRange: UITableView!
    @IBOutlet weak var constraintsTableHeight: NSLayoutConstraint!
    
    
    // constants
    let cellDateDisplayID = "cellDisplayDate"


    @IBAction func clickedSaveButton(sender: UIButton) {
        self.collectSaveBack()
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableDateRange.dataSource = self
        self.tableDateRange.delegate = self
    }


    private func collectSaveBack() {
        let search: String? = self.searchBar.text
        var sortBy: EventsListSortType = .ByDate
        var onlyFree: Bool

        if self.segmentSortBy.selectedSegmentIndex == 1 {
            sortBy = .ByPopular
        }
        onlyFree = self.radioIsFree.on

        let filters = EventsListFiltersState(search: search, sortBy: sortBy, onlyFree: onlyFree, dateFrom: nil, dateTo: nil)
        self.viewModel.onChangeFilters(filters)
    }
}


extension FeedFiltersController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(self.cellDateDisplayID)!
        if indexPath.row == 0 {
            cell.textLabel?.text = "From"
        } else if indexPath.row == 1 {
            cell.textLabel?.text = "To"
        }
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print(".didSelectRow", indexPath.row)
    }
}




