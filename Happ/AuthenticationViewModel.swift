//
//  SignInViewModel.swift
//  Happ
//
//  Created by MacBook Pro on 9/19/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import Foundation
import PromiseKit
import SwiftyJSON


class AuthenticationViewModel {

    var navigateSignUp: NavigationFunc
    var navigateSetup: NavigationFunc
    var navigateBack: NavigationFunc
    var navigateAfterLogin: NavigationFunc
    var navigatePrivacyPolicyPage: NavigationFunc
    var navigateTermsPolicyPage: NavigationFunc


    init() {
    }


    //MARK: - Inputs
    func onSignIn(username: String, password: String) -> Promise<Void> {
        return AuthenticationService.signIn(username, password: password)
            .then { _ -> Void in
                self.navigateAfterLogin?()
            }
    }
    func onSignUp(username: String, password: String) -> Promise<Void> {
        return AuthenticationService.signUp(username, password: password, email: nil)
            .then { _ -> Void in
                self.navigateSetup?()
            }
    }
    func onLoggedInFacebook(fbUserID: String) -> Promise<Void> {
        return AuthenticationService.facebookLogin(fbUserID)
            .then { _ -> Void in
                self.navigateAfterLogin?()
        }
    }
    func onRegisterByFacebookData(data: JSON) -> Promise<Void> {
        let data = data.dictionaryValue

        let fbUserID = data["id"]!.stringValue
        var info: [String: AnyObject] = [
            "fullname": data["name"]!.stringValue,
            "gender": (data["gender"]!.stringValue == "female") ? 0 : 1
        ]
        if let email = data["email"]?.stringValue {
            info.updateValue(email, forKey: "email")
        }

        return AuthenticationService.facebookRegister(fbUserID, info: info)
            .then { _ -> Void in
                self.navigateSetup?()
            }
    }

}


