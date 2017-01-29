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


class SelectCurrencyViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var viewModel: SettingsViewModel!  {
        didSet {
            self.bindToViewModel()
        }
    }


    @IBAction func clickedSaveButton(sender: UIButton) {
        self.viewModel.onSaveCurrency()
    }

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buttonSave: UIButton!



    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.automaticallyAdjustsScrollViewInsets = false

        self.initNavBarItems()
        self.viewModelDidUpdate()
    }



    func viewModelDidUpdate() {
        self.tableView.reloadData()
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
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.currencies.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let currency = self.viewModel.currencies[indexPath.row]

        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        cell.textLabel!.text = currency.code.uppercaseString

        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedIndexPath = self.tableView.indexPathForSelectedRow!
        let currency = self.viewModel.currencies[selectedIndexPath.row]
        self.viewModel.onSelectCurrency(currency)
    }
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {

        if  let currency_id = self.viewModel.state.currencyID,
            let currency = self.viewModel.currencies.filter({ $0.id == currency_id }).first,
            let selectedRow = self.viewModel.currencies.indexOf(currency)
            where selectedRow == indexPath.row {

            cell.extSetHighlighted()
        } else {
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
            self.buttonSave.enabled = true

        } else {
            self.buttonSave.enabled = false
        }
    }

    private func initNavBarItems() {
        self.navigationItem.title = loc_change_currency
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "nav-back"), style: .Plain, target: self, action: #selector(handleClickNavBarBack))
    }
    func handleClickNavBarBack() {
        self.viewModel.navigateBack?()
    }
}
