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
import GoogleMapsCore
import SwiftyJSON


enum EventPageTypes {
    case Favourite
    case Feed
    case Explore
    case Map
    case MyEvents
}

enum EventErrors: ErrorType {
    case MutexWriteDenied
}


class EventService {

    static let endpoint = "events/"

    static var isLastPageOfFeed: Bool = false
    static var isLastPageOfFavourites: Bool = false
    static var mutexCurrentPageType: EventPageTypes!


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
                    return self.fetchEvent(eventID)
                }
    }

    class func updateFavourite(eventID: String, value: Bool) -> Promise<Void> {
        var url = endpoint + eventID
        url += (value == true) ? "/fav/" : "/unfav/"
        return Post(url, parameters: nil)
                .then { _ in
                    return self.fetchEvent(eventID)
                }
    }
    
    class func fetchMyEvents(page: Int = 1, overwrite: Bool = false, startDate: NSDate? = nil, endDate: NSDate? = nil, active: Bool = true, inactive: Bool = true, onreview: Bool = true, rejected: Bool = true, finished: Bool = true) -> Promise<Void> {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let timeformatter = NSDateFormatter()
        timeformatter.dateFormat = "HHss"
        let feedEndpoint = endpoint + "organizer/" + "?page=\(page)" +
            (startDate != nil ? "&start_date=\(formatter.stringFromDate(startDate!))" : "") +
            (endDate != nil ? "&end_date=\(formatter.stringFromDate(endDate!))" : "") +
            (active ? "" : "&active=false") +
            (inactive ? "" : "&not_active=false") +
            (onreview ? "" : "&moderation=false") +
            (rejected ? "" : "&rejected=false") +
            (finished ? "" : "&finished=false")

        self.mutexCurrentPageType = .MyEvents
        return Promise { resolve, reject in
            GetPaginated(feedEndpoint, parameters: nil)
                .then { (data, isLastPage, count) -> Void in
                    guard self.mutexCurrentPageType == .MyEvents else {
                        reject(EventErrors.MutexWriteDenied)
                        return
                    }
                    let results = data as! [AnyObject]
                    self.isLastPageOfFeed = isLastPage
                    
                    let realm = try! Realm()
                    try! realm.write {
                        if overwrite {
                            let exists = realm.objects(EventModel)
                            realm.delete(exists)
                        }
                        results.forEach() { event in
                            let inst = Mapper<EventModel>().map(event)
                            realm.add(inst!, update: true) // `update: true` - not required
                        }
                    }
                    resolve()
                }
        }
    }
    
    class func createOrEditEvent(eventId: String?, valuesDict: [String: AnyObject]) -> Promise<Void> {
        return Post(endpoint + "\(eventId != nil ? "\(eventId!)/" : "")", method: eventId != nil ? .PATCH : .POST, parameters: valuesDict)
            .then { result -> Void in
                let realm = try! Realm()
                try! realm.write {
                    let item = Mapper<EventModel>().map(result)
                    realm.add(item!, update: true)
                }
        }
    }
    
    class func removeEvent(id: String) -> Promise<Void> {
        return Post(endpoint + id + "/", method: .DELETE, parameters: [:])
            .then { result -> Void in }
    }
    
    class func copyEvent(id: String) -> Promise<Void> {
        return Post(endpoint + id + "/copy/", parameters: [:])
            .then { result -> Void in }
    }
    
    class func activateDeactivateEvent(activate: Bool, id: String) -> Promise<Void> {
        return Post(endpoint + id + "/\(activate ? "" : "de")activate/", parameters: [:])
            .then { result -> Void in }
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
        
        self.mutexCurrentPageType = .Feed
        return Promise { resolve, reject in
            GetPaginated(feedEndpoint, parameters: nil)
                .then { (data, isLastPage, count) -> Void in
                    guard self.mutexCurrentPageType == .Feed else {
                        reject(EventErrors.MutexWriteDenied)
                        return
                    }

                    let results = data as! [AnyObject]
                    self.isLastPageOfFeed = isLastPage
                    
                    let realm = try! Realm()
                    try! realm.write {
                        if overwrite {
                            let exists = realm.objects(EventModel)
                            realm.delete(exists)
                        }
                        results.forEach() { event in
                            let inst = Mapper<EventModel>().map(event)
                            //                        inst!.datetimes.forEach(){ datetime in
                            //                            let datetimes = List<EventDateModel>()
                            //                            datetimes.append(datetime)
                            //                            inst!.datetimes = datetimes
                            //                            realm.add(inst!, update: true)
                            //                        }
                            realm.add(inst!, update: true) // `update: true` - not required
                        }
                    }
                    resolve()
            }
        }
    }
    class func fetchFavourite(page: Int = 1, overwrite: Bool = false) -> Promise<Void> {
        let feedEndpoint = endpoint + "favourites/" + "?page=\(page)"

        self.mutexCurrentPageType = .Favourite
        return Promise { resolve, reject in
            GetPaginated(feedEndpoint, parameters: nil)
                .then { (data, isLastPage, count) -> Void in
                    guard self.mutexCurrentPageType == .Favourite else {
                        reject(EventErrors.MutexWriteDenied)
                        return
                    }

                    let results = data as! [AnyObject]
                    self.isLastPageOfFavourites = isLastPage
                    
                    let realm = try! Realm()
                    try! realm.write {
                        if overwrite {
                            let exists = realm.objects(EventModel)
                            realm.delete(exists)
                        }
                        results.forEach() { event in
                            let inst = Mapper<EventModel>().map(event)
                            realm.add(inst!, update: true) // `update: true` - not required
                        }
                    }
                    resolve()
                }
        }
    }
    class func fetchExplore(overwrite overwriteValue: Bool = false) -> Promise<Void> {
        let exploreEndpoint = endpoint + "explore/"

        self.mutexCurrentPageType = .Explore
        return Promise { resolve, reject in
            Get(exploreEndpoint, parameters: nil)
                .then { result -> Void in
                    guard self.mutexCurrentPageType == .Explore else {
                        reject(EventErrors.MutexWriteDenied)
                        return
                    }
                    guard let results = JSON(result).dictionaryValue["results"]?.arrayObject else { return }
                    
                    let realm = try! Realm()
                    try! realm.write {
                        if overwriteValue {
                            let exists = realm.objects(EventModel)
                            realm.delete(exists)
                        }
                        results.forEach() { event in
                            let inst = Mapper<EventModel>().map(event)
                            realm.add(inst!, update: true) // `update: true` - not required
                        }
                    }
                    resolve()
                }
        }
    }
    class func fetchMap(center: CLLocation, radius: Int, overwrite: Bool = false) -> Promise<Void> {
        let mapEndpoint = endpoint + "map/"
        let params: [String: AnyObject] = [
            "center": [center.coordinate.longitude, center.coordinate.latitude],
            "radius": radius
        ]

        self.mutexCurrentPageType = .Map
        return Promise { resolve, reject in
            Post(mapEndpoint, parameters: params)
                .then { result -> Void in
                    guard self.mutexCurrentPageType == .Map else {
                        reject(EventErrors.MutexWriteDenied)
                        return
                    }
                    guard let results = JSON(result).dictionaryValue["results"]?.arrayObject else { return }
                    
                    let realm = try! Realm()
                    try! realm.write {
                        if overwrite {
                            let exists = realm.objects(EventModel)
                            realm.delete(exists)
                        }
                        results.forEach() { event in
                            let inst = Mapper<EventModel>().map(event)
                            realm.add(inst!, update: true) // `update: true` - not required
                        }
                    }
                    resolve()
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

    class func getStored() -> Results<EventModel> {
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
    class func getExplore() -> [EventModel] {
        let realm = try! Realm()
        let events = realm
            .objects(EventModel)
            .sort({ eventA, eventB in
                return eventA.timestamp.compare(eventB.timestamp) == .OrderedAscending
            })
        return events
    }

    class func getByID(id: String) -> EventModel? {
        let realm = try! Realm()
        let result = realm.objects(EventModel.self)
                        .filter("id == %@", id)
        return result.first
    }
    
}
