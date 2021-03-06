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


struct EventsExploreState: DataStateProtocol {
    var items: [EventModel]
    var isFetching: Bool
    
    static func getInitialState() -> EventsExploreState {
        return EventsExploreState(items: [], isFetching: false)
    }
}


struct EventsExploreViewModel: DataViewModelProtocol {

    var navigateEventDetails: NavigationFuncWithID
    var displaySlideMenu: NavigationFunc


    // variables
    var state: EventsExploreState


    init() {
        self.state = EventsExploreState.getInitialState()
    }

    mutating func onInitLoadingNextData(completion: ((EventsExploreState) -> Void)) {
        completion(self.state)
        self.state.isFetching = true
        self.fetchData(overwrite: false)
            .then { _ -> Void in
                let newItems = self.getData()
                var updState = self.state
                updState.items = newItems
                updState.isFetching = false
                completion(updState)
            }
            .error { err in
                let cachedItems = self.getData()
                var updState = self.state
                updState.items = cachedItems
                updState.isFetching = false
                completion(updState)
        }
    }
    mutating func onInitLoadingData(completion: ((EventsExploreState) -> Void)) {
        self.state.isFetching = true
        self.fetchData(overwrite: true)
            .then { _ -> Void in
                let newItems = self.getData()
                var updState = self.state
                updState.items = newItems
                updState.isFetching = false
                completion(updState)
            }
            .error { err in
                let cachedItems = self.getData()
                var updState = self.state
                updState.items = cachedItems
                updState.isFetching = false
                completion(updState)
        }
    }
    func fetchData(overwrite flagValue: Bool) -> Promise<Void> {
        return Promise { resolve, reject in
            EventService
                .fetchExplore(overwrite: flagValue)
                .then { resolve() }
                .error { err in
                    switch err {
                    case EventErrors.MutexWriteDenied:
                        //do nothing
                        break
                    default:
                        reject(err)
                    }
                }
        }
    }
    func getData() -> [EventModel] {
        return EventService.getExplore()
    }

    
    //MARK: - Inputs
    func onClickEvent(event: EventModel) {
        self.navigateEventDetails?(id: event.id)
    }

}


