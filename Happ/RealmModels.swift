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
import Quickblox

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
    dynamic var qbID = 0
    dynamic var qbLogin = ""
    dynamic var qbPassword = ""

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
        qbID            <- map["quickblox_id"]
        qbLogin         <- map["quickblox_login"]
        qbPassword      <- map["quickblox_password"]
    }

    override static func primaryKey() -> String? {
        return "id"
    }
}

class AuthorModel: Object, Mappable {
    dynamic var id = ""
    dynamic var fn: String?
    dynamic var qbID = 0
    let events = LinkingObjects(fromType: EventModel.self, property: "author")

    
    required convenience init?(_ map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        id  <- map["id"]
        fn  <- map["fn"]
        qbID  <- map["quickblox_id"]
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

class EventInterestModel: InterestModel {
    dynamic var parent: InterestModel?
    
    required convenience init?(_ map: Map) {
        self.init()
    }

    override func mapping(map: Map) {
        id          <- map["id"]
        parent      <- map["parent"]
        children    <- (map["children"], ArrayTransform<InterestModel>())
        title       <- map["title"]
        image       <- map["image"]
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
    case OnReview = 0
    case Active = 1
    case Rejected = 2
    case Inactive = 3
    case Finished = 4
}

class RealmString: Object, Mappable {
    dynamic var stringValue = ""
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        stringValue <- map["stringValue"]
    }
}

class RejectionReason: Object, Mappable {
    dynamic var text: String?
    dynamic var author: AuthorModel?
    dynamic var date: NSDate?
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        text <- map["text"]
        author <- map["author"]
        date <- (map["date_edited"], HappDateTransformer)
    }
}

class EventModel: Object, Mappable {
    dynamic var id = ""
    dynamic var timestamp: NSDate = NSDate()
    var interests = List<EventInterestModel>()
    dynamic var currency: CurrencyModel?
    dynamic var author: AuthorModel?
    var datetimes = List<EventDateModel>()
    var event_datetimes = List<EventDateModel>()
    dynamic var is_active = false
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

    dynamic var place_name: String?
    dynamic var address: String?
    dynamic var geopoint: GeoPointModel?
    var _phones = List<RealmString>()
    var phones: [String] {
        get {
            return _phones.map { $0.stringValue }
        }
        set {
            _phones.removeAll()
            _phones.appendContentsOf(newValue.map({ RealmString(value: [$0]) }))
        }
    }
    dynamic var email: String?
    dynamic var web_site: String?
    dynamic var votes_num = 0
    dynamic var views_count = 0
    var images = List<ImageModel>()
    // city
    dynamic var _cityCountry = ""
    dynamic var _cityName = ""
    dynamic var _cityId = ""
    var city: CityModel? {
        get {
            return CityModel(value: [_cityId, _cityCountry, _cityName])
        }
    }
    // city end
    dynamic var is_close_on_start = false
    dynamic var registration_link: String?
    dynamic var tickets_link: String?
    dynamic var max_age = 200
    dynamic var min_age = 0
    
    dynamic var _rejectionText = ""
    dynamic var _rejectionAuthor = ""
    dynamic var _rejectionDate: NSDate?

    // Object
    override static func primaryKey() -> String? {
        return "id"
    }

    override static func ignoredProperties() -> [String] {
        return ["city", "min_price", "max_price", "phones"]
    }


    // Mappable
    required convenience init?(_ map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        id                  <- map["id"]
        interests           <- (map["interests"], ArrayTransform<EventInterestModel>())
        currency            <- map["currency"]
        author              <- map["author"]
        event_datetimes     <- (map["event_datetimes"], ArrayTransform<EventDateModel>())
        datetimes           <- (map["datetimes"], ArrayTransform<EventDateModel>())
        is_upvoted          <- map["is_upvoted"]
        is_active           <- map["is_active"]
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
        place_name          <- map["place_name"]
        address             <- map["address"]
        geopoint            <- map["geopoint"]
        phones              <- map["phones"]
        email               <- map["email"]
        web_site            <- map["web_site"]
        votes_num           <- map["votes_num"]
        views_count         <- map["views_count"]
        images              <- (map["images"], ArrayTransform<ImageModel>())
        _cityCountry        <- map["city.country_name"]
        _cityName           <- map["city.name"]
        _cityId             <- map["city.id"]
        is_close_on_start   <- map["close_on_start"]
        registration_link   <- map["registration_link"]
        tickets_link        <- map["tickets_link"]
        min_age             <- map["min_age"]
        max_age             <- map["max_age"]
        _rejectionText      <- map["rejection_reason.text"]
        _rejectionAuthor    <- map["rejection_reason.author.fn"]
        _rejectionDate      <- (map["rejection_reason.date_edited"], HappDateTransformer)
    }


    // functions
    func getStatus(activated: Bool? = nil) -> EventModelStatusTypes {
        var status = self.status
        if activated != nil {
            if !activated! { status = 3 }
        }else{
            if !self.is_active { status = 3 }
        }
        if let lastDate = self.datetimes.last?.raw_date {
            if NSDate() > HappDateFormats.ISOFormatBegin.toDate(lastDate) {
                status = 4
            }
        }
        return EventModelStatusTypes(rawValue: status)!
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

class ChatModel: Object {
    dynamic var id: String?
    dynamic var author: AuthorModel?
    dynamic var name: String?
    dynamic var message: String?
    dynamic var date: NSDate?
    dynamic var unread = 0
    
    required convenience init?(_ chat: QBChatDialog, manager: Bool = false) {
        self.init()
        id = chat.ID
        author = AuthorModel()
        author?.id = chat.data?[manager ? "participator" : "author"] as! String
        author?.fn = chat.data?[manager ? "participator_name" : "author_name"] as? String
        name = chat.data?[manager ? "participator_name" : "author_name"] as? String
        message = chat.lastMessageText
        date = chat.lastMessageDate
        unread = Int(chat.unreadMessagesCount)
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

class MessageModel: Object {
    dynamic var message: String?
    dynamic var incoming = false
    dynamic var date: NSDate?
    dynamic var id: String?
    
    required convenience init?(_ _message: QBChatMessage, _incoming: Bool) {
        self.init()
        id = _message.ID
        date = _message.dateSent
        message = _message.text
        incoming = _incoming
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
