//
//  ProfileViewModel.swift
//  Happ
//
//  Created by MacBook Pro on 9/28/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import Foundation
import PromiseKit


enum SelectCityInterestsDidUpdateTypes {
    case CitiesList
    case InterestsList
    case SelectedCity
}

class SelectCityInterestsViewModel {

    var cities: [CityModel] = []
    var interests: [InterestModel] = []
    var selectedCity: CityModel?

    var navigateSelectCity: NavigationFunc
    var navigateBack: NavigationFunc


    init() {
        // get from local DB
        //self.cities = self.getCities()
        //self.interests = self.getInterests()

        // update from Server
        ProfileService.fetchCitiesFromServer()
            .then { _ -> Void in
                self.cities = self.getCities()
                //print(".fetch.cities.Done", self.cities)
                self.didUpdate?(.CitiesList)
        }
        ProfileService.fetchInterestsFromServer()
            .then { _ -> Void in
                self.interests = self.getInterests()
                //print(".fetch.interests.Done", self.interests)
                self.didUpdate?(.InterestsList)
        }
    }


    //MARK: - Events
    var didUpdate: (((SelectCityInterestsDidUpdateTypes)) -> Void)?


    //MARK: - Inputs
    func onSelectInterest(interest: InterestModel) {
        // TODO insert SubInterest cell below selected Interest
    }
    func onClickSelectCity() {
        self.navigateSelectCity!()
    }
    func onSelectCity(city: CityModel) {
        
        print(".onSelectCity", city, self.navigateBack)

        self.selectedCity = city
        self.navigateBack!()
        //self.didUpdate?(.SelectedCity)
    }


    private func getCities() -> [CityModel] {
        return Array(ProfileService.getCitiesStored())
    }

    private func getInterests() -> [InterestModel] {
        return Array(ProfileService.getInterestsStored())
    }

}



