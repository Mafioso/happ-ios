//
//  SettingsController.swift
//  Happ
//
//  Created by MacBook Pro on 9/28/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit

class SettingsController: UIViewController, UITableViewDelegate {

    var viewModel: SettingsViewModel!

    
    let segueEmbeddedTableID = "embeddedTable"
    var embeddedTable: UITableView!


    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "bg-gradient")!)

        self.embeddedTable.delegate = self
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.extMakeNavBarTransparent(UIColor.whiteColor())
        self.extMakeStatusBarWhite()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        self.extMakeStatusBarDefault()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == segueEmbeddedTableID {
            let dest = segue.destinationViewController as! UITableViewController
            self.embeddedTable = dest.tableView
        }
    }


    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print(".settings.selectedRow", indexPath.section, indexPath.row)

        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                self.viewModel.navigateSelectCity?()
            case 1:
                self.viewModel.navigateSelectLanguage?()
            case 2:
                self.viewModel.navigateSelectCurrency?()
            case 3:
                self.viewModel.navigateSelectNotifications?()
            default:
                break
            }
        case 2:
            switch indexPath.row {
            case 0:
                self.viewModel.navigateContact?()
            case 1:
                self.viewModel.navigateHelp?()
            case 2:
                self.viewModel.navigateTerms?()
            default:
                break
            }
        default:
            break
        }
    }
    
}
