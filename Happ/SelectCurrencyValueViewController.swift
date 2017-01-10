//
//  SelectCurrencyValueViewController.swift
//  Happ
//
//  Created by Aleksei Pugachev on 12/29/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit

protocol SelectCurrencyValueDelegate {
    func didSelectCurrencyValue(currencyValue: CurrencyModel)
}

class SelectCurrencyValueViewController: UITableViewController, UISearchResultsUpdating {
    
    var viewModel: SelectCurrencyValueViewModel! {
        didSet {
            self.bindToViewModel(viewModel)
        }
    }
    
    var delegate: SelectCurrencyValueDelegate?
    var searchController: UISearchController!
    let identifierCell = "cell"
    var filtered = false
    var filteredItems: [CurrencyModel] = []
    
    internal func bindToViewModel(viewModel: SelectCurrencyValueViewModel) {
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
            controller.searchBar.placeholder = "Search"
            controller.dimsBackgroundDuringPresentation = false
            self.definesPresentationContext = true
            return controller
        })()
        
        self.tableView.tableHeaderView = self.searchController.searchBar
        self.tableView.allowsSelection = true
        self.tableView.allowsMultipleSelection = false
    }
    
    private func initNavBarItems() {
        self.navigationItem.title = "Select currency"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "nav-close-orange"), style: .Plain, target: self, action: #selector(handleClickNavItemClose))
    }
    
    func handleClickNavItemClose() {
        self.viewModel.navigateBack?()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filtered ? filteredItems.count : viewModel.items.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(self.identifierCell, forIndexPath: indexPath)
        
        let items = filtered ? filteredItems : viewModel.items
        
        cell.textLabel!.text = items[indexPath.row].code
        cell.detailTextLabel!.text = items[indexPath.row].name
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let items = filtered ? filteredItems : viewModel.items
        delegate?.didSelectCurrencyValue(items[indexPath.row])
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if searchController.searchBar.text?.characters.count > 0 {
            filtered = true
            filteredItems = viewModel.items.filter {
                return
                    $0.code.lowercaseString.rangeOfString(searchController.searchBar.text!.lowercaseString) != nil ||
                    $0.name.lowercaseString.rangeOfString(searchController.searchBar.text!.lowercaseString) != nil
            }
        }else{
            filtered = false
        }
        tableView.reloadData()
    }
    
}
