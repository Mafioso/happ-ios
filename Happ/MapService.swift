//
//  MapService.swift
//  Happ
//
//  Created by MacBook Pro on 11/26/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import Foundation
import PromiseKit
import RealmSwift
import ObjectMapper
import ObjectMapper_Realm
import SwiftyJSON
import GoogleMaps



class MapService {

    class func fetchByArea(location: CLLocation, radius: Int, overwrite: Bool = false) -> Promise<Void> {
        let endpoint = "events/map/"
        let params: [String: AnyObject] = [
            "center": [location.coordinate.longitude, location.coordinate.latitude],
            "radius": radius
        ]
        return Post(endpoint, parameters: params)
            .then { result -> Void in
                let json = JSON(result as! NSDictionary)
                let results = json["results"].arrayObject!
                let realm = try! Realm()
                try! realm.write {
                    if overwrite {
                        let all = realm.objects(EventModel)
                        realm.delete(all)
                    }

                    results.forEach() { event in
                        let inst = Mapper<EventModel>().map(event)
                        realm.add(inst!, update: true)
                    }
                }
            }
    }

    class func fetchPlaces(search: String) -> Promise<[MapPlace]> {
        let endpoint = "places/"
        let params: [String: AnyObject] = [
            "text": search
        ]
        return Post(endpoint, parameters: params)
            .then { result -> [MapPlace] in
                let json = JSON(result as! NSDictionary)
                let places = json["results"]
                    .arrayValue
                    .map { jsonPlace in
                        return MapPlace(
                            name: jsonPlace["name"].stringValue,
                            photoRef: jsonPlace["photos", 0, "photo_reference"].stringValue,
                            address: jsonPlace["formatted_address"].stringValue,
                            location: CLLocation(
                                latitude: Double(jsonPlace["geometry", "location", "lat"].stringValue)!,
                                longitude: Double(jsonPlace["geometry", "location", "lng"].stringValue)!
                            )
                        )
                    }
                return places
            }
    }
    class func fetchDirection(from: CLLocation, to: CLLocation) -> Promise<MapDirection> {
        let url = "https://maps.googleapis.com/maps/api/directions/json"
        let params: [String: AnyObject] = [
            "origin": "\(from.coordinate.latitude),\(from.coordinate.longitude)",
            "destination": "\(to.coordinate.latitude),\(to.coordinate.longitude)",
            "mode": "driving",
            "alternatives": false,
            "units": "metric"
        ]
        return GetCustom(url, parameters: params, paramsEncoding: .URL, headers: nil)
            .then { result -> MapDirection in
                let json = JSON(result as! NSDictionary)
                let status = json["status"].stringValue
                switch status {
                    case "OK":
                        return MapDirection(
                            legSteps: json["routes", 0, "legs", 0, "steps"].array!,
                            overviewPolylinePoints: json["routes", 0, "overview_polyline", "points"].string!)
                    case "ZERO_RESULTS":
                        return MapDirection(legSteps: [], overviewPolylinePoints: "")
                    default:
                        fatalError()
                     break
                }
        }
    }


    class func getPlacePhotoURL(photoRef: String, width: Int) -> NSURL {
        let url = HostAPI + "photos/?photoreference=\(photoRef)&max_width=\(width)"
        return NSURL(string: url)!
    }

}



