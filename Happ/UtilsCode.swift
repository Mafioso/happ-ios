//
//  CodeUtils.swift
//  Happ
//
//  Created by MacBook Pro on 9/8/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import Foundation
import ObjectMapper


extension Dictionary {
    mutating func merge(dict2: Dictionary) {
        for key in dict2.keys {
            self[key] = dict2[key]
        }
    }
}



enum HappDateFormats: String {
    case ISOFormat = "yyyy-MM-dd'T'HH:mm:ss"


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




