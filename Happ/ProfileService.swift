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


class ProfileService {

    static let endpointUser = "users/current/"
    static let endpointCity = "cities/"
    static let endpointCurrencies = "currencies/"


    class func fetchCities() -> Promise<Void> {
        return GetPaginated(endpointCity, parameters: nil)
            .then { (data, isLastPage) -> Void in
                let results = data as! [AnyObject]
                let realm = try! Realm()
                try! realm.write {
                    // 1. delete exists
                    let exists = realm.objects(CityModel)
                    realm.delete(exists)

                    // 2. add new
                    results.forEach() { city in
                        let inst = Mapper<CityModel>().map(city)
                        realm.add(inst!, update: true)
                    }
                }
        }
    }

    class func fetchCity(id: String) -> Promise<Void> {
        return Get(endpointCity + id + "/", parameters: nil)
            .then { result -> Void in
                let realm = try! Realm()
                try! realm.write {
                    let inst = Mapper<CityModel>().map(result)
                    realm.add(inst!, update: true)
                }
        }
    }
    class func fetchUserCity() -> Promise<Void> {
        let user = self.getUserProfile()
        let cityID = user.settings!.city_id!
        return self.fetchCity(cityID)
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


    class func setCity(cityID: String) -> Promise<AnyObject> {
        let url = endpointCity + cityID + "/set/"
        return Post(url, parametersJSON: nil)
    }

    class func setCurrency(currencyID: String) -> Promise<AnyObject> {
        let url = endpointCurrencies + currencyID + "/set/"
        return Post(url, parametersJSON: nil)
    }

    class func updateUserProfile(valuesDict: [String: AnyObject]) -> Promise<AnyObject> {
        return Post(endpointUser + "edit/", parameters: valuesDict)
    }


    class func getCitiesStored() -> Results<CityModel> {
        let realm = try! Realm()
        let result = realm.objects(CityModel)//.sort(sort.isOrderedBeforeFunc)
        return result
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

    class func getUserCity() -> CityModel? {
        let realm = try! Realm()
        let result = realm.objects(CityModel)

        let user = self.getUserProfile()
        let settings = user.settings!
        let city = result.filter("id == %@", settings.city_id!).first

        return city
    }

    class func isUserProfileExists() -> Bool {
        let realm = try! Realm()
        let users = realm.objects(UserModel)
        return users.count > 0
    }
    
    
}



