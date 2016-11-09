//
//  AfterSignupSelectCityController.swift
//  Happ
//
//  Created by MacBook Pro on 11/8/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import Foundation
import UIKit


class SelectCityOnSetupController: SelectCityPrototype {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let searchBar = self.tableView.tableHeaderView as! UISearchBar
        searchBar.placeholder = "Find city..."

        self.initNavBarItems()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.extMakeNavBarTransparrent()
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.extMakeNavBarVisible()
    }


    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {

        if  let selectedCity = self.viewModel.selectedCity,
            let selectedRow = self.viewModel.cities.indexOf(selectedCity)
            where selectedRow == indexPath.row {

            cell.extSetHighlighted()

        } else {
            cell.extUnsetHighlighted()
        }
    }


    private func initNavBarItems() {
        self.navigationItem.title = "Select Your City"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "nav-close-orange"), style: .Plain, target: self, action: #selector(handleClickNavItemClose))
    }
    func handleClickNavItemClose() {
        let vm = self.viewModel as! SelectCityOnSetupViewModel
        vm.navigateBack?()
    }
}



