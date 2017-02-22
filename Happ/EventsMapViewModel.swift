//
//  EventsMapViewModel.swift
//  Happ
//
//  Created by MacBook Pro on 12/19/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit
import PromiseKit
import RealmSwift
import GoogleMapsCore


struct EventsMapState: DataStateProtocol {
    var items: [EventModel]
    var isFetching: Bool

    var filters: EventsListFiltersState

    var center: CLLocation?
    var radius: Int?

    static func getInitialState() -> EventsMapState {
        return EventsMapState(items: [], isFetching: false, filters: EventsListFiltersState.getInitialState(), center: nil, radius: nil)
    }
}

struct EventsMapViewModel: DataViewModelProtocol {
    var state: EventsMapState

    var navigateEventDetailsMap: NavigationFuncWithID
    var displaySlideMenu: NavigationFunc
    var displaySlideFilters: NavigationFunc
    var displayEmptyList: NavigationFunc


    init() {
        self.state = EventsMapState.getInitialState()
    }

    mutating func onChangeFilters(newFiltersState: EventsListFiltersState) {
        self.state = StateType.getInitialState()
        self.state.filters = newFiltersState
    }

    mutating func onChangeMapPosition(center: CLLocation, radius: Int, completion: (EventsMapState -> Void)) {
        self.state.center = center
        self.state.radius = radius

        self.onInitLoadingData(completion)
    }

    func fetchData(overwrite flagValue: Bool) -> Promise<Void> {
        return Promise { resolve, reject in
            EventService
                .fetchMap(self.state.center!, radius: self.state.radius!, overwrite: flagValue)
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
        return Array(EventService.getStored())
    }
}



