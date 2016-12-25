//
//  EventsExploreViewModel.swift
//  Happ
//
//  Created by MacBook Pro on 11/10/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import Foundation
import RealmSwift
import PromiseKit


struct EventsExploreState {
    var fetchingState: RequestStates
    var page: Int
    var events: [EventModel]
}


class EventsExploreViewModel {

    var navigateEventDetails: NavigationFuncWithID
    var displaySlideMenu: NavigationFunc


    // variables
    var state: EventsExploreState


    init() {
        self.state = EventsExploreState(fetchingState: .None, page: 0, events: [])

        self.initDataFetching()
    }

    func initDataFetching() {
        // 1. start request
        // 2. update fetchState -> display loading cells
        // 3. finish request -> delete database -> add new
        // 4. update fetchState -> display data | display EmptyPage if isEmpty
        // !. error request -> catch error
        // !. update fetchState -> display data | display EmptyPage if isEmpty
        
        self.state.fetchingState = .StartRequest
        self.didUpdate?()

        EventService.fetchExplore(1, overwrite: true)
            .then { _ -> Void in
                let newEvents = self.getEvents()
                self.state = EventsExploreState(fetchingState: .FinishRequest, page: 1, events: newEvents)
                self.didUpdate?()
            }
            .error { err in
                // catch NoInternet here
                let cachedEvents = self.getEvents() // old instances
                self.state = EventsExploreState(fetchingState: .NoInternet, page: 0, events: cachedEvents)
                self.didUpdate?()
                
        }
    }

    
    

    //MARK: - Events
    var didUpdate: (() -> Void)?


    //MARK: - Inputs
    func loadNextPage() {
        let nextPage = self.state.page + 1
        EventService.fetchExplore(nextPage, overwrite: false)
            .then { _ -> Void in
                let events = self.getEvents()
                self.state = EventsExploreState(fetchingState: .FinishRequest, page: nextPage, events: events)
                self.didUpdate?()
            }
        
    }
    func onClickEvent(event: EventModel) {
        self.navigateEventDetails?(id: event.id)
    }


    private func getEvents() -> [EventModel] {
        return Array(EventService.getStored())
    }
}


