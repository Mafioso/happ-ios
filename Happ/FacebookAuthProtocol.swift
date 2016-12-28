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
            alertController = UIAlertController(title: "Login Cancelled", message: "User cancelled login.", preferredStyle: .Alert)
        case .Failed(let error):
            alertController =  UIAlertController(title: "Login Fail", message: "Login failed with error \(error)", preferredStyle: .Alert)
        case .Success(let grantedPermissions, _, _):
            alertController = UIAlertController(title: "Login Success", message: "Login succeeded with granted permissions: \(grantedPermissions)", preferredStyle: .Alert)
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


