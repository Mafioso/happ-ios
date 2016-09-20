//
//  EventService.swift
//  Happ
//
//  Created by MacBook Pro on 9/19/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import Foundation
import SwiftyJSON
import PromiseKit
import RealmSwift


class EventService {

    static let endpoint = "events/"


    class func fetchFromServer() -> Promise<Void> {
        return Get(endpoint, parameters: nil)
            .then { paginateData -> Void in
                let results = paginateData.dictionaryValue["results"]!.arrayValue

                let data = EventModel.clearRawData(results[0])
                print(".fetchFromServer.SUCCESS!!")


                results.forEach() { res in
                    let data = EventModel.clearRawData(res)
                    var inst = EventModel()
                    data.forEach({ key, value in
                        print("..", key, value, inst)

                        inst.setValue(value, forKey: key)
                    })
                }
                /*
                let realm = try! Realm()
                try! realm.write {
                    results.forEach() { res in
                        let data = EventModel.clearRawData(res)
                        realm.create(EventModel.self, value: data, update: true)
                    }
                }
                */
            }
    }

    class func getEvents() -> Results<EventModel> {
        let realm = try! Realm()
        return realm.objects(EventModel)
    }
    
}
