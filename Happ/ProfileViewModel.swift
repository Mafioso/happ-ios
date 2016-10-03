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
            .then { _ -> AnyObject in
                self.navigateBack!()
                return NSNull()
        }
    }
    func onSave(values: [String: AnyObject], passwordValues: [String: AnyObject]) -> Promise<AnyObject> {
        return self.onSave(values)
            .then { _ in
                let oldPassword = passwordValues["old_password"] as! String
                let newPassword = passwordValues["new_password"] as! String
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
