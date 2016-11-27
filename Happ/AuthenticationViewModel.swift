//
//  SignInViewModel.swift
//  Happ
//
//  Created by MacBook Pro on 9/19/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import Foundation
import PromiseKit



class AuthenticationViewModel {

    var navigateSignUp: NavigationFunc
    var navigateSetup: NavigationFunc
    var navigateBack: NavigationFunc
    var navigateAfterLogin: NavigationFunc
    var navigatePrivacyPolicy: NavigationFunc


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

}


