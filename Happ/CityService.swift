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


    class func fetchCities(page: Int = 1) -> Promise<Void> {
        let pagedURL = endpoint + "?page=\(page)"
        return GetPaginated(pagedURL, parameters: nil)
            .then { (data, isLastPage) -> Void in
                self.isLastPage = isLastPage

                let results = data as! [AnyObject]
                let realm = try! Realm()
                try! realm.write {
                    /*
                    if page == 1 {
                        // 1.   delete exists
                        var query = realm.objects(CityModel)
                        //      except User's City
                        let userProfile = ProfileService.getUserProfile()
                        if let userCityID = userProfile.settings?.city_id {
                            query = query.filter("id != %@", userCityID)
                        }
                        realm.delete(query)
                    }
                    */

                    // 2. add new
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
        let city = self.getCity(id)
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


    class func getCities() -> Results<CityModel> {
        let realm = try! Realm()
        let result = realm.objects(CityModel)
        return result
    }
    class func getCity(id: String) -> CityModel {
        let realm = try! Realm()
        let result = realm.objects(CityModel)
        return result.filter("id == %@", id).first!
    }

    
}


