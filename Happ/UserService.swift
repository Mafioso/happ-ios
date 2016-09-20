//
//  UserService.swift
//  Happ
//
//  Created by MacBook Pro on 9/19/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import Foundation
import SwiftyJSON
import PromiseKit
import KeychainSwift


let keyJWT = "auth0-jwt"

class UserService {

    class func signIn(username: String, password: String) -> Promise<Void> {
        let parameters = [
            "username": username,
            "password": password
        ]

        return Post("auth/login/", parameters: parameters, isAuthenticated: false)
            .then { data -> Void in
                UserService.storeCredential(data)
            }
    }

    class func signUp(username: String, password: String, email: String?) -> Promise<Void> {
        var parameters = [
            "username": username,
            "password": password
        ]
        if email != nil {
            parameters.merge(["email": email!])
        }

        return Post("auth/register/", parameters: parameters, isAuthenticated: false)
            .then { data  -> Void in
                UserService.storeCredential(data)
            }
    }


    // check for valid credential, fetch updated if was expired
    class func isCredentialAvailable() -> Promise<Bool> {
        return Promise { fulfill, reject in
            if let credential = UserService.getCredential() {
                // check here
                fulfill(true)
            } else {
                fulfill(false)
            }
        }
    }

    class func getCredential() -> String? {
        let jwt = KeychainSwift().get(keyJWT)
        return jwt
    }

    private class func storeCredential(data: JSON) {
        let jwt = data["token"].stringValue
        KeychainSwift().set(jwt, forKey: keyJWT)
    }
    
}



