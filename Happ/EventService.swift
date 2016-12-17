//
//  EventService.swift
//  Happ
//
//  Created by MacBook Pro on 9/19/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import Foundation
import PromiseKit
import RealmSwift
import ObjectMapper
import ObjectMapper_Realm


enum EventLocationError: ErrorType {
    case NoAddress
    case AddressNotFound
}


class EventService {

    static let endpoint = "events/"

    static var isLastPageOfFeed: Bool = false
    static var isLastPageOfFavourites: Bool = false
    static var isLastPageOfExplore: Bool = false


    class func setLike(eventID: String, value: Bool) {
        let event = self.getByID(eventID)!
        let realm = try! Realm()
        try! realm.write {
            event.is_upvoted = value
        }
    }

    class func setFavourite(eventID: String, value: Bool) {
        let event = self.getByID(eventID)!
        let realm = try! Realm()
        try! realm.write {
            event.is_in_favourites = value
        }
    }

    class func updateLike(eventID: String, value: Bool) -> Promise<Void> {
        var url = endpoint + eventID
        url += (value == true) ? "/upvote/" : "/downvote/"
        return Post(url, parameters: nil)
                .then { _ -> Promise<Void> in
                    print(".EventService.setLike.beforeFetch")
                    return self.fetchEvent(eventID)
                }
                .then { print(".EventService.setLike.afterFetch!") }
    }

    class func updateFavourite(eventID: String, value: Bool) -> Promise<Void> {
        var url = endpoint + eventID
        url += (value == true) ? "/fav/" : "/unfav/"
        return Post(url, parameters: nil)
                .then { _ in
                    return self.fetchEvent(eventID)
                }
    }

    class func fetchFeed(page: Int = 1, overwrite: Bool = false, onlyFree: Bool = false, popular: Bool = false, startDate: NSDate? = nil, endDate: NSDate? = nil, startTime: NSDate? = nil) -> Promise<Void> {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let timeformatter = NSDateFormatter()
        timeformatter.dateFormat = "HHss"
        let feedEndpoint = endpoint + "feed/" + "?page=\(page)" +
            (onlyFree ? "&max_price=0" : "") +
            (popular ? "&order=popular" : "") +
            (startDate != nil ? "&start_date=\(formatter.stringFromDate(startDate!))" : "") +
            (endDate != nil ? "&end_date=\(formatter.stringFromDate(endDate!))" : "") +
            (startTime != nil ? "&start_time=\(timeformatter.stringFromDate(startTime!))" : "")
        print(feedEndpoint)
        return GetPaginated(feedEndpoint, parameters: nil)
            .then { (data, isLastPage, count) -> Void in
                let results = data as! [AnyObject]
                self.isLastPageOfFeed = isLastPage
                
                if overwrite {
                    self.deleteEventsLocal()
                }

                let realm = try! Realm()
                try! realm.write {
                    results.forEach() { event in
                        let inst = Mapper<EventModel>().map(event)
                        realm.add(inst!, update: true) // `update: true` - not required
                    }
                }
            }
    }
    class func fetchFavourite(page: Int = 1, overwrite: Bool = false) -> Promise<Void> {
        let feedEndpoint = endpoint + "favourites/" + "?page=\(page)"
        return GetPaginated(feedEndpoint, parameters: nil)
            .then { (data, isLastPage, count) -> Void in
                let results = data as! [AnyObject]
                self.isLastPageOfFavourites = isLastPage

                if overwrite {
                    self.deleteEventsLocal()
                }

                let realm = try! Realm()
                try! realm.write {
                    results.forEach() { event in
                        let inst = Mapper<EventModel>().map(event)
                        realm.add(inst!, update: true) // `update: true` - not required
                    }
                }
        }
    }
    class func fetchExplore(page: Int = 1, overwrite: Bool = false) -> Promise<Void> {
        let exploreEndpoint = endpoint + "feed/" + "?page=\(page)"
        return GetPaginated(exploreEndpoint, parameters: nil)
            .then { (data, isLastPage, count) -> Void in
                let results = data as! [AnyObject]
                self.isLastPageOfExplore = isLastPage

                if overwrite {
                    self.deleteEventsLocal()
                }

                let realm = try! Realm()
                try! realm.write {
                    results.forEach() { event in
                        let inst = Mapper<EventModel>().map(event)
                        realm.add(inst!, update: true) // `update: true` - not required
                    }
                }
        }
    }
    class func fetchEvent(id: String) -> Promise<Void> {
        let url = endpoint + id + "/"
        return Get(url, parameters: nil)
            .then { result -> Void in
                let realm = try! Realm()
                try! realm.write {
                    let inst = Mapper<EventModel>().map(result)
                    realm.add(inst!, update: true)
                }
        }

    }
    
    class func deleteEventsLocal() {
        let realm = try! Realm()
        try! realm.write {
            let exists = realm.objects(EventModel)
            realm.delete(exists)
        }
    }

    class func updateGeoPoint(event: EventModel, geopoint: GeoPointModel) {
        let realm = try! Realm()
        try! realm.write {
            event.geopoint = geopoint
        }
    }

    class func updateGeoPointIfNotExists(event: EventModel) -> Promise<EventModel> {
        return Promise { resolve, reject in
            if  let geopoint = event.geopoint
                where !geopoint.isZero() {
                    resolve(event)

            } else {
                guard   let address = event.address
                        else { reject(EventLocationError.NoAddress); return }
                MapService.fetchPlaces(address)
                    .then { results -> Void in
                        guard   let location = results.first
                                else { reject(EventLocationError.AddressNotFound); return }
                        self.updateGeoPoint(event, geopoint: location.location.asGeoPoint())
                        let updEvent = self.getByID(event.id)!
                        resolve(updEvent)

                    }
                    .error { err in
                        reject(err)
                    }
            }
        }
    }

    class func getFeed() -> Results<EventModel> {
        let realm = try! Realm()
        let events = realm.objects(EventModel)
        return events
    }
    class func getFavourite() -> Results<EventModel> {
        let realm = try! Realm()
        let events = realm
                        .objects(EventModel)
                        .filter("is_in_favourites == true")
        return events
    }
    class func getExplore() -> Results<EventModel> {
        let realm = try! Realm()
        let events = realm.objects(EventModel) //TODO get only Explore
        return events
    }

    class func getByID(id: String) -> EventModel? {
        let realm = try! Realm()
        let result = realm.objects(EventModel.self)
                        .filter("id == %@", id)
        return result.first
    }
    
}
