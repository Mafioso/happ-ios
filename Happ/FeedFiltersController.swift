//
//  FeedFiltersController.swift
//  Happ
//
//  Created by MacBook Pro on 10/4/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit

class FeedFiltersController: UIViewController {

    var viewModel: FeedViewModel!

    
    // outlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var segmentSortBy: UISegmentedControl!
    @IBOutlet weak var radioIsFree: UISwitch!
    @IBOutlet weak var tableDateRange: UITableView!
    @IBOutlet weak var constraintsTableHeight: NSLayoutConstraint!
    
    
    // constants
    let cellDateDisplayID = "cellDisplayDate"


    @IBAction func clickedSaveButton(sender: UIButton) {
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableDateRange.dataSource = self
        self.tableDateRange.delegate = self
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




