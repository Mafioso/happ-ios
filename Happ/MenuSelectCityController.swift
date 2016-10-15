//
//  MenuSelectCity.swift
//  Happ
//
//  Created by MacBook Pro on 10/15/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import Foundation
import UIKit


class MenuSelectCityController: SelectCityPrototype {
    
    var handleSelect: ((CityModel) -> Void)?

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let city = self.viewModel.cities[indexPath.row]
        self.viewModel.onSelectCity(city)
        self.handleSelect?(city)
    }

}
