//
//  AfterSignupViewModel.swift
//  Happ
//
//  Created by MacBook Pro on 11/8/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import Foundation
import PromiseKit


class SetupCityAndInterestsViewModel {

    var citySelected: CityModel?
    var interestsSelected: [InterestModel] = []

    var navigateSelectCity: NavigationFunc
    var navigateBack: NavigationFunc
    var navigateSelectInterests: NavigationFunc
    var navigateFeed: NavigationFunc

    
    init() {
    }

    //MARK: - Events
    var didUpdate: (() -> Void)?


    //MARK: - Inputs
    func onClickSelectCity() {
        self.navigateSelectCity?()
    }


    func onSelectCity(city: CityModel) {
        self.citySelected = city
        self.navigateBack?()
        self.didUpdate?()
    }
    func onSelectInterests(interests: [InterestModel]) {
        self.interestsSelected = interests
        self.didUpdate?()
    }

    func onSaveCityPage() {
        CityService.setUserCity(self.citySelected!.id)
            .then { _ in
                self.navigateSelectInterests?()
        }
    }
    func onSaveInterestsPage() {
        let interestIDs = self.interestsSelected.map{ $0.id }
        InterestService.setUserInterests(interestIDs)
            .then { _ in
                self.navigateFeed?()
        }
    }
}


extension SetupCityAndInterestsViewModel: SelectInterestsVMProtocol {
    func selectInterestsIsAllowsMultipleSelection() -> Bool {
        return true
    }
    func selectInterestsGetTitle() -> String {
        return self.citySelected!.name
    }
    func selectInterestsOnSave(selectedInterests: [InterestModel]) {
        self.onSelectInterests(selectedInterests)
        self.onSaveInterestsPage()
    }
}



