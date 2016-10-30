//
//  SelectNotificationsViewController.swift
//  Happ
//
//  Created by MacBook Pro on 10/29/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit

class SelectNotificationsViewController: UIViewController, UITableViewDelegate {

    
    var viewModel: SettingsViewModel!  {
        didSet {
            self.bindToViewModel()
        }
    }
    

    // outlets
    @IBAction func clickedSaveButton(sender: UIButton) {
        self.handleClickSave()
    }

    
    // constants
    let segueEmbeddedTableID = "embeddedTable"
    
    // variables
    var tableView: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.automaticallyAdjustsScrollViewInsets = false

        self.initNavigationBarItems()
        self.viewModelDidUpdate()
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == self.segueEmbeddedTableID {
            let destController = segue.destinationViewController as! UITableViewController
            self.tableView = destController.tableView
        }
    }


    func viewModelDidUpdate() {
        // update switch controllers on cells
        self.tableView.reloadData()
    }

    private func bindToViewModel() {
        self.viewModel.didCurrencyUpdate = { [weak self] _ in
            self?.viewModelDidUpdate()
        }
    }


    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print(".selectNotifications.didSelect", indexPath.section, indexPath.row)

        switch indexPath.row {
        case 0:
            self.viewModel.onSelectNotification(.NewInterests)
        case 1:
            self.viewModel.onSelectNotification(.EventUpdates)
        case 2:
            self.viewModel.onSelectNotification(.Chat)
        case 3:
            self.viewModel.onSelectNotification(.AppUpdates)
        default:
            break
        }
    }
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        print("..selectNotifications.willDisplay", indexPath.row)

        let notifs = self.viewModel.state.notificationsMap
        let cellSwitch = cell.viewWithTag(1) as! UISwitch

        switch indexPath.row {
        case 0:
            cellSwitch.on = notifs[.NewInterests]!
        case 1:
            cellSwitch.on = notifs[.EventUpdates]!
        case 2:
            cellSwitch.on = notifs[.Chat]!
        case 3:
            cellSwitch.on = notifs[.AppUpdates]!
        default:
            break
        }
    }


    private func initNavigationBarItems() {
        self.navigationItem.title = "Push notifications"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "nav-back"), style: .Plain, target: self, action: #selector(handleClickNavBarBack))
    }
    func handleClickNavBarBack() {
        self.viewModel.navigateBack?()
    }
    func handleClickSave() {
        self.viewModel.onSaveNotifications()
    }
}
