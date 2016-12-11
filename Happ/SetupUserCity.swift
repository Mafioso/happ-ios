//
//  SetupUserCity.swift
//  Happ
//
//  Created by MacBook Pro on 12/11/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import PromiseKit


struct SetupUserCityViewModel {
    
    var selectedCity: CityModel?
    
    var navigateSelectCity: NavigationFunc
    var navigateBack: NavigationFunc
    var navigateSelectInterests: NavigationFunc
    
    
    init() {
    }
    
    //MARK: - Inputs
    func onClickSelectCity() {
        self.navigateSelectCity?()
    }
    func onClickSave() {
        CityService
            .setUserCity(self.selectedCity!.id)
            .then { _ in self.navigateSelectInterests?() }
    }
    mutating func onSelectCity(city: CityModel) {
        self.selectedCity = city
        self.navigateBack?()
    }
}

