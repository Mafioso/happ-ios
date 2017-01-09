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
import FacebookCore
import FacebookLogin


let keyJWT = "auth0-jwt"


enum AuthenticationErrors: ErrorType {
    case NoCredentials
    case CredentialsExpired
    case FacebookUserNotRegistered
    case FacebookNoCredentials
}

class AuthenticationService {
    
    class func requestConfirm(email: String) -> Promise<Void> {
        let parameters = [
            "email": email
        ]
        
        return Post("auth/email/confirm/request/", parameters: parameters, paramsEncoding: .JSON)
            .then { data -> Void in }
    }
    
    class func confirm(token: String) -> Promise<Void> {
        let parameters = [
            "key": token
        ]
        
        return Post("auth/email/confirm/", parameters: parameters, paramsEncoding: .JSON, isAuthenticated: true)
            .then { data -> Void in }
    }

    class func facebookLogin(fbUserID: String) -> Promise<Void> {
        let params = [
            "facebook_id": fbUserID
        ]
        return Promise { resolve, reject in
            Post("auth/login/facebook/", parameters: params, paramsEncoding: .JSON, isAuthenticated: false)
            .then { (data: AnyObject) -> Void in
                self.storeCredential(data as! [String : AnyObject])
            }
            .then { _ in resolve() }
            .error { err in
                switch err {
                case RequestError.BadRequest:
                    reject(AuthenticationErrors.FacebookUserNotRegistered)
                default:
                    reject(err)
                }
            }
        }
    }

    class func facebookRegister(fbUserID: String, info: [String: AnyObject]) -> Promise<Void> {
        var params = info
        params.updateValue(fbUserID, forKey: "facebook_id")
        return Post("auth/register/facebook/", parameters: params, paramsEncoding: .JSON, isAuthenticated: false)
            .then { (data: AnyObject) -> Void in
                self.storeCredential(data as! [String : AnyObject])
            }
    }

    class func signIn(username: String, password: String) -> Promise<Void> {
        let parameters = [
            "username": username,
            "password": password
        ]

        return Post("auth/login/", parameters: parameters, paramsEncoding: .JSON, isAuthenticated: false)
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

        return Post("auth/register/", parameters: parameters, paramsEncoding: .JSON, isAuthenticated: false)
            .then { (data: AnyObject) -> Void in
                self.storeCredential(data as! [String : AnyObject])
            }
    }

    class func updatePassword(oldPassword: String, newPassword: String) -> Promise<AnyObject> {
        let params = [
            "old_password": oldPassword,
            "new_password": newPassword
        ]
        return PostRAW("auth/password/change/", parametersAnyObject: params)
    }


    // check for valid credential, fetch updated if was expired
    class func checkCredentialAvailable() -> Promise<Void> {
        return Promise { fulfill, reject in
            if let credential = self.getCredential() {
                //print(credential)
                // TODO check here
                // reject(AuthenticationErrors.CredentialsExpired)
                fulfill()
            } else {
                reject(AuthenticationErrors.NoCredentials)
            }
        }
    }

    class func checkFacebookCredentialAvailable() -> Promise<Void> {
        return Promise { fulfill, reject in
            if AccessToken.current != nil {
                fulfill()
            } else {
                reject(AuthenticationErrors.FacebookNoCredentials)
            }
        }
    }

    class func logOut() {
        self.deleteCredential()
        self.facebookLogOut()
    }

    class func facebookLogOut() {
        let loginManager = LoginManager()
        loginManager.logOut()
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



