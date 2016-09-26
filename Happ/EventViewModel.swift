//
//  EventModelView.swift
//  Happ
//
//  Created by MacBook Pro on 9/19/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import Foundation
import PromiseKit



class EventViewModel {

    var eventID: Int?
    var event: EventModel?

    
    init() {
        
    }

    convenience init(forID: String) {
        self.init()
        self.event = EventService.getByID(forID)
        
        print("..", forID, event)

    }


    //MARK: - Events
    var didUpdate: (() -> Void)?
    
    
    //MARK: - Inputs

    
}
