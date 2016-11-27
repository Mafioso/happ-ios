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
        if self.location != nil {
            let eventLocation = CLLocation(latitude: 43.233018, longitude: 76.955978)
            MapService.fetchDirection(self.location!, to: eventLocation)
                .then { direction -> Void in
                    self.mapDirection = direction
                    self.didUpdate?()
            }
        }
    }
}



