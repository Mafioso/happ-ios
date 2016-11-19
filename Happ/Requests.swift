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
let HostPC = "http://192.168.43.179:8000"
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
        "Accept": "application/json",
        "Content-Type": "application/json"
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

func Post(endpoint: String, parametersAnyObject: AnyObject?, isAuthenticated: Bool = true) -> Promise<AnyObject> {
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
            .validate(statusCode: [204])
            .response { (request, response, data, error) in
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
        Alamofire
            .request(.GET, url, headers: getRequestHeaders(), parameters: parameters, encoding: .JSON)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success:
                    resolve(response.result.value!)

                case .Failure(let error):
                    if let reqErrorType = RequestError(rawValue: error.code) {
                        reject(reqErrorType as ErrorType)
                    } else {
                        print(".Get.error", url, parameters, error, error.code, error.localizedDescription)
                        reject(RequestError.UnknownError)
                    }
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
                    if let reqErrorType = RequestError(rawValue: error.code) {
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


func GetPaginated(endpoint: String, parameters: [String: AnyObject]?) -> Promise<(AnyObject, Bool)> {
    return Promise { resolve, reject in
        let url = HostAPI + endpoint
        Alamofire
            .request(.GET, url, headers: getRequestHeaders(), parameters: parameters, encoding: .JSON)
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


/*
private func createRequest(url: String, parameters: [String: AnyObject]?, customHeaders: [String: String]?) -> Request {
    // create Request
    var  request: Request!
    if parameters == nil {
        let nsURL = NSURL(string: url)
        let headers = customHeaders == nil ? getRequestHeaders() : customHeaders // getRequestHeaders()
        let nsRequest = NSMutableURLRequest(URL: nsURL!)
        nsRequest.HTTPMethod = "GET"
        headers.forEach({ nsRequest.setValue($0.1, forHTTPHeaderField: $0.0) })
        request = Alamofire.request(nsRequest)
    } else {
        request = Alamofire.request(.GET, url, headers: getRequestHeaders(), parameters: parameters, encoding: .JSON)
    }
    return request
}
*/
