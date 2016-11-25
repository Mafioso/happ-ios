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

        self.selectedCity = self.getUserCity()
    }

    override func onSelectCity(city: CityModel) {
        CityService.setUserCity(city.id)
            .then { _ in
                super.onSelectCity(city)
        }
    }


    private func getUserCity() -> CityModel {
        return ProfileService.getUserCity()
    }


    // for implement SelectInterestsVMProtocol:
    func selectInterestsIsAllowsMultipleSelection() -> Bool {
        return true
    }
    func selectInterestsGetTitle() -> String {
        return self.getUserCity().name
    }
    func selectInterestsOnSave(selectedInterests: [InterestModel]) {
        let interestIDs = selectedInterests.map { $0.id }
        InterestService.setUserInterests(interestIDs)
            .then { _ in self.navigateFeed?() }
    }
    func selectInterestsOnSaveAll() {
        InterestService.setUserAllInterests()
            .then { _ in self.navigateFeed?() }
    }
}



class SelectCityViewModelPrototype {

    var citiesPage: Int = 1
    var cities: [CityModel] = []
    var selectedCity: CityModel?
    var search: String?


    init() {
        print(".selectCityVM.init")

        self.fetchCities()
            .then { _ -> Void in
                print(".selectCityVM.fetchCities.done", self.cities.count)
            }
    }


    //MARK: - Events
    var didUpdate: (() -> Void)?
    var didSelectCity: ((CityModel) -> Void)?


    //MARK: - Inputs
    func onSelectCity(city: CityModel) {
        self.selectedCity = city
        self.didSelectCity?(city)
        self.didUpdate?()
    }
    func onChangeSearch(search: String?) {
        self.search = search
        // local search
        self.cities = self.getCities()
        self.didUpdate?()
        // server search
        self.fetchCitiesByName()
    }
    func onLoadNextPage() {
        if self.citiesPage > 1 && CityService.isLastPage {
            return
        }
        self.citiesPage += 1
        self.fetchCities()
    }


    private func fetchCities() -> Promise<Void> {
        return CityService.fetchCities(self.citiesPage)
            .then { _ -> Void in
                self.cities = self.getCities()
                self.didUpdate?()
        }
    }
    private func fetchCitiesByName() {
        CityService.fetchCitiesByName(self.search!)
            .then { _ -> Void in
                self.cities = self.getCities()
                self.didUpdate?()
            }
    }
    private func getCities() -> [CityModel] {
        var cities = CityService.getCities()
        if self.search != nil {
            cities = cities.filter("name CONTAINS[c] %@", search!)
        }
        return Array(cities)
    }

}




