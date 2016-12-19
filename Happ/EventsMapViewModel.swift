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



struct EventsMapState: PaginatedDataStateProtocol {
    var items: [Object]
    var page: Int
    var isFetching: Bool
    
    var filters: EventsListFiltersState

    static func getInitialState() -> EventsMapState {
        return EventsMapState(items: [], page: 0, isFetching: false, filters: EventsListFiltersState.getInitialState())
    }
}

struct EventsMapViewModel: PaginatedDataViewModelProtocol {
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

    func fetchData(page: Int, overwrite: Bool) -> Promise<Void> {
        return EventService.fetchFeed(page, overwrite: overwrite)
    }
    func getData() -> [Object] {
        return Array(EventService.getFeed())
    }
    func isLastPage() -> Bool {
        return EventService.isLastPageOfFeed
    }
}

