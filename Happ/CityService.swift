//
//  CityService.swift
//  Happ
//
//  Created by MacBook Pro on 11/18/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import Foundation
import PromiseKit
import RealmSwift
import ObjectMapper
import ObjectMapper_Realm
import GoogleMaps


class CityService {
    
    static let endpoint = "cities/"

    static var isLastPage: Bool = false


    class func fetchCities(page: Int = 1, overwrite: Bool = false) -> Promise<Void> {
        let pagedURL = endpoint + "?page=\(page)"
        return GetPaginated(pagedURL, parameters: nil)
            .then { (data, isLastPage) -> Void in
                self.isLastPage = isLastPage

                let results = data as! [AnyObject]
                let realm = try! Realm()
                try! realm.write {
                    if overwrite {
                        let exists = realm.objects(CityModel)
                        realm.delete(exists)
                    }
                    results.forEach() { city in
                        let inst = Mapper<CityModel>().map(city)
                        realm.add(inst!, update: true)
                    }
                }
        }
    }
    class func fetchCitiesByName(name: String) -> Promise<Void> {
        return GetPaginated(endpoint, parameters: ["search": name], paramsEncoding: .URL)
            .then { (data, isLastPage) -> Void in
                let results = data as! [AnyObject]
                
                let realm = try! Realm()
                try! realm.write {
                    results.forEach() { city in
                        let inst = Mapper<CityModel>().map(city)
                        realm.add(inst!, update: true)
                    }
                }
        }
    }
    class func fetchCity(id: String) -> Promise<Void> {
        return Get(endpoint + id + "/", parameters: nil)
            .then { result -> Void in
                let realm = try! Realm()
                try! realm.write {
                    let inst = Mapper<CityModel>().map(result)
                    realm.add(inst!, update: true)
                }
        }
    }
    class func fetchCityLocation(id: String) -> Promise<AnyObject?> {
        let city = self.getCity(id)!
        let url = "http://nominatim.openstreetmap.org/search"
        let params: [String: AnyObject] = [
            "city": city.name,
            "country": city.country_name,
            "format": "json",
            "addressdetails": 1
        ]
        return GetCustom(url, parameters: params, paramsEncoding: .URL, headers: [:])
            .then { result -> AnyObject? in
                if  let array = result as? NSArray,
                    let firstObj = array.firstObject,
                    let data = firstObj as? NSDictionary {

                    let lat = Double(data.objectForKey("lat") as! String)!
                    let long = Double(data.objectForKey("lon") as! String)!
                    return CLLocation(latitude: lat, longitude: long)
                }
                return nil
        }
    }

    class func setUserCity(cityID: String) -> Promise<AnyObject> {
        let url = endpoint + cityID + "/set/"
        return PostRAW(url, parametersAnyObject: nil)
                .then { data in
                    return ProfileService.fetchUserProfile()
                        .then { userProfileData in
                            return data
                    }
                }
    }


    class func deleteCitiesLocal(exceptIDs: [String]?) {
        let realm = try! Realm()
        try! realm.write {
            var exists = realm.objects(EventModel)
            if let ids = exceptIDs {
                exists = exists.filter("NOT id IN %@", ids)
            }
            realm.delete(exists)
        }
    }

    class func getCities() -> Results<CityModel> {
        let realm = try! Realm()
        let result = realm.objects(CityModel)
        return result
    }
    class func getCity(id: String) -> CityModel? {
        let realm = try! Realm()
        let result = realm.objects(CityModel)
        return result.filter("id == %@", id).first
    }

    
}


