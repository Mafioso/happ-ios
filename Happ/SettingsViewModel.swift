//
//  SettingsViewModel.swift
//  Happ
//
//  Created by MacBook Pro on 9/30/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import Foundation



class SettingsViewModel {

    var userSettings: SettingsDictModel!
    var currency: CurrencyModel? // TODO load from GetCurrency
    var currencies: [CurrencyModel] = []


    var navigateSelectCity: NavigationFunc
    var navigateSelectCurrency: NavigationFunc
    var navigateSelectNotifications: NavigationFunc

    var navigateContact: NavigationFunc
    var navigateHelp: NavigationFunc
    var navigateTerms: NavigationFunc
    
    var navigateBack: NavigationFunc


    init() {
        self.userSettings = self.getUserSettings()
        self.currencies = self.getCurrencies()
    }


    //MARK: - Inputs
    func onSelectCurrency(currency: CurrencyModel) {
        ProfileService.setCurrency(currency.id)
            .then {_ -> Void in
                self.userSettings = self.getUserSettings()
                self.navigateBack!()
        }
    }


    private func getCurrencies() -> [CurrencyModel] {
        ProfileService
            .fetchCurrencies()
            .then {
                self.currencies = Array(ProfileService.getCurrenciesStored())
        }

        return Array(ProfileService.getCurrenciesStored())
    }

    private func getUserSettings() -> SettingsDictModel {
        ProfileService
            .fetchUserProfile()
            .then {
                self.userSettings = ProfileService.getUserProfile().settings!
        }

        return ProfileService.getUserProfile().settings!
    }
}


