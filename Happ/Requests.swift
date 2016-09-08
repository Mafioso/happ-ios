//
//  Requests.swift
//  Happ
//
//  Created by MacBook Pro on 9/7/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import PromiseKit


let Host = "http://happ.westeurope.cloudapp.azure.com"
let HostAPI = Host + "/api/v1/"
var AccessToken: String?


enum RequestError: Int, ErrorType, CustomStringConvertible {
    case SignInIncorrect
    case NoInternet
    case BadResponse = -1017
    case UnknownError

    var description: String {
        switch self {
        case .BadResponse:
            return "cannot parse response"
        case .NoInternet:
            return "No Internet =( \n Please, check connection."
        case .SignInIncorrect:
            return "Incorrect username or password"
        case .UnknownError:
            return "🈵 Unknown error! Check log outputs"
        }
    }
}


func getRequestHeaders() -> [String: String] {
    let headers = [
        "Authorization": "JWT " + AccessToken!,
        "Accept": "application/json"
    ]
    return headers
}


func PostSignIn(username: String, password: String) -> Promise<Void> {
    return Promise { resolve, reject in

        let parameters = [
            "username": username,
            "password": password
        ]
        Alamofire
            .request(.POST, HostAPI+"auth/login/", parameters: parameters, encoding: .JSON)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success(let dict):
                    let token = dict["token"] as! String
                    AccessToken = token
                    resolve()

                case .Failure(let error):
                    if let reqErrorType = RequestError(rawValue: error.code) {
                        reject(reqErrorType)
                    } else {
                        print(".SignIn.error", parameters, error, error.code)
                        reject(RequestError.UnknownError)
                    }
                }
        }
    }
}


func Get(endpoint: String, parameters: [String: AnyObject]?) -> Promise<JSON> {
    return Promise { resolve, reject in

        let url = HostAPI + endpoint

        Alamofire
            .request(.GET, url, headers: getRequestHeaders(), parameters: parameters, encoding: .JSON)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success:
                    let swiftedJSON = JSON(response.result.value!)
                    resolve(swiftedJSON)

                case .Failure(let error):
                    if let reqErrorType = RequestError(rawValue: error.code) {
                        reject(reqErrorType)
                    } else {
                        print(".Get.error", endpoint, parameters, error, error.code)
                        reject(RequestError.UnknownError)
                    }
                }

                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            }

        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
}


