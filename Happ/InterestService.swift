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

    static let endpoint = "interests/"

    static var isLastPage: Bool = false
    static var countAll: Int = 0
    static var countUserInterests: Int = 0


    static func fetchAll(page: Int = 1, overwrite: Bool = false) -> Promise<Void> {
        let pagedURL = endpoint + "?page=\(page)"
        return GetPaginated(pagedURL, parameters: nil)
            .then { (data, isLastPage, count) -> Void in
                self.isLastPage = isLastPage
                self.countAll = count

                let results = data as! [AnyObject]
                let realm = try! Realm()
                try! realm.write {
                    if overwrite {
                        let all = realm.objects(InterestModel)
                        realm.delete(all)
                    }

                    results.forEach() { city in
                        let inst = Mapper<InterestModel>().map(city)
                        realm.add(inst!, update: true)
                    }
                }
        }
    }
    static func fetchUserInterests(page: Int = 1, overwrite: Bool = false) -> Promise<Void> {
        let pagedURL = endpoint + "my/?page=\(page)"
        return GetPaginated(pagedURL, parameters: nil)
            .then { (data, isLastPage, count) -> Void in
                self.isLastPage = isLastPage
                self.countUserInterests = count

                let results = data as! [AnyObject]
                let realm = try! Realm()
                try! realm.write {
                    if overwrite {
                        let all = realm.objects(InterestModel)
                        realm.delete(all)
                    }

                    results.forEach() { data in
                        let inst = Mapper<InterestModel>().map(data)
                        realm.add(inst!, update: true)
                    }
                }
        }
    }
    static func setUserInterests(interestIDs: [String]) -> Promise<AnyObject> {
        let url = endpoint + "set/"
        return PostRAW(url, parametersAnyObject: interestIDs)
                .then { data in
                    return ProfileService.fetchUserProfile()
                        .then { userProfileData in
                            return data
                    }
                }
    }
    static func setUserAllInterests() -> Promise<Void> {
        let url = endpoint + "set/?all=1"
        return PostRAW(url, parametersAnyObject: nil)
            .then { _ in ProfileService.fetchUserProfile() }
    }


    static func getAllStored() -> Results<InterestModel> {
        let realm = try! Realm()
        let result = realm.objects(InterestModel)//.sort(sort.isOrderedBeforeFunc)
        return result
    }
    static func deleteAllStored() {
        let realm = try! Realm()
        try! realm.write {
            let exists = realm.objects(InterestModel)
            realm.delete(exists)
        }
    }

    static func getParentOf(interest: InterestModel) -> InterestModel? {
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
    static func getSubinterestsOf(interest: InterestModel) -> [InterestModel] {
        return Array(interest.children)
    }
    static func getGroupedByParents(interests: [InterestModel]) -> [InterestModel: [InterestModel]] {
        var dict: [InterestModel: [InterestModel]] = [:]
        interests
            .filter { $0.parent_id == nil }
            .forEach { dict.updateValue([], forKey: $0) }
        interests
            .filter { $0.parent_id != nil }
            .forEach { subinterest in
                if let interest = self.getParentOf(subinterest) {
                    if var value = dict[interest] {
                        value.append(subinterest)
                        dict.updateValue(value, forKey: interest)
                    } else {
                        dict.updateValue([subinterest], forKey: interest)
                    }
                }
        }
        return dict
    }

}



