//
//  SignInViewModel.swift
//  Happ
//
//  Created by MacBook Pro on 9/19/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import Foundation
import PromiseKit



class SignInViewModel {
    
    var navigateSignUp: NavigationFunc
    var navigateFeed: NavigationFunc


    init() {
        
    }


    //MARK: - Events
    var didUpdate: (() -> Void)?


    //MARK: - Inputs
    func clickedSignIn(username: String, password: String) -> Promise<Void> {
        return UserService.signIn(username, password: password)
            .then { data -> Void in
                self.navigateFeed!()
            }
    }

    func clickedSignUp() {
        self.navigateSignUp!()
    }

}
