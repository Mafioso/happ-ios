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

    var selectedCity: CityModel?
    var selectedInterests: [InterestModel: [InterestModel]?] = [:]
    /*
        [Interest1: nil]    <- not selected
        [Interest1: []]     <- selected all SubInterests
        [Interest1: [SubInterest1, SubInterest2]]   <- selected some of SubInterests
    */

    var navigateSelectCity: NavigationFunc
    var navigateBack: NavigationFunc
    var navigateFeed: NavigationFunc


    init() {
        // get from local DB
        //self.cities = self.getCities()
        //self.interests = self.getInterests()


        // update from Server
        ProfileService.fetchCities()
            .then { _ -> Void in
                self.cities = self.getCities()
        }
        ProfileService.fetchInterests()
            .then { _ -> Void in
                print(".fetchInterests.done")

                self.interests = self.getInterests()
                self.didUpdate?()
        }
    }


    //MARK: - Events
    var didUpdate: (() -> Void)?


    //MARK: - Inputs
    func onSelectInterest(interest: InterestModel) {
        let isSelected = (self.selectedInterests[interest] != nil)
        if !isSelected {
            self.selectedInterests.updateValue([], forKey: interest)
        } else {
            self.selectedInterests[interest] = nil
        }
        self.didUpdate?()
    }
    func onClickSelectCity() {
        self.navigateSelectCity!()
    }
    func onSelectCity(city: CityModel) {
        self.selectedCity = city
        self.navigateBack!()
    }
    func onClickDone() {
        if let selCity = self.selectedCity where self.selectedInterests.count != 0 {
            let selInterestIds = self.selectedInterests
                                    .filter({ $0.1 != nil })
                                    .map({ $0.0.id })

            ProfileService.setCity(selCity.id)
            ProfileService.setInterests(selInterestIds)
            self.navigateFeed!()

            /*
            firstly {
                ProfileService.setCity(selCity.id)
            }.then {
                ProfileService.setInterests(selInterestIds)
            }.then { _ -> Void in
                self.navigateFeed!()
            }.error({ error in
                print("...error", error)
            })
            */
        }
    }


    private func getCities() -> [CityModel] {
        let cities = ProfileService.getCitiesStored()
        return Array(cities)
    }

    private func getInterests() -> [InterestModel] {
        return Array(ProfileService.getInterestsStored())
    }

}



