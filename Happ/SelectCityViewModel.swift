//
//  SelectCityViewModel.swift
//  Happ
//
//  Created by MacBook Pro on 10/15/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import Foundation
import PromiseKit


class SelectCityViewModel {

    var cities: [CityModel] = []
    var selectedCity: CityModel?
    var search: String?

    var navigateBack: NavigationFunc


    init() {

        self.fetchCities()
    }


    //MARK: - Events
    var didUpdate: (() -> Void)?


    //MARK: - Inputs
    func onSelectCity(city: CityModel) {
        self.selectedCity = city
    }
    func onChangeSearch(search: String?) {
        self.search = search
        self.cities = self.getCities()
        self.didUpdate?()
    }

    private func getCities() -> [CityModel] {
        var cities = ProfileService.getCitiesStored()
        if self.search != nil {
            cities = cities.filter("name CONTAINS %@", search!)
        }
        return Array(cities)
    }

    private func fetchCities() -> Void {
        ProfileService.fetchCities()
            .then { _ -> Void in
                self.cities = self.getCities()
                self.didUpdate?()
        }
    }


}



