//
//  ProfileViewModel.swift
//  Happ
//
//  Created by MacBook Pro on 9/28/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import Foundation
import PromiseKit


class SelectCityInterestsViewModel {

    var cities: [CityModel] = []
    var interests: [InterestModel] = []

    var navigateSelectCity: NavigationFunc


    init() {
        // get from local DB
        self.cities = self.getCities()
        self.interests = self.getInterests()

        // update from Server
        ProfileService.fetchCitiesFromServer()
            .then { _ -> Void in
                self.cities = self.getCities()
                self.didUpdateCities?()
        }
        ProfileService.fetchInterestsFromServer()
            .then { _ -> Void in
                self.interests = self.getInterests()
                self.didUpdateInterests?()
        }
    }


    //MARK: - Events
    var didUpdateCities: (() -> Void)?
    var didUpdateInterests: (() -> Void)?


    //MARK: - Inputs
    func onSelectInterest(interest: InterestModel) {
        // TODO insert SubInterest cell below selected Interest
    }
    func onClickSelectCity() {
        self.navigateSelectCity!()
    }


    private func getCities() -> [CityModel] {
        return Array(ProfileService.getCitiesStored())
    }

    private func getInterests() -> [InterestModel] {
        return Array(ProfileService.getInterestsStored())
    }

}



