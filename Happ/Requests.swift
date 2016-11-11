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
let HostLocal = "http://127.0.0.1:8000"
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
        let accessToken = AuthenticationService.getCredential()
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
                        // print(".Post.error", endpoint, parameters, error, error.code)
                        reject(RequestError.UnknownError)
                    }
                    print(".Post.error", endpoint, parameters, error, error.code)
                }

                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }

}

func Post(endpoint: String, parametersJSON: NSData?, isAuthenticated: Bool = true) -> Promise<AnyObject> {
    return Promise { resolve, reject in
        let url = HostAPI + endpoint
        let headers = getRequestHeaders(isAuthenticated)

        let nsURL = NSURL(string: url)
        let request = NSMutableURLRequest(URL: nsURL!)
        request.HTTPMethod = "POST"
        request.HTTPBody = parametersJSON
        headers.forEach({ request.setValue($0.1, forHTTPHeaderField: $0.0) })

        Alamofire
            .request(request)
            .validate()
            .validate(statusCode: [405])
            .response { (request, response, data, error) in

                print(".here", request, response)

                if error == nil {
                    resolve(NSNull())
                } else {
                    if let reqErrorType = RequestError(rawValue: error!.code) {
                        reject(reqErrorType)
                    } else {
                        // print(".Post.error", endpoint, parameters, error, error.code)
                        reject(RequestError.UnknownError)
                    }
                }

                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
}



func Get(endpoint: String, parameters: [String: AnyObject]?) -> Promise<AnyObject> {
    return Promise { resolve, reject in
        let url = HostAPI + endpoint
        let request = createRequest(url, parameters: parameters)
        request
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success:
                    resolve(response.result.value!)

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

func GetPaginated(endpoint: String, parameters: [String: AnyObject]?) -> Promise<(AnyObject, Bool)> {
    return Promise { resolve, reject in
        let url = HostAPI + endpoint
        let request = createRequest(url, parameters: parameters)
        request
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success:
                    let paginatedResponse = response.result.value as! NSDictionary
                    let results = paginatedResponse["results"] as! [AnyObject]
                    let isLastPage = paginatedResponse["next"] is NSNull
                    resolve((results, isLastPage))

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



private func createRequest(url: String, parameters: [String: AnyObject]?) -> Request {
    // create Request
    var  request: Request!
    if parameters == nil {
        let nsURL = NSURL(string: url)
        let headers = getRequestHeaders()
        let nsRequest = NSMutableURLRequest(URL: nsURL!)
        nsRequest.HTTPMethod = "GET"
        headers.forEach({ nsRequest.setValue($0.1, forHTTPHeaderField: $0.0) })
        request = Alamofire.request(nsRequest)
    } else {
        request = Alamofire.request(.GET, url, headers: getRequestHeaders(), parameters: parameters, encoding: .JSON)
    }
    return request
}


