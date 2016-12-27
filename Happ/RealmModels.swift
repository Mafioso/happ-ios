//
//  EventModel.swift
//  Happ
//
//  Created by MacBook Pro on 9/19/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift


class SettingsDictModel: Object, Mappable {
    // notifications
    dynamic var language: String?
    dynamic var city_id: String?
    dynamic var currency_id: String?

    required convenience init?(_ map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        language    <- map["language"]
        city_id        <- map["city"]
        currency_id    <- map["currency"]
    }
}


class UserModel: Object, Mappable {
    dynamic var id = ""
    dynamic var fn = ""
    dynamic var settings: SettingsDictModel?
    dynamic var avatar: ImageModel?
    dynamic var date_created: NSDate?
    dynamic var date_edited: NSDate?
    dynamic var username = ""
    dynamic var fullname = ""
    dynamic var email = ""
    dynamic var phone = ""
    dynamic var date_of_birth: NSDate?
    dynamic var gender = 0 // 0 - male / 1 - female
    dynamic var ogranization = false
    dynamic var is_active = false
    dynamic var last_login: NSDate?
    dynamic var role = 0


    required convenience init?(_ map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        id              <- map["id"]
        fn              <- map["fn"]
        settings        <- map["settings"]
        avatar          <- map["avatar"]
        date_created    <- (map["date_created"], HappDateTransformer)
        date_edited     <- (map["date_edited"], HappDateTransformer)
        username        <- map["username"]
        fullname        <- map["fullname"]
        email           <- map["email"]
        phone           <- map["phone"]
        date_of_birth   <- (map["date_of_birth"], HappDateTransformer)
        gender          <- map["gender"]
        ogranization    <- map["ogranization"]
        is_active       <- map["is_active"]
        last_login      <- (map["last_login"], HappDateTransformer)
        role            <- map["role"]
    }

    override static func primaryKey() -> String? {
        return "id"
    }
}

class AuthorModel: Object, Mappable {
    dynamic var id = ""
    dynamic var fn: String?
    let events = LinkingObjects(fromType: EventModel.self, property: "author")

    
    required convenience init?(_ map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        id  <- map["id"]
        fn  <- map["fn"]
    }

    override static func primaryKey() -> String? {
        return "id"
    }
}

class CurrencyModel: Object, Mappable {
    dynamic var id = ""
    dynamic var name = ""
    dynamic var code = ""

    required convenience init?(_ map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        id      <- map["id"]
        name    <- map["name"]
        code    <- map["code"]
    }

    override static func primaryKey() -> String? {
        return "id"
    }
}

class CityModel: Object, Mappable {
    dynamic var id = ""
    dynamic var country_name = ""
    dynamic var name = ""


    required convenience init?(_ map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        id              <- map["id"]
        country_name    <- map["country_name"]
        name            <- map["name"]
    }

    override static func primaryKey() -> String? {
        return "id"
    }
}

class InterestModel: Object, Mappable {
    dynamic var id = ""
    dynamic var parent_id: String?
    var children = List<InterestModel>()
    dynamic var title = ""
    dynamic var image: ImageModel?


    required convenience init?(_ map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        id          <- map["id"]
        parent_id   <- map["parent"]
        children    <- (map["children"], ArrayTransform<InterestModel>())
        title       <- map["title"]
        image       <- map["image"]
    }

    override static func primaryKey() -> String? {
        return "id"
    }
}


class GeoPointModel: Object, Mappable {
    dynamic var lat = 0.0
    dynamic var long = 0.0


    func isZero() -> Bool {
        return self.lat.isZero && self.long.isZero
    }
    
    
    // Mappable
    required convenience init?(_ map: Map) {
        self.init()
    }
    func mapping(map: Map) {
        lat     <- map["lat"]
        long    <- map["lng"]
    }
}


class ImageModel: Object, Mappable {
    dynamic var id = ""
    dynamic var path: String?
    dynamic var color: String?


    func getURL() -> NSURL? {
        if let url = self.path {
            return NSURL(string: Host+url)
        }
        return nil
    }


    // Object
    override static func primaryKey() -> String? {
        return "id"
    }

    // Mappable
    required convenience init?(_ map: Map) {
        self.init()
    }
    func mapping(map: Map) {
        id      <- map["id"]
        path    <- map["path"]
        color   <- map["color"]
    }
}

class EventDateModel: Object, Mappable {
    dynamic var raw_date = ""
    dynamic var raw_start_time = ""
    dynamic var raw_end_time = ""

