//
//  SettingsController.swift
//  Happ
//
//  Created by MacBook Pro on 9/28/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit

let loc_settings = NSLocalizedString("Settings", comment: "Title of Settings NavBar")


class SettingsController: UIViewController, UITableViewDelegate, EmailSenderProtocol {

    var viewModel: SettingsViewModel!


    // constants
    let segueEmbeddedTableID = "embeddedTable"

    // variables
    var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.automaticallyAdjustsScrollViewInsets = false

        self.initNavigationBarItems()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.extMakeNavBarTransparrent()
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == self.segueEmbeddedTableID {
            let destController = segue.destinationViewController as! UITableViewController
            self.tableView = destController.tableView
        }
    }


    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        switch cell.tag {
        case 0:
            self.viewModel.navigateProfile?()
        case 1:
            self.viewModel.navigateSelectNotifications?()
        case 2:
            self.viewModel.navigateCitiesManager?()
        case 3:
            self.viewModel.navigateSelectCurrency?()
        case 4:
            self.sendEmailToHapp()
        case 5:
            self.viewModel.navigateHelp?()
        case 6:
            self.viewModel.navigateTerms?()
        case 7:
            self.viewModel.navigatePrivacy?()
        default:
            break
        }
    }

    
    private func sendEmailToHapp() {
        let happAddress = DefaultParameters.getValue(.HappEmailAddress) as! String
        let email = EmailSenderCompose.Simple(subject: "Hello Happ!", body: "", receipants: [happAddress])
        self.sendEmail(email)
    }

    private func initNavigationBarItems() {
        self.navigationItem.title = loc_settings
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "nav-menu"), style: .Plain, target: self, action: #selector(handleClickNavBarMenu))
    }
    func handleClickNavBarMenu() {
        self.viewModel.displaySlideMenu?()
    }
}
