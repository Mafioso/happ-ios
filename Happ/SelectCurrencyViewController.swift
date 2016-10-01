//
//  SelectCurrencyViewController.swift
//  Happ
//
//  Created by MacBook Pro on 9/30/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit

class SelectCurrencyViewController: UITableViewController {

    var viewModel: SettingsViewModel!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.hidden = false
        self.extMakeNavBarWhite()

        self.initDisplaySelectButton()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.updateTableWithSelected()
    }


    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.currencies.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let currency = self.viewModel.currencies[indexPath.row]

        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        cell.textLabel!.text = currency.name

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
        // set selections for already selected currency
        if let currency = self.viewModel.userSettings.currency {
            let atRow = self.viewModel.currencies.indexOf(currency)
            self.tableView.selectRowAtIndexPath(NSIndexPath(forRow: atRow!, inSection: 0), animated: false, scrollPosition: UITableViewScrollPosition.Middle)
            self.updateDisplaySelectButton()
        }
    }


    func clickedSelectButton() {
        let selectedIndexPath = self.tableView.indexPathForSelectedRow!
        let currency = self.viewModel.currencies[selectedIndexPath.row]
        self.viewModel.onSelectCurrency(currency)
    }

}
