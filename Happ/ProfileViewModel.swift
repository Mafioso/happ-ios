//
//  ProfileViewModel.swift
//  Happ
//
//  Created by MacBook Pro on 10/1/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import Foundation
import PromiseKit


class ProfileViewModel {
    
    var userProfile: UserModel!

    var navigateBack: NavigationFunc
    var navigateChangePassword: NavigationFunc
    

    init() {
        self.userProfile = self.getUserProfile()
    }


    //MARK: - Events
    var didUpdate: (() -> Void)?


    //MARK: - Inputs
    func onChangeProfile(values: [String: AnyObject]) -> Promise<AnyObject> {
        return ProfileService.updateUserProfile(values)
    }
    func onChangePassword(values: [String: AnyObject]) -> Promise<AnyObject> {
        let oldPassword = values["old_password"] as! String
        let newPassword = values["new_password"] as! String
        return AuthenticationService.updatePassword(oldPassword, newPassword: newPassword)
    }


    private func getUserProfile() -> UserModel {
        ProfileService
            .fetchUserProfile()
            .then {
                self.userProfile = ProfileService.getUserProfile()
        }

        return ProfileService.getUserProfile()
    }
}



