//
//  CodeUtils.swift
//  Happ
//
//  Created by MacBook Pro on 9/8/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import Foundation


extension Dictionary {
    mutating func merge(dict2: Dictionary) {
        for key in dict2.keys {
            self[key] = dict2[key]
        }
    }
}



enum HappDateFormats: String {
    case ISOFormat = "yyyy-MM-dd'T'HH:mm:ss"
}

func dateParseFrom(format: HappDateFormats, value: String) -> NSDate {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = format.rawValue
    return dateFormatter.dateFromString(value)!
}

