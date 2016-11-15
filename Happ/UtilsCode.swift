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



enum DefaultParametersKeyTypes: String {
    case GoogleMapApiKey = "api_key_google_map"
}

class DefaultParameters {
    static var sharedInstance = DefaultParameters()
    
    let plistFileName = "Default"
    var dataDictionary: [String:AnyObject]

    private init() {
        var format = NSPropertyListFormat.XMLFormat_v1_0 //format of the property list
        let plistPath:String? = NSBundle.mainBundle().pathForResource(plistFileName, ofType: "plist")! //the path of the data
        let plistXML = NSFileManager.defaultManager().contentsAtPath(plistPath!)! //the data in XML format
        do{ //convert the data to a dictionary and handle errors.
            self.dataDictionary = try NSPropertyListSerialization.propertyListWithData(plistXML,options: .MutableContainersAndLeaves,format: &format)as! [String:AnyObject]
        }
        catch{ // error condition
            print("Error reading plist: \(error), format: \(format)")
            self.dataDictionary = [:]
        }
    }
    static func getValue(forKey: DefaultParametersKeyTypes) -> AnyObject {
        return DefaultParameters.sharedInstance.dataDictionary[forKey.rawValue]!
    }
}



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
    case OnlyTime = "HH:mm"


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





