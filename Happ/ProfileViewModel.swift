//
//  ProfileViewModel.swift
//  Happ
//
//  Created by MacBook Pro on 10/1/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import Foundation
import PromiseKit


enum ProfileErrorTypes: ErrorType {
    case BadConfirm
    case BadPassword
    case BadValues
}

class ProfileViewModel {

    var userProfile: UserModel!

    var navigateBack: NavigationFunc
    var navigateChangePassword: NavigationFunc


    init() {
        self.userProfile = ProfileService.getUserProfile()
    }


    //MARK: - Events
    var didUpdate: (() -> Void)?


    //MARK: - Inputs
    func onSave(values: [String: AnyObject]) -> Promise<Void> {
        return Promise { resolve, reject in

            func updatePassword() -> Bool {
                if  let old = values["old_password"],
                    let new = values["new_password"] {

                    let oldPassword = old as! String
                    let newPassword = new as! String
                    let confirmPassword = values["confirm_password"] as! String

                    if confirmPassword != newPassword {
                        reject(ProfileErrorTypes.BadConfirm)
                        return false
                    }

                    AuthenticationService.updatePassword(oldPassword, newPassword: newPassword)
                        .then { _ in
                            resolve()
                        }
                        .error { err in
                            if  let reqError = err as? RequestError
                                where reqError == RequestError.BadRequest {
                                reject(ProfileErrorTypes.BadPassword)
                            } else {
                                reject(err)
                            }
                        }
                    return true
                }
                return false
            }

            ProfileService.updateUserProfile(values)
                .then { _ -> Void in
                    self.userProfile = ProfileService.getUserProfile()

                    if !updatePassword() {
                        resolve()
                    }
                }
                .error { err in
                    reject(ProfileErrorTypes.BadValues)
                }
        }
    }


}



