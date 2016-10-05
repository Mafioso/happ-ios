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

    
    class func setLike(eventID: String, value: Bool) -> Promise<AnyObject> {
        var url = endpoint + eventID
        url += (value == true) ? "/upvote/" : "/downvote/"
        return Post(url, parametersJSON: nil)
    }

    class func setFavourite(eventID: String, value: Bool) -> Promise<AnyObject> {
        var url = endpoint + eventID
        url += (value == true) ? "/fav/" : "/unfav/"
        return Post(url, parametersJSON: nil)
    }

    class func fetchFeed(page: Int = 1) -> Promise<Void> {
        let feedEndpoint = endpoint + "?page=\(page)"
        //+ "feed/" TODO
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

    class func getFeed() -> Results<EventModel> {
        let realm = try! Realm()
        let events = realm.objects(EventModel)
        return events
    }

    class func getByID(id: String) -> EventModel? {
        let realm = try! Realm()
        let result = realm.objects(EventModel.self)
                        .filter("id == %@", id)
        return result.first
    }
    
}
