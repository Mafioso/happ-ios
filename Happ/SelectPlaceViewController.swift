//
//  SelectPlaceViewController.swift
//  Happ
//
//  Created by Aleksei Pugachev on 12/29/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit

let loc_select_place = NSLocalizedString("Select currency", comment: "Title of NavBar in SelectCurrency page")
let loc_select_place_search_placeholder = NSLocalizedString("Start to type place or address", comment: "Placeholder used in UISearchController of SelectPlaceViewController")


protocol SelectPlaceDelegate {
    func didSelectPlace(place: MapPlace)
}

class SelectPlaceViewController: UITableViewController, UISearchResultsUpdating {
    
    var viewModel: SelectPlaceViewModel! {
        didSet {
            self.bindToViewModel(viewModel)
        }
    }
    
    var delegate: SelectPlaceDelegate?
    var searchController: UISearchController!
    let identifierCell = "cell"
    
    internal func bindToViewModel(viewModel: SelectPlaceViewModel) {
        viewModel.didUpdate = {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.prepareTableView()
        self.initNavBarItems()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.extMakeNavBarWhite()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.extMakeNavBarVisible()
    }

    private func prepareTableView() {
        self.searchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.searchBar.searchBarStyle = .Minimal
            controller.searchBar.sizeToFit()
            controller.searchBar.placeholder = loc_select_place_search_placeholder
            controller.dimsBackgroundDuringPresentation = false
            self.definesPresentationContext = true
            return controller
        })()
        
        self.tableView.tableHeaderView = self.searchController.searchBar
        self.tableView.allowsSelection = true
        self.tableView.allowsMultipleSelection = false
    }

    private func initNavBarItems() {
        self.navigationItem.title = loc_select_place
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "nav-close-orange"), style: .Plain, target: self, action: #selector(handleClickNavItemClose))
    }
    
    func handleClickNavItemClose() {
        self.viewModel.navigateBack?()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.items.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(self.identifierCell, forIndexPath: indexPath)
        
        cell.textLabel!.text = self.viewModel.items[indexPath.row].name
        cell.detailTextLabel!.text = self.viewModel.items[indexPath.row].address
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        delegate?.didSelectPlace(self.viewModel.items[indexPath.row])
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        self.viewModel.search(searchController.searchBar.text!)
    }
    
}
