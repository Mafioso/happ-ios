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
    dynamic var settings: SettingsDictModel?
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


    required convenience init?(_ map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        id              <- map["id"]
        settings        <- map["settings"]
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
        last_login   <- (map["last_login"], HappDateTransformer)
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

    required convenience init?(_ map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        id              <- map["id"]
        name            <- map["name"]
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
    dynamic var color: String?


    required convenience init?(_ map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        id          <- map["id"]
        parent_id   <- map["parent"]
        children    <- (map["children"], ArrayTransform<InterestModel>())
        title       <- map["title"]
        color       <- map["color"]
    }

    override static func primaryKey() -> String? {
        return "id"
    }
}


enum EventModelPriceTypes {
    case Range
    case MinPrice
    case MaxPrice

    func format(event: EventModel) -> String {
        let currency = event.currency == nil ? CurrencyModel(value: ["0", "KZT"]) : event.currency!
        let minValue = event.min_price.value
        let maxValue = event.max_price.value

        switch self {
        case .Range:
            var ans: String
            if minValue == nil {
                ans = "FREE"
            } else {
                ans = format(minValue!)
            }
            if maxValue != nil {
                ans += " — "
                ans = format(maxValue!)
            }
            return ans
        case .MinPrice:
            if minValue == nil {
                return "FREE"
            } else {
                return format(minValue!) + " " + currency.name
            }
        case .MaxPrice:
            return format(maxValue!) + " " + currency.name
        }
    }

    func format(value: Int) -> String {
        // TODO add real formatting
        return String(value)
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
        lat     <- map["0"]
        long    <- map["1"]
    }
}

class ImageModel: Object, Mappable {
    dynamic var id = ""
    dynamic var path: String?


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
    var interests = List<InterestModel>()
    dynamic var currency: CurrencyModel?
    dynamic var author: AuthorModel?
    dynamic var start_datetime: NSDate?
    dynamic var end_datetime: NSDate?
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
    var min_price = RealmOptional<Int>()
    var max_price = RealmOptional<Int>()
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
    dynamic var age_restriction = 0
    dynamic var color: String?



    // Object
    override static func primaryKey() -> String? {
        return "id"
    }

    override static func ignoredProperties() -> [String] {
        return ["city"]
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
        start_datetime      <- (map["start_datetime"], HappDateTransformer)
        end_datetime        <- (map["end_datetime"], HappDateTransformer)
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
        age_restriction     <- map["age_restriction"]
        color               <- map["color"]
    }


    // functions
    func getPrice(format: EventModelPriceTypes) -> String {
        return format.format(self)
    }
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
