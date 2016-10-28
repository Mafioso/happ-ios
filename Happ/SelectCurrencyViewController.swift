//
//  SelectCurrencyViewController.swift
//  Happ
//
//  Created by MacBook Pro on 9/30/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit

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
        cell.textLabel!.text = currency.name

        return cell
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedIndexPath = self.tableView.indexPathForSelectedRow!
        let currency = self.viewModel.currencies[selectedIndexPath.row]
        self.viewModel.onSelectCurrency(currency)
    }



    private func updateTableWithSelected() {
        if let currency = self.viewModel.state.currency {
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
        self.navigationItem.title = "Change Currency"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "nav-back"), style: .Plain, target: self, action: #selector(handleClickNavBarBack))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .Plain, target: self, action: #selector(handleClickNavBarSave))
    }
    func handleClickNavBarBack() {
        self.viewModel.navigateBack?()
    }
    func handleClickNavBarSave() {
        self.viewModel.onSaveCurrency()
    }
}
