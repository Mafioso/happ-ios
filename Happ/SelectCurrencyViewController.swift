//
//  SelectCurrencyViewController.swift
//  Happ
//
//  Created by MacBook Pro on 9/30/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit

let loc_change_currency = NSLocalizedString("Change currency", comment: "Title of Select Currency NavBar in Settings")
let loc_save = NSLocalizedString("Save", comment: "")


class SelectCurrencyViewController: UITableViewController {

    var viewModel: SettingsViewModel!  {
        didSet {
            self.bindToViewModel()
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initNavigationBarItems()
        self.viewModelDidUpdate()
    }



    func viewModelDidUpdate() {
        self.updateTableWithSelected()
    }

    private func bindToViewModel() {
        self.viewModel.didCurrencyUpdate = { [weak self] _ in
            self?.viewModelDidUpdate()
        }
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
        cell.textLabel!.text = currency.code.uppercaseString

        return cell
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedIndexPath = self.tableView.indexPathForSelectedRow!
        let currency = self.viewModel.currencies[selectedIndexPath.row]
        let cell = tableView.cellForRowAtIndexPath(selectedIndexPath)
        cell!.extSetHighlighted()
        self.viewModel.onSelectCurrency(currency)
    }
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell!.extUnsetHighlighted()
    }
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {

        if  let currency_id = self.viewModel.state.currencyID,
            let currency = self.viewModel.currencies.filter({ $0.id == currency_id }).first,
            let selectedRow = self.viewModel.currencies.indexOf(currency)
            where selectedRow == indexPath.row {
                cell.extSetHighlighted()
                tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.Middle)
            } else {
                tableView.deselectRowAtIndexPath(indexPath, animated: false)
                cell.extUnsetHighlighted()
            }
    }


    private func updateTableWithSelected() {
        if  let currency_id = self.viewModel.state.currencyID,
            let currency = self.viewModel.currencies.filter({ $0.id == currency_id }).first {
            // select row
            let atRow = self.viewModel.currencies.indexOf(currency)
            
            self.tableView.selectRowAtIndexPath(NSIndexPath(forRow: atRow!, inSection: 0), animated: false, scrollPosition: UITableViewScrollPosition.Middle)
            
            // enable Save button
            self.navigationItem.rightBarButtonItem!.enabled = true

        } else {
            self.navigationItem.rightBarButtonItem!.enabled = false
        }
    }

    private func initNavigationBarItems() {
        self.navigationItem.title = loc_change_currency
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "nav-back"), style: .Plain, target: self, action: #selector(handleClickNavBarBack))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: loc_save, style: .Plain, target: self, action: #selector(handleClickNavBarSave))
    }
    func handleClickNavBarBack() {
        self.viewModel.navigateBack?()
    }
    func handleClickNavBarSave() {
        self.viewModel.onSaveCurrency()
    }
}
