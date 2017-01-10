//
//  EventManageViewModel.swift
//  Happ
//
//  Created by MacBook Pro on 10/18/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import Foundation
import PromiseKit
import RealmSwift

class EventManageViewModel {

    var navigateBack: NavigationFunc
    var navigateNext: NavigationFunc
    var navigateSubmit: NavigationFunc
    var navigatePickInterest: NavigationFunc
    var navigatePickCity: NavigationFunc
    var navigatePickCurrency: NavigationFunc
    var navigatePickPlace: NavigationFunc

    var isEditing: Bool
    var event: EventModel
    
    var uploadingPhotos: [String:UIImage?] = [:]
    var uploadedPhotoModels: [String:ImageModel] = [:]
    var name: String?
    var interests: [InterestModel] = []
    var description: String?
    
    var city: CityModel?
    var place: MapPlace?
    var priceFrom: Int?
    var priceTo: Int?
    var currency: CurrencyModel?
    var dateStart: NSDate?
    var dateEnd: NSDate?
    var timeFrom: NSDate?
    var timeTo: NSDate?
    var continuity: Bool = false
    
    var phones: [String] = []
    var email: String?
    var website: String?
    var tickets: String?
    var registration: String?
    var ageFrom: Int?
    var ageTo: Int?

    //MARK: - Events
    var didUpdatePhotos: ((Bool) -> Void)?
    var didFail: (Void -> Void)?

    //MARK: - Inputs
    func onClickSelectInterest() {
        self.navigatePickInterest?()
    }
    
    func onClickSelectCity() {
        self.navigatePickCity?()
    }
    
    func onClickSelectCurrency() {
        self.navigatePickCurrency?()
    }
    
    func onClickSelectPlace() {
        self.navigatePickPlace?()
    }
    
    func onPickImage(image: UIImage) {
        let key = String.randomNumericString(6)
        
        uploadingPhotos.updateValue(image, forKey: key)
        didUpdatePhotos?(false)
        
        UploadImage(image)
            .then { imageData -> Void in
                self.uploadedPhotoModels.updateValue(imageData, forKey: key)
                self.didUpdatePhotos?(false)
            }
            .error { err in
                self.uploadingPhotos.removeValueForKey(key)
                self.didUpdatePhotos?(true)
        }
    }
    
    func onSelectInterests(interests: [InterestModel]) {
        self.interests = interests
    }
    
    func onSelectName(name: String?, andDescription description: String?) {
        self.name = name
        self.description = description
    }
    
    func onSelectCity(city: CityModel) {
        self.city = city
    }
    
    func onSelectPlace(place: MapPlace) {
        self.place = place
    }
    
    func onSelectPrice(priceFrom: Int?, to priceTo: Int?) {
        self.priceFrom = priceFrom
        self.priceTo = priceTo
    }
    
    func onSelectCurrency(currency: CurrencyModel) {
        self.currency = currency
    }
    
    func onSelectDateStart(dateStart: NSDate?) {
        self.dateStart = dateStart
    }
    
    func onSelectDateEnd(dateEnd: NSDate?) {
        self.dateEnd = dateEnd
    }
    
    func onSelectTimeFrom(timeFrom: NSDate?) {
        self.timeFrom = timeFrom
    }
    
    func onSelectTimeTo(timeTo: NSDate?) {
        self.timeTo = timeTo
    }
    
    func onSelectContinuity(continuity: Bool) {
        self.continuity = continuity
    }
    
    func onSubmitBySelectPhones(phones: [String], andEmail email: String?, andWebsite website: String?, andTickets tickets: String?, andRegistration registration: String?, andAgeFrom ageFrom: Int?, andAgeTo ageTo: Int?) {
        self.phones = phones
        self.email = email
        self.website = website
        self.tickets = tickets
        self.registration = registration
        self.ageFrom = ageFrom
        self.ageTo = ageTo
        
        self.submit()
    }

