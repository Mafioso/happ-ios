//
//  EventOnMapViewModel.swift
//  Happ
//
//  Created by MacBook Pro on 11/21/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import Foundation
import GoogleMaps


class EventOnMapViewModel: EventViewModel {
    
    var navigateEventDetails: NavigationFuncWithID

    // variables
    var mapDirection: MapDirection?
    var location: CLLocation?


    override init() {
        super.init()
        
        self.fetchDirection()
    }

    convenience init(event: EventModel) {
        self.init()
        self.event = event
    }

    convenience init(forID: String) {
        self.init()
        self.event = EventService.getByID(forID)
    }


    // inputs:
    func onClickOpenEventDetails() {
        //self.navigateBack?()
        self.navigateEventDetails?(id: self.event.id)
    }
    func onFoundLocation(location: CLLocation) {
        self.location = location
        self.fetchDirection()
    }


    private func fetchDirection() {
        guard let myLocation = self.location else { return }
        EventService.updateGeoPointIfNotExists(self.event)
            .then { event -> Void in
                let eventLocation = CLLocation(geopoint: event.geopoint!)
                MapService.fetchDirection(myLocation, to: eventLocation)
                    .then { direction -> Void in
                        self.mapDirection = direction
                        self.didUpdate?()
                }
        }
    }
}



