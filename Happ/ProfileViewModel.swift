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
    

    init() {
        self.userProfile = self.getUserProfile()
    }


    //MARK: - Events
    var didUpdate: (() -> Void)?


    //MARK: - Inputs
    func onSave(values: [String: AnyObject]) -> Promise<AnyObject> {
        return ProfileService.updateUserProfile(values)
    }
    func onSave(values: [String: AnyObject], passwordValues: [String: AnyObject]) -> Promise<AnyObject> {
        return self.onSave(values)
            .then { _ in
                let oldPassword = passwordValues[ProfileControllerFields.PasswordCurrent.rawValue] as! String
                let newPassword = passwordValues[ProfileControllerFields.PasswordNew.rawValue] as! String
                return AuthenticationService.updatePassword(oldPassword, newPassword: newPassword)
        }
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
