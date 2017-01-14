//
//  FacebookAuthProtocol.swift
//  Happ
//
//  Created by MacBook Pro on 12/28/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin
import PromiseKit
import SwiftyJSON
import FBSDKCoreKit


let loc_auth_facebook_warning_title_canceled = NSLocalizedString("Login Cancelled", comment: "Warning title displayed after Facebook's form when Login is canceled")
let loc_auth_facebook_warning_body_canceled = NSLocalizedString("User cancelled login.", comment: "Warning body displayed after Facebook's form when Login is canceled")
let loc_auth_facebook_warning_title_fail = NSLocalizedString("Login Fail", comment: "Warning title displayed after Facebook's form when Login fail occured")
let loc_auth_facebook_warning_body_fail = NSLocalizedString("Login failed with error: ", comment: "Warning body displayed after Facebook's form when Login fail occured")
let loc_auth_facebook_warning_title_success = NSLocalizedString("Login Success", comment: "Warning title displayed after Facebook's form on Success Login")
let loc_auth_facebook_warning_body_success = NSLocalizedString("Login succeeded with granted permissions: ", comment: "Warning body displayed after Facebook's form on Success Login")


protocol FacebookAuthProtocol: class {
    func fbLogin() -> Promise<LoginResult>
    func fbLoginManagerDidComplete(result: LoginResult)
    func fbFetchProfileData() -> Promise<JSON>
    func fbLogout()
}


extension FacebookAuthProtocol where Self: UIViewController {

    func fbFetchProfileData() -> Promise<JSON> {
        return Promise { resolve, reject in
            let connection = GraphRequestConnection()
            let fields = ["fields": "id, name, gender, age_range, email"]
            let version = FBSDK_TARGET_PLATFORM_VERSION
            let request = GraphRequest(graphPath: "/me", parameters: fields, accessToken: AccessToken.current, httpMethod: .GET, apiVersion: version)

            connection.add(request) { httpResponse, result in
                switch result {
                case .Success(let response):
                    resolve(JSON(response.dictionaryValue!))
                case .Failed(let error):
                    reject(error)
                }
            }
            connection.start()
        }
    }

    func fbLoginManagerDidComplete(result: LoginResult) {
        let alertController: UIAlertController
        switch result {
        case .Cancelled:
            alertController = UIAlertController(title: loc_auth_facebook_warning_title_canceled, message: loc_auth_facebook_warning_body_canceled, preferredStyle: .Alert)
        case .Failed(let error):
            alertController =  UIAlertController(title: loc_auth_facebook_warning_title_fail, message: loc_auth_facebook_warning_body_fail + "\(error)", preferredStyle: .Alert)
        case .Success(let grantedPermissions, _, _):
            alertController = UIAlertController(title: loc_auth_facebook_warning_title_success, message: loc_auth_facebook_warning_body_success + "\(grantedPermissions)", preferredStyle: .Alert)
        }
        self.presentViewController(alertController, animated: true, completion: nil)
    }

    func fbLogin() -> Promise<LoginResult> {
        let loginManager = LoginManager()
        return Promise { resolve, reject in
            loginManager.logIn([.PublicProfile, .Email], viewController: self) { result in
                resolve(result)
            }
        }
    }

    func fbLogout() {
        let loginManager = LoginManager()
        loginManager.logOut()
    }
}


