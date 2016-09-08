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
    case BadRequest = -6003
    case BadResponse = -1017
    case UnknownError

    var description: String {
        switch self {
        case .BadRequest:
            return "Please, check your input data"
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


func getRequestHeaders(isAuthenticated: Bool = true) -> [String: String] {
    var headers = [
        "Accept": "application/json"
    ]
    if isAuthenticated {
        headers.merge(["Authorization": "JWT " + AccessToken!])
    }
    return headers
}



func PostSignIn(username: String, password: String) -> Promise<Void> {
    let parameters = [
        "username": username,
        "password": password
    ]
    
    return Post("auth/login/", parameters: parameters, isAuthenticated: false)
        .then { data in
            AccessToken = data["token"].stringValue
        }
}


func PostSignUp(username: String, password: String, email: String?) -> Promise<Void> {
    var parameters = [
        "username": username,
        "password": password
    ]
    if email != nil {
        parameters.merge(["email": email!])
    }

    return Post("auth/register/", parameters: parameters, isAuthenticated: false)
        .then { data in
            AccessToken = data["token"].stringValue
        }
}


func Post(endpoint: String, parameters: [String: AnyObject]?, isAuthenticated: Bool = true) -> Promise<JSON> {
    return Promise { resolve, reject in
        
        let url = HostAPI + endpoint

        Alamofire
            .request(.POST, url, headers: getRequestHeaders(isAuthenticated), parameters: parameters, encoding: .JSON)
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
                        print(".Post.error", endpoint, parameters, error, error.code)
                        reject(RequestError.UnknownError)
                    }
                }
                
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
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


