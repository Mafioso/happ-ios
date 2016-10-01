//
//  AuthenticationService.swift
//  Happ
//
//  Created by MacBook Pro on 9/19/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import Foundation
import PromiseKit
import KeychainSwift


let keyJWT = "auth0-jwt"

class AuthenticationService {

    class func signIn(username: String, password: String) -> Promise<Void> {
        let parameters = [
            "username": username,
            "password": password
        ]

        return Post("auth/login/", parameters: parameters, isAuthenticated: false)
            .then { (data: AnyObject) -> Void in
                self.storeCredential(data as! [String : AnyObject])
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
            .then { (data: AnyObject) -> Void in
                self.storeCredential(data as! [String : AnyObject])
            }
    }

    class func updatePassword(oldPassword: String, newPassword: String) -> Promise<AnyObject> {
        let params = [
            "old_password": oldPassword,
            "new_password": newPassword
        ]
        return Post("auth/password/change", parameters: params, isAuthenticated: true)
    }
    
    
    // check for valid credential, fetch updated if was expired
    class func isCredentialAvailable() -> Promise<Bool> {
        return Promise { fulfill, reject in
            if let credential = self.getCredential() {
                // check here
                fulfill(true)
            } else {
                fulfill(false)
            }
        }
    }

    class func logOut() {
        self.deleteCredential()
    }
    
    class func getCredential() -> String? {
        let jwt = KeychainSwift().get(keyJWT)
        return jwt
    }
    
    private class func storeCredential(data: [String: AnyObject]) {
        let jwt = data["token"] as! String
        KeychainSwift().set(jwt, forKey: keyJWT)
    }

    private class func deleteCredential() {
        KeychainSwift().clear()
    }
}



