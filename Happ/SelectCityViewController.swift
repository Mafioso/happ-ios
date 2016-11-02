//
//  SelectCityViewController.swift
//  Happ
//
//  Created by MacBook Pro on 9/28/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit

class SelectCityViewController: UITableViewController {

    var viewModel: SelectCityViewModel!


    override func viewDidLoad() {
        super.viewDidLoad()

        self.initDisplaySelectButton()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.updateTableWithSelected()
    }



    // MARK: - Table view data source

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
        buttonSelect.enabled = false
        self.navigationItem.rightBarButtonItem = buttonSelect
    }

    private func updateDisplaySelectButton() {
        let isSelected = (self.tableView.indexPathForSelectedRow != nil)
        self.navigationItem.rightBarButtonItem!.enabled = isSelected
    }

    private func updateTableWithSelected() {
        // set selections for already selected city
        if let city = self.viewModel.selectedCity {
            let atRow = self.viewModel.cities.indexOf(city)
            self.tableView.selectRowAtIndexPath(NSIndexPath(forRow: atRow!, inSection: 0), animated: false, scrollPosition: UITableViewScrollPosition.Middle)
            self.updateDisplaySelectButton()
        }
    }


    func clickedSelectButton() {
        let selectedIndexPath = self.tableView.indexPathForSelectedRow!
        let selectedCity = self.viewModel.cities[selectedIndexPath.row]
        self.viewModel.onSelectCity(selectedCity)
    }
}




