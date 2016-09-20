//
//  EventModel.swift
//  Happ
//
//  Created by MacBook Pro on 9/19/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON


class RealmImage: Object {
    dynamic var url = ""
}

class AuthorModel: Object {
    dynamic var id = ""
    dynamic var fn: String?
    let events = LinkingObjects(fromType: EventModel.self, property: "author")

    override static func primaryKey() -> String? {
        return "id"
    }
}

class CurrencyModel: Object {
    dynamic var id = ""
    dynamic var name = ""

    override static func primaryKey() -> String? {
        return "id"
    }
}

class CityModel: Object {
    dynamic var id = ""
    dynamic var country_name = ""
    dynamic var name = ""

    override static func primaryKey() -> String? {
        return "id"
    }
}

class InterestModel: Object {
    dynamic var id = ""
    let children = List<InterestModel>()
    dynamic var title = ""
    dynamic var color = "FF0000"
    dynamic var parent = "parent ID"
    // dynamic var parent: InterestModel?

    override static func primaryKey() -> String? {
        return "id"
    }
}

class AuthorPhoneModel: Object {
    dynamic var number = ""
}


enum EventModelDateFields {
    case start_datetime
    case end_datetime
    case date_created
    case date_edited
}


class EventModel: Object {
    dynamic var id = ""
    let interests = List<InterestModel>()
    dynamic var currency: CurrencyModel?
    dynamic var city: CityModel?
    dynamic var author: AuthorModel?
    dynamic var start_datetime = ""
    dynamic var end_datetime = ""
    let images = List<RealmImage>()
    dynamic var date_created = ""
    dynamic var date_edited = ""
    dynamic var title = ""

    // NOTE: `description` name is already used in Object
    dynamic var description_text = ""
    dynamic var language = ""
    dynamic var type = 0
    dynamic var status = 0
    let min_price = RealmOptional<Int>()
    let max_price = RealmOptional<Int>()
    dynamic var address: String?
    dynamic var geopoint: NSData?
    dynamic var phones: AuthorPhoneModel?
    dynamic var email: String?
    dynamic var web_site: String?
    dynamic var votes = 0


    func getDate(field: EventModelDateFields) -> NSDate {
        var value = ""
        switch field {
        case .date_created:
            value = self.date_created
        case .date_edited:
            value = self.date_edited
        case .start_datetime:
            value = self.start_datetime
        case .end_datetime:
            value = self.end_datetime
        }
        return dateParseFrom(.ISOFormat, value: value)
    }

    class func clearRawData(data: JSON) -> [String: AnyObject] {
        var dict = data.dictionaryObject!
        var nonAvailableKeys = ["city"]

        dict.forEach({ key, value in
            print(".", key, value, value is NSNull, JSON(value).null)
            if value is NSNull {
                nonAvailableKeys.append(key)
            }
        })

        dict.updateValue(data["description"].stringValue, forKey: "description_text")
        nonAvailableKeys.append("description")

        nonAvailableKeys.forEach({ dict.removeValueForKey($0) })
        return dict
    }


    override static func primaryKey() -> String? {
        return "id"
    }
}
