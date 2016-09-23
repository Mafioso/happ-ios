//
//  CodeUtils.swift
//  Happ
//
//  Created by MacBook Pro on 9/8/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift


extension Dictionary {
    mutating func merge(dict2: Dictionary) {
        for key in dict2.keys {
            self[key] = dict2[key]
        }
    }
}


func formatStatValue(value: Int) -> String {
    return String(value)
}


enum HappDateFormats: String {
    case ISOFormat = "yyyy-MM-dd'T'HH:mm:ss"
    case EventOnFeed = "MMMM d, H:mm a"


    func getFormatter() -> NSDateFormatter {
        let formatter = NSDateFormatter()
        formatter.dateFormat = self.rawValue
        return formatter
    }

    func toString(date: NSDate) -> String {
        return self.getFormatter().stringFromDate(date)
    }

    func toDate(value: String) -> NSDate? {
        return self.getFormatter().dateFromString(value)
    }
}


let HappDateTransformer = TransformOf<NSDate, String>(fromJSON: { (value: String?) -> NSDate? in
    return (value == nil) ? nil : HappDateFormats.ISOFormat.toDate(value!)
    }, toJSON: { (value: NSDate?) -> String? in
        return  (value == nil) ? nil : HappDateFormats.ISOFormat.toString(value!)
})



// gist source: https://gist.github.com/Jerrot/fe233a94c5427a4ec29b
class ArrayTransform<T:RealmSwift.Object where T:Mappable> : TransformType {
    typealias Object = List<T>
    typealias JSON = Array<AnyObject>

    let mapper = Mapper<T>()

    func transformFromJSON(value: AnyObject?) -> List<T>? {
        var result = List<T>()
        if let tempArr = value as! Array<AnyObject>? {
            for entry in tempArr {
                let mapper = Mapper<T>()
                let model : T = mapper.map(entry)!
                result.append(model)
            }
        }
        return result
    }

    func transformToJSON(value: Object?) -> JSON? {
        var results = [AnyObject]()
        if let value = value {
            for obj in value {
                let json = mapper.toJSON(obj)
                results.append(json)
            }
        }
        return results
    }
}


private let ArrayStringTransformerSeparator = "#NEXT_VALUE#"
let ArrayStringTransformer = TransformOf<String, [String]>(fromJSON: { (value: [String]?) -> String? in
    var result = ""
    if value != nil {
        result = value!.joinWithSeparator(ArrayStringTransformerSeparator)
    }
    return result

    }, toJSON: { (value: String?) -> [String]? in
        let result = value?.componentsSeparatedByString(ArrayStringTransformerSeparator)
        return result!
})





