//
//  SignInViewModel.swift
//  Happ
//
//  Created by MacBook Pro on 9/19/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import Foundation



class SignInViewModel {
    
    var navigateSignUp: NavigationFunc
    var navigateFeed: NavigationFunc


    //MARK: - Events
    var didUpdate: (() -> Void)?


    //MARK: - Inputs
    func clickedSignIn(username: String, password: String) -> Promise<NSNull> {
        return UserService.signIn(username, password: password)
            .then { _ -> Promise<JSON> in
                self.navigateFeed()
            }
            .then { _ -> Promise<JSON> in
                return Get("users/current/", parameters: nil)
            }
            .then { data -> Void in
                let userData = data.dictionaryValue
                print(".done.Get.users/current", userData["username"]?.stringValue)
            }
    }

    func clickedSignUp() {
        self.navigateSignUp()
    }

}
