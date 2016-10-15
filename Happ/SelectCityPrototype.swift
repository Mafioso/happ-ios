//
//  SelectCityPrototype.swift
//  Happ
//
//  Created by MacBook Pro on 10/15/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import Foundation
import UIKit


class SelectCityPrototype: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {

    var viewModel: SelectCityViewModel! {
        didSet {
            self.bindToViewModel()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // init Search bar
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.searchBarStyle = .Minimal
        searchController.dimsBackgroundDuringPresentation = false
        self.definesPresentationContext = true
        self.tableView.tableHeaderView = searchController.searchBar

    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.initTableWithSelected()
    }

    func viewModelDidUpdate() {
        self.tableView.reloadData()
    }
    private func bindToViewModel() {
        self.viewModel.didUpdate = { [weak self] _ in
            self?.viewModelDidUpdate()
        }
    }


    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.viewModel.cities.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let city = self.viewModel.cities[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        cell.textLabel!.text = city.name
        cell.detailTextLabel?.text = city.country_name
        return cell
    }

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        print(".searchBar.textDidChange", searchText)
        self.viewModel.onChangeSearch(searchText)
    }

    func updateSearchResultsForSearchController(searchController: UISearchController) {
        print(".updateSearch", searchController.searchBar.text)
    }

    private func initTableWithSelected() {
        // set selections for already selected city
        if let city = self.viewModel.selectedCity {
            let atRow = self.viewModel.cities.indexOf(city)
            self.tableView.selectRowAtIndexPath(NSIndexPath(forRow: atRow!, inSection: 0), animated: false, scrollPosition: UITableViewScrollPosition.Middle)
        }
    }

}



