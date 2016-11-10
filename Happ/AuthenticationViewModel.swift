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
    var navigateSelectCityInterests: NavigationFunc
    var navigateSetup: NavigationFunc
    var navigateBack: NavigationFunc


    init() {
        
    }


    //MARK: - Events
    var didUpdate: (() -> Void)?


    //MARK: - Inputs
    func onSignIn(username: String, password: String) -> Promise<Void> {
        return AuthenticationService.signIn(username, password: password)
            .then { data -> Void in
                self.navigateSetup?()
            }
    }
    func onSignUp(username: String, password: String) -> Promise<Void> {
        return AuthenticationService.signUp(username, password: password, email: nil)
            .then { data -> Void in
                self.navigateSelectCityInterests?()
            }
    }


}
