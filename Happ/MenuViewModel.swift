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

class MenuViewModel {

    var user: UserModel!
    var scope: MenuViewModelScope = .Normal

    var navigateBack: NavigationFunc
    var navigateProfile: NavigationFunc
    var navigateFeed: NavigationFunc
    var navigateSelectInterests: NavigationFunc
    var navigateEventPlanner: NavigationFunc
    var navigateSettings: NavigationFunc
    var navigateLogout: NavigationFunc

    init() {
        self.user = ProfileService.getUserProfile()

    }

    //MARK: - Inputs
    func onChangeScope(scope: MenuViewModelScope) {
        self.scope = scope
        self.didUpdate?()
    }

    //MARK: - Events
    var didUpdate: (() -> Void)?


}
