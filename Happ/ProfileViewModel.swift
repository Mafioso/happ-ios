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
    var avatar: UIImage?
    var avatarModel: ImageModel?
    var isUploadingAvatar: Bool = false

    var navigateBack: NavigationFunc
    var navigateChangePassword: NavigationFunc


    init() {
        self.setProfile()
    }

    //MARK: - Events
    var didUpdate: (() -> Void)?


    //MARK: - Inputs
    func onPickImage(image: UIImage) {
        self.isUploadingAvatar = true
        self.avatar = image
        self.didUpdate?()

        UploadImage(image)
            .then { imageData -> Void in
                self.avatarModel = imageData
                self.isUploadingAvatar = false
                self.didUpdate?()
            }
            .error { err in
                self.avatarModel = nil
                self.avatar = nil
                self.isUploadingAvatar = false
                self.didUpdate?()
            }
    }
    func onSave(values: [String: AnyObject]) -> Promise<Void> {
        return Promise { resolve, reject in
                firstly {
                    return ProfileService.updateUserProfile(values)
                }
                .then { _ -> Promise<Void> in
                    return self.updatePassword(values)
                }
                .then { self.setProfile() }
                .then { _ -> Void in
                    resolve()
                }
                .error { err in
                    if let profileError = err as? ProfileErrorTypes {
                        reject(profileError)
                    } else {
                        reject(ProfileErrorTypes.BadValues)
                    }
                }
        }
    }


    private func updatePassword(values: [String: AnyObject]) -> Promise<Void> {
        return Promise { resolve, reject in
            if  let oldPassword = values["old_password"] as? String,
                let newPassword = values["new_password"] as? String
                where !newPassword.characters.isEmpty {

                let confirmPassword = values["confirm_password"] as! String
                if confirmPassword != newPassword {
                    reject(ProfileErrorTypes.BadConfirm)
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

            } else {
                resolve()
            }
        }
    }

    private func setProfile() {
        self.userProfile = ProfileService.getUserProfile()
        self.didUpdate?()
    }
}



