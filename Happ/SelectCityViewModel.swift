//
//  SelectCityViewModel.swift
//  Happ
//
//  Created by MacBook Pro on 10/15/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import Foundation
import PromiseKit



class SelectCityOnSetupViewModel: SelectCityViewModelPrototype {

    var navigateBack: NavigationFunc

    override init() {
        super.init()
    }

}


class SelectCityOnMenuViewModel: SelectCityViewModelPrototype, SelectInterestsVMProtocol {

    var navigateFeed: NavigationFunc

    override init() {
        super.init()
    }

    override func onSelectCity(city: CityModel) {
        super.onSelectCity(city)

        //TODO ProfileService.setCity(city.id)
    }


    override private func willLoad() {
        self.fetchCities().then { _ -> Void in
            print(".selectCityVM.fetchCities.done", self.cities.count)
            self.fetchUserCity()
                .then { _ -> Void in
                    print(".selectCityVM.fetchUserCity.done", self.selectedCity?.name)
                    self.didLoad?()
                    self.didUpdate?()
            }
        }
    }
    private func getUserCity() -> CityModel? {
        return ProfileService.getUserCity()
    }
    private func fetchUserCity() -> Promise<Void> {
        if let city = self.getUserCity() {
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


    // for implement SelectInterestsVMProtocol:
    func selectInterestsIsAllowsMultipleSelection() -> Bool {
        return true
    }
    func selectInterestsGetTitle() -> String {
        return self.getUserCity()!.name
    }
    func selectInterestsOnSave(selectedInterests: [InterestModel]) {
        self.navigateFeed?()
    }
}



class SelectCityViewModelPrototype {

    var cities: [CityModel] = []
    var selectedCity: CityModel?
    var search: String?


    init() {
        print(".selectCityVM.init")

        self.willLoad()
    }


    //MARK: - Events
    var didUpdate: (() -> Void)?
    var didLoad: (() -> Void)?
    var didSelectCity: ((CityModel) -> Void)?


    //MARK: - Inputs
    func onSelectCity(city: CityModel) {
        self.selectedCity = city
        self.didSelectCity?(city)
        self.didUpdate?()
    }
    func onChangeSearch(search: String?) {
        self.search = search
        self.cities = self.getCities()
        self.didUpdate?()
    }


    private func willLoad() {
        self.fetchCities().then { _ -> Void in
            print(".selectCityVM.fetchCities.done", self.cities.count)
            self.didLoad?()
            self.didUpdate?()
        }
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

}




