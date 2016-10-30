//
//  SettingsViewModel.swift
//  Happ
//
//  Created by MacBook Pro on 9/30/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import Foundation


enum SettingsNotificationTypes {
    case NewInterests
    case EventUpdates
    case Chat
    case AppUpdates
}


class SettingsState {
    
    var currency: CurrencyModel?
    var notificationsMap: [SettingsNotificationTypes: Bool]

    init() { // TODO set from UserSettings
        self.currency = nil
        self.notificationsMap = [
            SettingsNotificationTypes.NewInterests: false,
            SettingsNotificationTypes.EventUpdates: false,
            SettingsNotificationTypes.Chat: false,
            SettingsNotificationTypes.AppUpdates: false
        ]
    }
}

class SettingsViewModel {

    var userSettings: SettingsDictModel!
    var currencies: [CurrencyModel] = []
    var state: SettingsState

    var navigateProfile: NavigationFunc
    var navigateSelectNotifications: NavigationFunc
    var navigateCitiesManager: NavigationFunc
    var navigateSelectCurrency: NavigationFunc
    var navigateContact: NavigationFunc
    var navigateHelp: NavigationFunc
    var navigateTerms: NavigationFunc
    var navigatePolicy: NavigationFunc

    var navigateBack: NavigationFunc
    var displaySlideMenu: NavigationFunc


    init() {
        self.state = SettingsState()

        self.userSettings = self.getUserSettings()
        self.currencies = self.getCurrencies()
    }

    //MARK: - Events
    var didCurrencyUpdate: (() -> Void)?
    var didNotificationsUpdate: (() -> Void)?


    //MARK: - Inputs
    func onSelectCurrency(currency: CurrencyModel) {
        self.state.currency = currency
        self.didCurrencyUpdate?()
    }
    func onSelectNotification(notification: SettingsNotificationTypes) {
        let oldValue = self.state.notificationsMap[notification]!
        self.state.notificationsMap.updateValue(!oldValue, forKey: notification)
        self.didNotificationsUpdate?()
    }
    func onSaveCurrency() {
        let currency = self.state.currency!
        ProfileService.setCurrency(currency.id)
            .then {_ -> Void in
                self.userSettings = self.getUserSettings()
                self.navigateBack?()
        }
    }
    func onSaveNotifications() {
        // TODO
        self.navigateBack?()
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


