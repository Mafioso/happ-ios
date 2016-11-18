//
//  SelectCityPrototype.swift
//  Happ
//
//  Created by MacBook Pro on 10/15/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import Foundation
import UIKit


class SelectCityPrototype: UITableViewController, UISearchResultsUpdating {


    var viewModel: SelectCityViewModelPrototype! {
        didSet {
            self.bindToViewModel()
        }
    }
    
    
    // variables
    var searchController: UISearchController!

    // constants
    let identifierCell = "cell"


    override func viewDidLoad() {
        super.viewDidLoad()

        // init Search bar
        self.searchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.searchBar.searchBarStyle = .Minimal
            controller.searchBar.sizeToFit()
            controller.dimsBackgroundDuringPresentation = false
            self.definesPresentationContext = true
            return controller
        })()

        self.tableView.tableHeaderView = self.searchController.searchBar
        self.tableView.allowsSelection = true
        self.tableView.allowsMultipleSelection = false

        self.viewModelDidUpdate()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        // self.scrollToSelectedCity()
    }

    func viewModelDidUpdate() {
        print(".SelectCity[V].VMdidUpdate", self.viewModel.cities.count)
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

        let cell = tableView.dequeueReusableCellWithIdentifier(self.identifierCell, forIndexPath: indexPath)
        cell.textLabel!.text = city.name
        cell.detailTextLabel?.text = city.country_name
        
        if indexPath == self.tableView.indexPathForSelectedRow {
            print(".selectCity.cellForRow", "selected", indexPath, city.name)
        }

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let city = self.viewModel.cities[indexPath.row]
        self.viewModel.onSelectCity(city)
    }


    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchText = searchController.searchBar.text
        print(".updateSearch", searchText)
        self.viewModel.onChangeSearch(searchText)
    }

}



