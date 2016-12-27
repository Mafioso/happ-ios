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
import GoogleMaps
import MessageUI




enum EmailSenderCompose {
    case Simple(subject: String, body: String, receipants: [String])
}

protocol EmailSenderProtocol: MFMailComposeViewControllerDelegate {
    func sendEmail(composed: EmailSenderCompose)
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult)
}
extension EmailSenderProtocol where Self: UIViewController {
    func sendEmail(email: EmailSenderCompose) {
        var receipants: [String]
        var subject: String
        var body: String
        
        switch email {
        case .Simple(let _subject, let _body, let _receipants):
            receipants = _receipants
            subject = _subject
            body = _body
        }
        
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(receipants)
            mail.setSubject(subject)
            mail.setMessageBody("<p>\(body).</p> <br/>", isHTML: true)
            
            self.presentViewController(mail, animated: true, completion: nil)
            
        } else {
            let params = [
                "subject": subject,
                "body": body
            ]
            
            let query = params.map { NSURLQueryItem(name: $0.0, value: $0.1) }
            let mailTo = NSURLComponents(string: "mailto:\(receipants.first!)")!
            mailTo.queryItems = query
            let mailToURL = mailTo.URL!
            
            UIApplication.sharedApplication().openURL(mailToURL)
        }
    }
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}



struct ScreenSize
{
    static let SCREEN_WIDTH = UIScreen.mainScreen().bounds.size.width
    static let SCREEN_HEIGHT = UIScreen.mainScreen().bounds.size.height
    static let SCREEN_MAX_LENGTH = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

struct DeviceType
{
    static let IS_IPHONE_4_OR_LESS =  UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
    static let IS_IPHONE_5 = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
    static let IS_IPHONE_6 = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
    static let IS_IPHONE_6P = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
}


enum DefaultParametersKeyTypes: String {
    case GoogleMapApiKey = "api_key_google_map"
    case HappEmailAddress = "happ_email"
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


func getSystemLanguage() -> String? {
    let langAndRegion = NSLocale.preferredLanguages()[0] as String? // en-KZ
    return langAndRegion?.componentsSeparatedByString("-").first
}


extension Dictionary {
    mutating func merge(dict2: Dictionary) {
        for key in dict2.keys {
            self[key] = dict2[key]
        }
    }
}




extension CLLocation {
    convenience init(geopoint: GeoPointModel) {
        self.init(latitude: geopoint.lat, longitude: geopoint.long)
    }
    func asGeoPoint() -> GeoPointModel {
        let inst = GeoPointModel()
        inst.lat = Double(self.coordinate.latitude)
        inst.long = Double(self.coordinate.longitude)
        return inst
    }
}


enum DistanceTypes {
    case Metric
    case Mile
}


struct Utils {
    static func formatDistance(value: Double, type: DistanceTypes) -> String {
        switch type {
        case .Metric:
            switch value {
            case 0..<1000:
                return "\(value) m"
            default:
                return Double(value / 1000).format(".1") + " km"
            }
        case .Mile:
            return "\(value) mi"
        }
    }
    static func isNilOrZero(value: Int?) -> Bool {
        return (value == nil || value! == 0)
    }
}

extension Double {
    func format(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}

func formatStatValue(value: Int) -> String {
    return String(value)
}


enum HappEventPriceFormats {
    case EventMinPrice(event: EventModel)
    case EventPriceRange(event: EventModel)
    
    func toString() -> String {
        switch self {
        case .EventMinPrice(let event):
            guard let currency = event.currency else { return "ERROR" }
            if  let value = event.min_price
                where value > 0
            {
                return "from" + " \(value) \(currency.code)"
            } else {
                return "FREE"
            }

        case .EventPriceRange(let event):
            guard let currency = event.currency else { return "ERROR" }
            let minValue = event.min_price
            let maxValue = event.max_price

            if minValue == nil || (minValue == 0 && Utils.isNilOrZero(maxValue)) {
                return "FREE"
            } else if minValue! > 0 && (maxValue == nil || maxValue! == minValue!) {
                return "\(minValue!)\n\(currency.name)"
            } else {
                return "\(minValue!) – \(maxValue!)\n\(currency.name)"
            }
        }
    }
}

enum HappEventDateFormats {
    case EventDate(datetime: EventDateModel)
    case EventTimeRange(datetime: EventDateModel)
    case EventDetails(first_datetime: EventDateModel, last_datetime: EventDateModel)

    func toString() -> String {
        switch self {
        case .EventDate(let datetime):
            let formatter = NSDateFormatter()
            formatter.dateFormat = "MMMM d"
            return formatter.stringFromDate(datetime.start_time)

        case .EventDetails(let first_datetime, let last_datetime):
            let dayFormatter = NSDateFormatter()
            dayFormatter.dateFormat = "MMM d"
            let timeFormatter = NSDateFormatter()
            timeFormatter.dateFormat = "HH:mm"
            return "\(dayFormatter.stringFromDate(first_datetime.start_time)) – \(dayFormatter.stringFromDate(last_datetime.end_time)) \n\(timeFormatter.stringFromDate(first_datetime.start_time)) – \(timeFormatter.stringFromDate(last_datetime.end_time))"

        case .EventTimeRange(let datetime):
            let formatter = NSDateFormatter()
            formatter.dateFormat = "HH:mm"
            return "\(formatter.stringFromDate(datetime.start_time)) – \(formatter.stringFromDate(datetime.end_time))"
        }
    }
}

enum HappDateFormats: String {
    case ISOFormat = "yyyy-MM-dd'T'HH:mm:ss"
    case DateTime = "yyyy-MM-dd HH:mm:ss"
    case EventOnFeed = "MMMM d"
    case OnlyTime = "HH:mm"


    func getFormatter() -> NSDateFormatter {
        let formatter = NSDateFormatter()
        formatter.dateFormat = self.rawValue
        return formatter
    }

    func toString(date: NSDate) -> String {
        return self.getFormatter().stringFromDate(date)
    }

    func toDate(var value: String) -> NSDate? {
        if self == HappDateFormats.ISOFormat {
            value = value.componentsSeparatedByString(".").first!
        }
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





