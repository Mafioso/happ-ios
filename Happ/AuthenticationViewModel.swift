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
    var navigateFeed: NavigationFunc
    var navigateSetup: NavigationFunc
    var navigateBack: NavigationFunc


    init() {
    }


    //MARK: - Events
    var didUpdate: (() -> Void)?
    var willDestroy: (() -> Void)?

    //MARK: - Inputs
    func onSignIn(username: String, password: String) -> Promise<Void> {
        return AuthenticationService.signIn(username, password: password)
            .then { data -> Void in
                self.willDestroy?()
                self.navigateFeed?()
            }
    }
    func onSignUp(username: String, password: String) -> Promise<Void> {
        return AuthenticationService.signUp(username, password: password, email: nil)
            .then { data -> Void in
                self.willDestroy?()
                self.navigateSetup?()
            }
    }

}