    init() {
        self.isEditing = false
        self.event = EventModel()
    }
    
    convenience init(event: EventModel) {
        self.init()
        
        self.event = event
        self.isEditing = true
        
        self.name = event.title
        self.description = event.description_text
        event.interests.forEach {
            self.interests.append($0)
        }
        event.images.forEach {
            let key = String.randomNumericString(6)
            self.uploadedPhotoModels.updateValue($0, forKey: key)
            self.uploadingPhotos.updateValue(nil, forKey: key)
        }
        
        self.city = event.city
        let name = event.place_name != nil ? event.place_name! : ""
        let address = event.address != nil ? event.address! : ""
        let location = event.geopoint != nil ? CLLocation(geopoint: event.geopoint!) : CLLocation()
        self.place = MapPlace(name: name, photoRef: "", address: address, location: location)
        self.priceFrom = event.min_price
        self.priceTo = event.max_price
        self.currency = event.currency
        self.dateStart = HappDateFormats.ISOFormatBegin.toDate((event.datetimes.first?.raw_date)!)
        self.dateEnd = HappDateFormats.ISOFormatBegin.toDate((event.datetimes.last?.raw_date)!)
        self.timeFrom = HappDateFormats.ISOFormatEnd.toDate((event.datetimes.first?.raw_start_time)!)
        self.timeTo = HappDateFormats.ISOFormatEnd.toDate((event.datetimes.first?.raw_end_time)!)
        self.continuity = !event.is_close_on_start
        self.phones = event.phones
        self.email = event.email
        self.website = event.web_site
        self.tickets = event.tickets_link
        self.registration = event.registration_link
        self.ageFrom = event.min_age
        self.ageTo = event.max_age
    }
    
    private func submit() {
        var images: [String] = []
        self.uploadedPhotoModels.forEach {
            images.append($0.1.id)
        }
        
        var interests: [String] = []
        self.interests.forEach {
            interests.append($0.id)
        }
        
        let dateStart = HappDateFormats.ISOFormatBegin.toString(self.dateStart!)
        let dateEnd = HappDateFormats.ISOFormatBegin.toString(self.dateEnd!)
        let timeStart = HappDateFormats.ISOFormatEnd.toString(self.timeFrom!)
        let timeEnd = HappDateFormats.ISOFormatEnd.toString(self.timeTo!)
        
        var event: [String:AnyObject] = [
            "image_ids": images,
            "title": name!,
            "description": description!,
            "interest_ids": interests,
            "city_id": city!.id,
            "address": place!.address,
            "geopoint": ["lat": Double(place!.location.coordinate.latitude), "lng": Double(place!.location.coordinate.longitude)],
            "place_name": place!.name,
            "start_datetime": "\(dateStart)T\(timeStart)",
            "end_datetime": "\(dateEnd)T\(timeEnd)",
            "close_on_start": !continuity,
            "phones": phones
        ]
        
        if priceFrom != nil { event.updateValue(priceFrom!, forKey: "min_price") }
        else { event.updateValue(0, forKey: "min_price") }
        if priceTo != nil { event.updateValue(priceTo!, forKey: "max_price") }
        else { event.updateValue(0, forKey: "max_price") }
        
        if currency != nil { event.updateValue(currency!.id, forKey: "currency_id") }
        if email != nil { event.updateValue(email!, forKey: "email") }
        if website != nil { event.updateValue(website!, forKey: "web_site") }
        if tickets != nil { event.updateValue(tickets!, forKey: "tickets_link") }
        if registration != nil { event.updateValue(registration!, forKey: "registration_link") }
        if ageFrom != nil { event.updateValue(ageFrom!, forKey: "min_age") }
        if ageTo != nil { event.updateValue(ageTo!, forKey: "max_age") }
        
        EventService.createOrEditEvent(isEditing ? self.event.id : nil, valuesDict: event)
        .then { _ in
            self.navigateSubmit?()
        }
        .error { err in
            self.didFail?()
        }
    }

}
