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


class EventService {

    static let endpoint = "events/"

    static var isLastPageOfFeed: Bool = false
    static var isLastPageOfFavourites: Bool = false
    static var isLastPageOfExplore: Bool = false


    class func setLike(eventID: String, value: Bool) -> Promise<Void> {
        var url = endpoint + eventID
        url += (value == true) ? "/upvote/" : "/downvote/"
        return Post(url, parameters: nil)
                .then { _ -> Promise<Void> in
                    print(".EventService.setLike.beforeFetch")
                    return self.fetchEvent(eventID)
                }
                .then { print(".EventService.setLike.afterFetch!") }
    }

    class func setFavourite(eventID: String, value: Bool) -> Promise<Void> {
        var url = endpoint + eventID
        url += (value == true) ? "/fav/" : "/unfav/"
        return Post(url, parameters: nil)
                .then { _ in
                    return self.fetchEvent(eventID)
                }
    }

    class func fetchFeed(page: Int = 1) -> Promise<Void> {
        let feedEndpoint = endpoint + "feed/" + "?page=\(page)"
        return GetPaginated(feedEndpoint, parameters: nil)
            .then { (data, isLastPage) -> Void in
                let results = data as! [AnyObject]
                let realm = try! Realm()

                if page == 1 {
                    // 1. delete exists
                    try! realm.write {
                        let exists = realm.objects(EventModel)
                        realm.delete(exists)
                    }
                }

                self.isLastPageOfFeed = isLastPage
                // 2. add new
                try! realm.write {
                    results.forEach() { event in
                        let inst = Mapper<EventModel>().map(event)
                        realm.add(inst!, update: true) // `update: true` - not required
                    }
                }
            }
    }
    class func fetchFavourite(page: Int = 1) -> Promise<Void> {
        let feedEndpoint = endpoint + "favourites/" + "?page=\(page)"
        return GetPaginated(feedEndpoint, parameters: nil)
            .then { (data, isLastPage) -> Void in
                let results = data as! [AnyObject]
                let realm = try! Realm()
                
                if page == 1 {
                    // 1. delete exists
                    try! realm.write {
                        let exists = realm.objects(EventModel)
                        realm.delete(exists)
                    }
                }

                self.isLastPageOfFeed = isLastPage
                // 2. add new
                try! realm.write {
                    results.forEach() { event in
                        let inst = Mapper<EventModel>().map(event)
                        realm.add(inst!, update: true) // `update: true` - not required
                    }
                }
        }
    }
    class func fetchExplore(page: Int = 1) -> Promise<Void> {
        let paged = endpoint + "favourites/" + "?page=\(page)"
        return GetPaginated(paged, parameters: nil)
            .then { (data, isLastPage) -> Void in
                let results = data as! [AnyObject]
                let realm = try! Realm()
                
                if page == 1 {
                    // 1. delete exists
                    try! realm.write {
                        let exists = realm.objects(EventModel)
                        realm.delete(exists)
                    }
                }

                self.isLastPageOfExplore = isLastPage
                // 2. add new
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
