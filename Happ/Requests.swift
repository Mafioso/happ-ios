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


private let HostServer = "http://happ.westeurope.cloudapp.azure.com"
private let HostServerReserve = "http://happ.skills.kz"
private let HostLocal = "http://127.0.0.1:8000"
private let HostPC = "http://192.168.43.179:8000"
let Host = HostServerReserve
let HostAPI = Host + "/api/v1/"


enum RequestStates: Int {
    case None = 0
    case StartRequest = 1
    case FinishRequest = 2
    case NoInternet = 3
}


enum RequestError: Int, ErrorType, CustomStringConvertible {
    case SignInIncorrect
    case NoInternet = -1009
    case NotAuthorized = 401
    case NotFound = 404
    case BadRequest = -6003
    case BadResponse = -1017
    case NoResponseIsTimedOut = -1001
    case UnknownError

    var description: String {
        switch self {
        case .NotAuthorized:
            return "Non Authorized"
        case .NotFound:
            return "Requesting data doesn't exists"
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
        "Accept": "application/json",
        "Content-Type": "application/json"
    ]
    if isAuthenticated {
        let accessToken = AuthenticationService.getCredential()
        headers.merge(["Authorization": "JWT " + accessToken!])
    }
    return headers
}



func Post(endpoint: String, parameters: [String: AnyObject]?, paramsEncoding: ParameterEncoding = .JSON, isAuthenticated: Bool = true) -> Promise<AnyObject> {
    return Promise { resolve, reject in
        let url = HostAPI + endpoint

        Alamofire
            .request(.POST, url, headers: getRequestHeaders(isAuthenticated), parameters: parameters, encoding: paramsEncoding)
            .validate()
            .responseJSON { response in

                switch response.result {
                case .Success:
                    resolve(response.result.value!)
                case .Failure(let error):
                    if  let statusCode = response.response?.statusCode,
                        let reqErrorType = RequestError(rawValue: statusCode){
                        reject(reqErrorType as ErrorType)
                    } else if let reqErrorType = RequestError(rawValue: error.code) {
                        reject(reqErrorType as ErrorType)
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

func PostRAW(endpoint: String, parametersAnyObject: AnyObject?, isAuthenticated: Bool = true) -> Promise<AnyObject> {
    return Promise { resolve, reject in
        let url = HostAPI + endpoint
        let headers = getRequestHeaders(isAuthenticated)

        let nsURL = NSURL(string: url)
        let request = NSMutableURLRequest(URL: nsURL!)
        request.HTTPMethod = "POST"
        if parametersAnyObject == nil {
            request.HTTPBody = nil
        } else {
            let jsonData = try! NSJSONSerialization.dataWithJSONObject(parametersAnyObject!, options: .PrettyPrinted)
            request.HTTPBody = jsonData
        }
        headers.forEach({ request.setValue($0.1, forHTTPHeaderField: $0.0) })

        Alamofire
            .request(request)
            .validate()
            .response { (request, response, data, error) in
                if error == nil {
                    resolve( (data != nil) ? data! : NSNull() )
                } else {
                    print("PostRAW.error ", error?.code, error?.localizedDescription)

                    if  let statusCode = response?.statusCode,
                        let reqErrorType = RequestError(rawValue: statusCode) {
                        reject(reqErrorType as ErrorType)
                    } else if let reqErrorType = RequestError(rawValue: error!.code) {
                        reject(reqErrorType as ErrorType)
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



func Get(endpoint: String, parameters: [String: AnyObject]?, paramsEncoding: ParameterEncoding = .JSON) -> Promise<AnyObject> {
    return Promise { resolve, reject in
        let url = HostAPI + endpoint
        Alamofire
            .request(.GET, url, headers: getRequestHeaders(), parameters: parameters, encoding: paramsEncoding)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success:
                    resolve(response.result.value!)

                case .Failure(let error):
                    if  let statusCode = response.response?.statusCode,
                        let reqErrorType = RequestError(rawValue: statusCode) {
                        reject(reqErrorType as ErrorType)
                    } else if let reqErrorType = RequestError(rawValue: error.code) {
                        reject(reqErrorType as ErrorType)
                    } else {
                        reject(RequestError.UnknownError)
                    }
                    print(".Get.error", url, parameters, error, error.code, error.localizedDescription)
                }

                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
}

func GetCustom(url: String, parameters: [String: AnyObject]?, paramsEncoding: ParameterEncoding, headers: [String: String]? = nil) -> Promise<AnyObject> {
    return Promise { resolve, reject in
        Alamofire
            .request(.GET, url, headers: headers, parameters: parameters, encoding: paramsEncoding)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success:
                    resolve(response.result.value!)

                case .Failure(let error):
                    if  let statusCode = response.response?.statusCode,
                        let reqErrorType = RequestError(rawValue: statusCode) {
                        reject(reqErrorType as ErrorType)
                    } else if let reqErrorType = RequestError(rawValue: error.code) {
                        reject(reqErrorType as ErrorType)
                    } else {
                        reject(RequestError.UnknownError)
                    }
                    print(".GetCustom.error", url, parameters, error, error.code, error.localizedDescription)
                }
                
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
}


func GetPaginated(endpoint: String, parameters: [String: AnyObject]?, paramsEncoding: ParameterEncoding = .JSON) -> Promise<(AnyObject, Bool, Int)> {
    return Promise { resolve, reject in
        let url = HostAPI + endpoint
        Alamofire
            .request(.GET, url, headers: getRequestHeaders(), parameters: parameters, encoding: paramsEncoding)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success:
                    let paginatedResponse = response.result.value as! NSDictionary
                    let results = paginatedResponse["results"] as! [AnyObject]
                    let isLastPage = paginatedResponse["next"] is NSNull
                    let count = paginatedResponse["count"] as! Int
                    resolve((results, isLastPage, count))

                case .Failure(let error):
                    if  let statusCode = response.response?.statusCode,
                        let reqErrorType = RequestError(rawValue: statusCode) {
                        reject(reqErrorType as ErrorType)
                    } else if let reqErrorType = RequestError(rawValue: error.code) {
                        reject(reqErrorType)
                    } else {
                        reject(RequestError.UnknownError)
                    }
                    print(".GetPaginated.error", endpoint, parameters, error, error.code)
                }

                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
}

