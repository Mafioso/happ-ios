//
//  Profile.swift
//  Happ
//
//  Created by MacBook Pro on 9/27/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import Foundation
import PromiseKit
import RealmSwift
import ObjectMapper


enum ProfileErrors: ErrorType {
    case CityNotSelected
    case InterestsNotSelected
    case LanguageWasChanged(nowLanguage: String)
}


class ProfileService {

    static let endpointUser = "users/current/"
    static let endpointCurrencies = "currencies/"

    class func fetchUserCity() -> Promise<Void> {
        let user = self.getUserProfile()
        let cityID = user.settings!.city_id!
        return CityService.fetchCity(cityID)
    }

    class func fetchUserProfile() -> Promise<Void> {
        return Get(endpointUser, parameters: nil)
            .then { data -> Void in
                let result = data
                let realm = try! Realm()
                try! realm.write {
                    // 1. delete exists
                    let exists = realm.objects(UserModel)
                    realm.delete(exists)

                    // 2. add new
                    let user = Mapper<UserModel>().map(result)
                    realm.add(user!, update: true)
                }
        }
    }

    class func fetchCurrencies() -> Promise<Void> {
        return GetPaginated(endpointCurrencies, parameters: nil)
            .then { (data, isLastPage) -> Void in
                let results = data as! [AnyObject]
                let realm = try! Realm()
                try! realm.write {
                    // 1. delete exists
                    let exists = realm.objects(CurrencyModel)
                    realm.delete(exists)

                    // 2. add new
                    results.forEach() { currencyData in
                        let item = Mapper<CurrencyModel>().map(currencyData)
                        realm.add(item!)
                    }
                }
        }
    }


    class func setCurrency(currencyID: String) -> Promise<AnyObject> {
        let url = endpointCurrencies + currencyID + "/set/"
        return PostRAW(url, parametersAnyObject: nil)
    }
    class func setLanguage(language: String) -> Promise<AnyObject> {
        let url = endpointUser + "set/language/"
        return Post(url, parameters: ["language": language])
    }
    class func updateUserProfile(valuesDict: [String: AnyObject]) -> Promise<Void> {
        return Post(endpointUser + "edit/", parameters: valuesDict)
            .then { result -> Void in
                let realm = try! Realm()
                try! realm.write {
                    let item = Mapper<UserModel>().map(result)
                    realm.add(item!, update: true)
                }
            }
    }


    class func getCurrenciesStored() -> Results<CurrencyModel> {
        let realm = try! Realm()
        let result = realm.objects(CurrencyModel)
        return result
    }

    class func getUserProfile() -> UserModel {
        let realm = try! Realm()
        let user = realm.objects(UserModel).first
        return user!
    }

    class func getUserCity() -> CityModel {
        let realm = try! Realm()
        let result = realm.objects(CityModel)

        let user = self.getUserProfile()
        let settings = user.settings!
        let city = result.filter("id == %@", settings.city_id!).first

        return city!
    }

    class func isUserProfileExists() -> Bool {
        let realm = try! Realm()
        let users = realm.objects(UserModel)
        return users.count > 0
    }
    
    class func checkCityExists() -> Promise<Void> {
        let profile = self.getUserProfile()
        let settings = profile.settings!
        
        return Promise { resolve, reject in
            if settings.city_id == nil {
                reject(ProfileErrors.CityNotSelected)
            } else {
                resolve()
            }
        }
    }
    class func checkInterestsExist() -> Promise<Void> {
        let profile = self.getUserProfile()

        return Promise { resolve, reject in
            if profile.interests.isEmpty {
                reject(ProfileErrors.InterestsNotSelected)
            } else {
                resolve()
            }
        }
    }
    class func checkLanguageChange() -> Promise<Void> {
        let profile = self.getUserProfile()
        let settings = profile.settings!
        let lang = getSystemLanguage()

        return Promise { resolve, reject in
            if settings.language != lang {
                reject(ProfileErrors.LanguageWasChanged(nowLanguage: lang!))
            } else {
                resolve()
            }
        }
    }
    
    
}



