//
//  SelectCityPrototype.swift
//  Happ
//
//  Created by MacBook Pro on 10/15/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import Foundation
import UIKit


class SelectCityOnMenuController {
}

/*
class SelectCityOnSetupController {
    
    var viewModel: SelectCityOnSetupViewModel! {
        didSet {
            
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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

    
    
    private func initNavBarItems() {
        self.navigationItem.title = "Select Your City"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "nav-close-orange"), style: .Plain, target: self, action: #selector(handleClickNavItemClose))
    }
    func handleClickNavItemClose() {
        let vm = self.viewModel as! SetupUserCityViewModel
        vm.navigateBack?()
    }
}
*/



protocol SelectCityDelegate {
    func didSelectCity(city: CityModel)
}

protocol SelectCityDataSource {
    func getSelectedCity() -> CityModel?
}


class SelectCityOnSetupController: UITableViewController, UISearchResultsUpdating {

    var viewModel: SelectCityOnSetupViewModel! {
        didSet {
            self.updateView()
        }
    }
    var delegate: SelectCityDelegate?
    var dataSource: SelectCityDataSource?

    var searchController: UISearchController!
    let identifierCell = "cell"


    override func viewDidLoad() {
        super.viewDidLoad()

        // init Search bar
        self.searchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.searchBar.searchBarStyle = .Minimal
            controller.searchBar.sizeToFit()
            controller.searchBar.placeholder = "Find city..."
            controller.dimsBackgroundDuringPresentation = false
            self.definesPresentationContext = true
            return controller
        })()

        self.tableView.tableHeaderView = self.searchController.searchBar
        self.tableView.allowsSelection = true
        self.tableView.allowsMultipleSelection = false
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if let city = self.dataSource?.getSelectedCity() {
            self.viewModel.state.selectedID = city.id
        }
        self.viewModel.onLoadFirstDataPage() { state in
            self.viewModel.state = state
        }
    }


    func updateView() {
        print(".[V].update", self.viewModel.state)
        self.tableView.reloadData()
        //TODO self.scrollToSelectedCity()
    }
    

    // fill with data
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.state.items.count
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let city = self.getCity(indexPath)

        let cell = tableView.dequeueReusableCellWithIdentifier(self.identifierCell, forIndexPath: indexPath)
        cell.textLabel!.text = city.name
        cell.detailTextLabel?.text = city.country_name

        return cell
    }

    // handle select
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let city = self.getCity(indexPath)

        self.viewModel.onSelectCity(city)
        self.delegate?.didSelectCity(city)
    }
    // higlight and pagination
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {

        if  let selectedCity = self.viewModel.selectedCity(),
            let selectedRow = self.viewModel.state.items.indexOf(selectedCity)
            where selectedRow == indexPath.row {

            cell.extSetHighlighted()
        } else {
            cell.extUnsetHighlighted()
        }

        // paginating
        if indexPath.row == self.viewModel.state.items.count - 3 {
            self.viewModel.onLoadNextDataPage() { state in
                self.viewModel.state = state
            }
        }
    }


    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchText = searchController.searchBar.text
        print(".updateSearch", searchText)
        self.viewModel.onChangeSearch(searchText)
    }

    private func getCity(indexPath: NSIndexPath) -> CityModel {
        return self.viewModel.state.items[indexPath.row] as! CityModel
    }

}



