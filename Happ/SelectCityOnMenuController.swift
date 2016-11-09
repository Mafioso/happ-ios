//
//  MenuSelectCity.swift
//  Happ
//
//  Created by MacBook Pro on 10/15/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import Foundation
import UIKit


class SelectCityOnMenuController: SelectCityPrototype {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let searchBar = self.tableView.tableHeaderView as! UISearchBar
        searchBar.placeholder = "Find city..."
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


}
