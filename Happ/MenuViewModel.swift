//
//  MenuViewModel.swift
//  Happ
//
//  Created by Aigerim'sMac on 28.09.16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import Foundation


enum MenuViewModelScope {
    case ChangeCity
    case Normal

    func opposite() -> MenuViewModelScope {
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

    var user: UserModel
    var highlight: MenuActions
    var scope: MenuViewModelScope = .Normal

    var navigateBack: NavigationFunc
    var navigateProfile: NavigationFunc
    var navigateFeed: NavigationFunc
    var navigateSelectInterests: NavigationFunc
    var navigateEventPlanner: NavigationFunc
    var navigateSettings: NavigationFunc
    var navigateLogout: NavigationFunc

    init(highlight: MenuActions) {
        self.highlight = highlight
        self.user = ProfileService.getUserProfile()
    }

    //MARK: - Inputs
    func onChangeScope(scope: MenuViewModelScope) {
        self.scope = scope
        self.didUpdate?()
    }
    func onClickAction(action: MenuActions) {
        switch action {
        case .Feed:
            self.navigateFeed?()
        case .SelectInterests:
            self.navigateSelectInterests?()
        case .EventPlanner:
            self.navigateEventPlanner?()
        case .Settings:
            self.navigateSettings?()
        case .Logout:
            self.navigateLogout?()
        }
    }

    //MARK: - Events
    var didUpdate: (() -> Void)?


}
