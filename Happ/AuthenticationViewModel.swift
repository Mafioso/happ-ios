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
    var navigateFeed: NavigationFunc


    init() {
        
    }


    //MARK: - Events
    var didUpdate: (() -> Void)?


    //MARK: - Inputs
    func clickedSignIn(username: String, password: String) -> Promise<Void> {
        return AuthenticationService.signIn(username, password: password)
            .then { data -> Void in
                self.navigateFeed!()
            }
    }
    func clickedSignUp(username: String, password: String, email: String?) -> Promise<Void> {
        return AuthenticationService.signUp(username, password: password, email: email)
            .then { data -> Void in
                self.navigateSelectCityInterests!()
            }
    }
    func clickedSignUp() {
        self.navigateSignUp!()
    }


}
