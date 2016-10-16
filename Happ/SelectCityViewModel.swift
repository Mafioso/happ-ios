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
        print(".selectCityVM.init")
        self.fetchCities().then { _ -> Void in
            print(".selectCityVM.fetchCities.done")
            self.fetchUserCity()
                .then { _ -> Void in
                    print(".selectCityVM.fetchUserCity.done", self.didUpdate)
                    self.didLoad?()
                    self.didUpdate?()
            }
        }
    }


    //MARK: - Events
    var didUpdate: (() -> Void)?
    var didLoad: (() -> Void)?
    var didSelectCity: ((CityModel) -> Void)?


    //MARK: - Inputs
    func onSelectCity(city: CityModel) {
        self.selectedCity = city
        // ProfileService.setCity(city.id) TODO
        self.didSelectCity?(city)
        self.didUpdate?()
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

    private func fetchCities() -> Promise<Void> {
        return ProfileService.fetchCities()
            .then { _ -> Void in
                self.cities = self.getCities()
        }
    }

    private func fetchUserCity() -> Promise<Void> {
        if let city = ProfileService.getUserCity() {
            self.selectedCity = city
            return Promise().asVoid()

        } else {
            return ProfileService.fetchUserCity()
                .then { _ -> Void in
                    self.selectedCity = ProfileService.getUserCity()
                    self.cities = self.getCities() // get updated data from local DB
                    self.didUpdate?()
            }
        }
    }

}



