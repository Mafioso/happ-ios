//
//  SelectCityViewController.swift
//  Happ
//
//  Created by MacBook Pro on 9/28/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit

class SelectCityViewController: UITableViewController {

    var viewModel: SelectCityInterestsViewModel! {
        didSet {
            self.bindToViewModel()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    
    private func bindToViewModel() {
        self.viewModel.didUpdateCities = { [weak self] _ in
            self?.tableView.reloadData()
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
        print("here", indexPath.row, city)

        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        cell.textLabel!.text = city.name
        cell.detailTextLabel!.text = city.country_name

        return cell
    }


}
