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


    class func fetchFromServer() -> Promise<Void> {
        let feedEndpoint = endpoint //+ "feed/" TODO
        return Get(feedEndpoint, parameters: nil, isPaginated: true)
            .then { data -> Void in
                let results = data as! [AnyObject]
                let realm = try! Realm()
                try! realm.write {
                    // TODO: remove line below
                    realm.deleteAll()

                    results.forEach() { event in
                        let inst = Mapper<EventModel>().map(event)
                        realm.add(inst!, update: true)
                    }
                }
            }
    }

    class func getStoredEvents(sort: EventSortType) -> Results<EventModel> {
        let realm = try! Realm()
        let events = realm.objects(EventModel)//.sort(sort.isOrderedBeforeFunc)
        return events
    }
    class func getStoredEvents(search: String, sort: EventSortType) -> Results<EventModel> {
        let searchFilter = NSPredicate(format: "title CONTAINS %@", search)

        let events = EventService.getStoredEvents(sort)
                        .filter(searchFilter)
        return events
    }


    class func getByID(id: String) -> EventModel? {
        let realm = try! Realm()
        let result = realm.objects(EventModel.self)
                        .filter("id == %@", id)
        return result.first
    }
    
}
