//
//  MenuViewModel.swift
//  Happ
//
//  Created by Aigerim'sMac on 28.09.16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import Foundation


enum MenuViewModelStateTypes {
    case ChangeCity
    case Normal

    func opposite() -> MenuViewModelStateTypes {
        switch self {
        case .Normal:
            return .ChangeCity
        case .ChangeCity:
            return .Normal
        }
    }
}

enum MenuActions: Int {
    case Feed = 0
    case SelectInterests = 1
    case EventPlanner = 2
    case Settings = 11
    case Logout = 12
}


class MenuViewModel {

    var highlight: MenuActions
    var state: MenuViewModelStateTypes = .Normal
    var city: CityModel

    var navigateBack: NavigationFunc
    var navigateProfile: NavigationFunc
    var navigateFeed: NavigationFunc
    var navigateSelectInterests: NavigationFunc
    var navigateEventPlanner: NavigationFunc
    var navigateSettings: NavigationFunc
    var navigateLogout: NavigationFunc

    init(highlight: MenuActions) {
        self.highlight = highlight
        self.city = ProfileService.getUserCity()
    }


    //MARK: - Events
    var didUpdate: (() -> Void)?

    //MARK: - Inputs
    func onClickAction(action: MenuActions) {
        switch action {
        case .Feed:
            self.navigateFeed?()
        case .SelectInterests:
            self.navigateSelectInterests?()
        case .EventPlanner:
            //TODO self.navigateEventPlanner?()
            break
        case .Settings:
            self.navigateSettings?()
        case .Logout:
            self.navigateLogout?()
        }
    }
    func onClickChangeCity() {
        self.state = self.state.opposite()
        self.didUpdate?()
    }
    func onChangeCity(city: CityModel) {
        self.state = .Normal
        self.city = city
        self.didUpdate?()

        self.navigateSelectInterests?()
    }



    func getUser() -> UserModel {
        return ProfileService.getUserProfile()
    }

}

