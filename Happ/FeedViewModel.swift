//
//  FeedViewModel.swift
//  Happ
//
//  Created by MacBook Pro on 9/19/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import Foundation
import PromiseKit


class FeedViewModel {

    var events: [EventModel] = []


    init() {
        // get from DB
        //self.events = self.getFiltered()

        EventService.fetchFromServer()
            .then { _ -> Void in
                self.events = self.getFiltered()
                self.didUpdate?()
            }
    }


    //MARK: - Events
    var didUpdate: (() -> Void)?
    

    //MARK: - Inputs
    func clickedLikeOnEvent(event: EventModel) {
        print(".FeedViewModel.inputs.clickedLikeOnEvent", event.id)
    }


    private func getFiltered() -> [EventModel] {
        return Array(EventService.getStoredEvents())
    }
    
}
