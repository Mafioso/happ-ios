//
//  Requests.swift
//  Happ
//
//  Created by MacBook Pro on 9/7/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit


let Host = "http://happ.westeurope.cloudapp.azure.com"
let HostAPI = Host + "/api/v1/"


enum RequestError: Int, ErrorType, CustomStringConvertible {
    case SignInIncorrect
    case NoInternet
    case BadRequest = -6003
    case BadResponse = -1017
    case NoResponseIsTimedOut = -1001
    case UnknownError

    var description: String {
        switch self {
        case .BadRequest:
            return "Please, check your input data"
        case .BadResponse:
            return "cannot parse response"
        case .NoInternet:
            return "No Internet =( \n Please, check connection."
        case .NoResponseIsTimedOut:
            return "The request timed out"
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
        let accessToken = UserService.getCredential()
        headers.merge(["Authorization": "JWT " + accessToken!])
    }
    return headers
}



func Post(endpoint: String, parameters: [String: AnyObject]?, isAuthenticated: Bool = true) -> Promise<AnyObject> {
    return Promise { resolve, reject in
        let url = HostAPI + endpoint

        Alamofire
            .request(.POST, url, headers: getRequestHeaders(isAuthenticated), parameters: parameters, encoding: .JSON)
            .validate()
            .responseJSON { response in

                switch response.result {
                case .Success:
                    resolve(response.result.value!)
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


func Get(endpoint: String, parameters: [String: AnyObject]?, isPaginated: Bool = false) -> Promise<AnyObject> {
    return Promise { resolve, reject in
        let url = HostAPI + endpoint

        Alamofire
            .request(.GET, url, headers: getRequestHeaders(), parameters: parameters, encoding: .JSON)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success:

                    if isPaginated {
                        let paginatedResponse = response.result.value as! NSDictionary
                        let results = paginatedResponse["results"] as! [AnyObject]
                        resolve(results)
                    } else {
                        resolve(response.result.value!)
                    }
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


