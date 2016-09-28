//
//  MenuViewModel.swift
//  Happ
//
//  Created by Aigerim'sMac on 28.09.16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import Foundation


class MenuViewModel {
    
    let user: UserModel!

    var navigateProfile: NavigationFunc
    var navigateFeed: NavigationFunc
    var navigateSelectInterests: NavigationFunc
    var navigateEventPlanner: NavigationFunc
    var navigateSettings: NavigationFunc
    var navigateLogout: NavigationFunc

    init() {
        user = ProfileService.getUserProfile()
    }

    //MARK: - Inputs

    //NOTE:  there is no inputs, 
    // navigate functions are called directly inside MenuViewController
}
