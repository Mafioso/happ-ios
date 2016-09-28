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


        self.initDisplaySelectButton()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source


    private func bindToViewModel() {
        self.viewModel.didUpdate = { [weak self] (updateType: SelectCityInterestsDidUpdateTypes) in
            if updateType == .CitiesList {
                self?.tableView.reloadData()
            }
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
        cell.detailTextLabel!.text = city.country_name

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.updateDisplaySelectButton()
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        self.updateDisplaySelectButton()
    }


    private func initDisplaySelectButton() {
        let buttonSelect = UIBarButtonItem(title: "Select", style: UIBarButtonItemStyle.Done, target: self, action: #selector(clickedSelectButton))
        self.navigationItem.rightBarButtonItem = buttonSelect
    }

    private func updateDisplaySelectButton() {
        let isSelected = (self.tableView.indexPathForSelectedRow != nil)
        self.navigationItem.rightBarButtonItem!.enabled = isSelected
    }

    func clickedSelectButton() {
        let selectedIndexPath = self.tableView.indexPathForSelectedRow!
        let selectedCity = self.viewModel.cities[selectedIndexPath.row]
        self.viewModel.onSelectCity(selectedCity)
    }
}



