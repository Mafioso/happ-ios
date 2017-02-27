//
//  EventDatetimesViewModel.swift
//  Happ
//
//  Created by MacBook Pro on 2/27/17.
//  Copyright © 2017 Sattar Stamkulov. All rights reserved.
//

import Foundation

class EventDatetimesViewModel: EventViewModel {

    
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

}


