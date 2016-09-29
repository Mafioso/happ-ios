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

    static let endpointCity = "cities/"
    static let endpointInterest = "interests/"


    class func fetchCitiesFromServer() -> Promise<Void> {
        return Get(endpointCity, parameters: nil, isPaginated: true)
            .then { data -> Void in
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

    class func fetchInterestsFromServer() -> Promise<Void> {
        return Get(endpointInterest, parameters: nil, isPaginated: true)
            .then { data -> Void in
                let results = data as! [AnyObject]
                let realm = try! Realm()
                try! realm.write {
                    // 1. delete exists
                    let exists = realm.objects(InterestModel)
                    realm.delete(exists)

                    // 2. add new
                    results.forEach() { city in
                        let inst = Mapper<InterestModel>().map(city)
                        realm.add(inst!, update: true)
                    }
                }
        }
    }


    class func postSetCity(cityID: String) -> Promise<Void> {
        let url = endpointCity + cityID + "/set/"
        return Post(url, parametersJSON: nil)
    }

    class func postSetInterest(interestIDs: [String]) -> Promise<Void> {
        let url = endpointCity + "set/"
        let data = try! NSJSONSerialization.dataWithJSONObject(interestIDs, options: [])
        return Post(url, parametersJSON: data)
    }


    class func getCitiesStored() -> Results<CityModel> {
        let realm = try! Realm()
        let events = realm.objects(CityModel)//.sort(sort.isOrderedBeforeFunc)
        return events
    }

    class func getInterestsStored() -> Results<InterestModel> {
        let realm = try! Realm()
        let events = realm.objects(InterestModel)//.sort(sort.isOrderedBeforeFunc)
        return events
    }
}



