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
        self.navigateFeed?()
        /*
        InterestService.setUserInterests(interestIDs)
            .then { _ in
                self.navigateFeed?()
        }
        */
    }
}



class SelectCityViewModelPrototype {

    var citiesPage: Int = 1
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
    func onLoadNextPage() {
        if self.citiesPage > 1 && CityService.isLastPage {
            return
        }
        self.citiesPage += 1
        self.fetchCities()
    }


    private func willLoad() {
        self.fetchCities().then { _ -> Void in
            print(".selectCityVM.fetchCities.done", self.cities.count)
            self.didLoad?()
            self.didUpdate?()
        }
    }
    private func fetchCities() -> Promise<Void> {
        return CityService.fetchCities(self.citiesPage)
            .then { _ -> Void in
                self.cities = self.getCities()
                self.didUpdate?()
        }
    }
    private func getCities() -> [CityModel] {
        var cities = CityService.getCities()
        if self.search != nil {
            cities = cities.filter("name CONTAINS %@", search!)
        }
        return Array(cities)
    }

}




