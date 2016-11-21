//
//  EventOnMapViewModel.swift
//  Happ
//
//  Created by MacBook Pro on 11/21/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import Foundation


class EventOnMapViewModel: EventViewModel {
    
    var navigateEventDetails: NavigationFuncWithID

    
    override init() {
        super.init()
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
    func onClickOpen() {
        self.navigateEventDetails?(id: self.event.id)
    }
    
}
