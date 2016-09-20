//
//  EventModel.swift
//  Happ
//
//  Created by MacBook Pro on 9/19/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper
import ObjectMapper_Realm


class RealmImage: Object, Mappable {
    dynamic var url = ""
    
    required convenience init?(_ map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        url <- map["url"]
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
    // TODO: convert to `dynamic var parent: InterestModel?`
    // let children = List<InterestModel>()
    dynamic var title = ""
    dynamic var color = "FF0000"


    required convenience init?(_ map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        id          <- map["id"]
        // parent      <- map["parent"]
        // children    <- (map["children"], ListTransform<InterestModel>())
        title       <- map["title"]
        color       <- map["color"]
    }

    override static func primaryKey() -> String? {
        return "id"
    }
}

class AuthorPhoneModel: Object, Mappable {
    dynamic var number = ""

    
    required convenience init?(_ map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        number <- map["number"]
    }

    override class func primaryKey() -> String? {
        return "number"
    }
}




class EventModel: Object, Mappable {
    dynamic var id = ""
    var interests = List<InterestModel>()
    dynamic var currency: CurrencyModel?
    //dynamic var city: CityModel? = CityModel(value: ["1capital", "Kazakhstan", "Astana"])
    dynamic var author: AuthorModel?
    dynamic var start_datetime: NSDate?
    dynamic var end_datetime: NSDate?
    var images = List<RealmImage>()
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
    dynamic var geopoint: NSData?
    dynamic var phones: AuthorPhoneModel?
    dynamic var email: String?
    dynamic var web_site: String?
    dynamic var votes = 0


    required convenience init?(_ map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        id                  <- map["id"]
        interests           <- (map["interests"], ListTransform<InterestModel>())
        currency            <- map["currency"]
        // city                <- map["city"]
        author              <- map["author"]
        start_datetime      <- (map["start_datetime"], HappDateTransformer)
        end_datetime        <- (map["end_datetime"], HappDateTransformer)
        images              <- (map["images"], ListTransform<RealmImage>())
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
        phones              <- map["phones"]
        email               <- map["email"]
        web_site            <- map["web_site"]
        votes               <- map["votes"]
    }

    override static func primaryKey() -> String? {
        return "id"
    }
}