    var start_time: NSDate {
        get {
            let t = "\(raw_date) \(raw_start_time)"
            return HappDateFormats.DateTime.toDate(t)!
        }
    }
    var end_time: NSDate {
        get {
            let t = "\(raw_date) \(raw_end_time)"
            return HappDateFormats.DateTime.toDate(t)!
        }
    }



    override static func ignoredProperties() -> [String] {
        return ["start_time", "end_time"]
    }
    
    // Mappable
    required convenience init?(_ map: Map) {
        self.init()
    }
    func mapping(map: Map) {
        raw_date        <- map["date"]
        raw_start_time  <- map["start_time"]
        raw_end_time    <- map["end_time"]
    }
}


enum EventModelStatusTypes: Int {
    case Active = 0
    case Inactive = 1
    case OnReview = 2
    case Rejected = 3
    case Finished = 4
}

class EventModel: Object, Mappable {
    dynamic var id = ""
    dynamic var timestamp: NSDate = NSDate()
    var interests = List<InterestModel>()
    dynamic var currency: CurrencyModel?
    dynamic var author: AuthorModel?
    var datetimes = List<EventDateModel>()
    dynamic var is_upvoted = false
    dynamic var is_in_favourites = false
    dynamic var date_created: NSDate?
    dynamic var date_edited: NSDate?
    dynamic var title = ""
    // NOTE: `description` name is already used in Object
    dynamic var description_text = ""
    dynamic var language = ""
    dynamic var type = 0
    dynamic var status = 0
    // NOTE: RealmOptional can't be mapped directly to variable
    let min_price_raw = RealmOptional<Int>()
    let max_price_raw = RealmOptional<Int>()
    var min_price: Int? {
        get {
            return min_price_raw.value
        }
        set(value) {
            min_price_raw.value = value
        }
    }
    var max_price: Int? {
        get {
            return max_price_raw.value
        }
        set(value) {
            max_price_raw.value = value
        }
    }

    dynamic var address: String?
    dynamic var geopoint: GeoPointModel?
    // phone
    dynamic var stored_phone_numbers: String = ""
    var phones: [String] {
        get {
            return ArrayStringTransformer.transformToJSON(self.stored_phone_numbers)!
        }
    }
    // end: phone
    dynamic var email: String?
    dynamic var web_site: String?
    dynamic var votes_num = 0
    var images = List<ImageModel>()
    // city
    dynamic var id_of_city = ""
    var city: CityModel? {
        get {
            // TODO: return by key in `self.id_of_city`
            return CityModel(value: ["1capital", "Kazakhstan", "Astana"])
        }
    }
    // city end
    dynamic var is_close_on_start = false
    dynamic var registration_link: String?
    dynamic var max_age = 200
    dynamic var min_age = 0



    // Object
    override static func primaryKey() -> String? {
        return "id"
    }

    override static func ignoredProperties() -> [String] {
        return ["city", "min_price", "max_price"]
    }


    // Mappable
    required convenience init?(_ map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        id                  <- map["id"]
        interests           <- (map["interests"], ArrayTransform<InterestModel>())
        currency            <- map["currency"]
        author              <- map["author"]
        datetimes           <- (map["datetimes"], ArrayTransform<EventDateModel>())
        is_upvoted          <- map["is_upvoted"]
        is_in_favourites    <- map["is_in_favourites"]
        date_created        <- (map["date_created"], HappDateTransformer)
        date_edited         <- (map["date_edited"], HappDateTransformer)
        title               <- map["title"]
        description_text    <- map["description"]
        language            <- map["language"]
        type                <- map["type"]
        status              <- map["status"]
        min_price           <- map["min_price"]
        max_price           <- map["max_price"]
        address             <- map["address"]
        geopoint            <- map["geopoint"]
        stored_phone_numbers <- map["stored_phone_numbers"]
        email               <- map["email"]
        web_site            <- map["web_site"]
        votes_num           <- map["votes_num"]
        images              <- (map["images"], ArrayTransform<ImageModel>())
        id_of_city          <- map["id_of_city"]
        is_close_on_start   <- map["close_on_start"]
        registration_link   <- map["registration_link"]
        min_age             <- map["min_age"]
        max_age             <- map["max_age"]
    }


    // functions
    func getStatus() -> EventModelStatusTypes {
        return EventModelStatusTypes(rawValue: self.status)!
    }
    func getUpvoteIcon() -> UIImage {
        if self.is_upvoted {
            return UIImage(named: "icon-upvote-active")!
        } else {
            return UIImage(named: "icon-upvote")!
        }
    }
    func getFavIcon() -> UIImage {
        if self.is_in_favourites {
            return UIImage(named: "icon-star-active")!
        } else {
            return UIImage(named: "icon-star")!
        }
    }
}
