//
//  MenuViewController.swift
//  Happ
//
//  Created by Aigerim'sMac on 28.09.16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit
import Haneke


class MenuViewController: UITableViewController {

    var viewModel: MenuViewModel!

    
    // outlets
    @IBOutlet weak var imageUserPhoto: UIImageView!
    @IBOutlet weak var labelUserFullname: UILabel!
    
    
    // action
    @IBAction func clickedChangeProfile(sender: UIButton) {
        self.viewModel.navigateProfile?()
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        if let user = self.viewModel.user {
            // TODO
            // let imageURL = NSURL(user...)
            // imageUserPhoto.hnk_setImageFromURL(imageURL)
            labelUserFullname.text = user.fullname
        }
    }

    

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }


    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        print(".menu.clicked", indexPath.row, indexPath.section)

        switch indexPath.section {
        case 1:
            switch indexPath.row {
            case 0:
                self.viewModel.navigateFeed?()
            case 1:
                self.viewModel.navigateSelectInterests?()
            case 2:
                self.viewModel.navigateEventPlanner?()
            default:
                break
            }
        case 2:
            switch indexPath.row {
            case 1:
                self.viewModel.navigateSettings?()
            case 2:
                self.viewModel.navigateLogout?()
            default:
                break
            }
        default:
            break
        }
    }
}
