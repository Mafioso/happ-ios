//
//  InterestService.swift
//  Happ
//
//  Created by MacBook Pro on 11/1/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import Foundation
import PromiseKit
import RealmSwift
import ObjectMapper


class InterestService {

    static let endpointInterest = "interests/"

    static func fetchFromServer() -> Promise<Void> {
        return GetPaginated(endpointInterest, parameters: nil)
            .then { (data, isLastPage) -> Void in
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

    static func setUserInterests(interestIDs: [String]) -> Promise<AnyObject> {
        let url = endpointInterest + "set/"
        let data = try! NSJSONSerialization.dataWithJSONObject(interestIDs, options: [])
        return Post(url, parametersJSON: data)
    }

    static func getAllStored() -> Results<InterestModel> {
        let realm = try! Realm()
        let result = realm.objects(InterestModel)//.sort(sort.isOrderedBeforeFunc)
        return result
    }

    static func getParent(interest: InterestModel) -> InterestModel? {
        if let id = interest.parent_id {
            let realm = try! Realm()
            return realm
                .objects(InterestModel.self)
                .filter("id == %@", id)
                .first
        } else {
            return nil
        }
    }

}


