//
//  EventsListViewModel.swift
//  Happ
//
//  Created by MacBook Pro on 9/19/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import Foundation
import PromiseKit
import RealmSwift


enum EventsListSortType {
    case ByDate
    case ByPopular

    func isOrderedBeforeFunc(event1: EventModel, event2: EventModel) -> Bool {
        let date1 = event1.start_datetime!
        let date2 = event2.start_datetime!
        let diff = NSCalendar.currentCalendar().components([.Day, .Hour], fromDate: date1, toDate: date2, options: [])
        let isSameDay = diff.day == 0
        let isLater = date1.laterDate(date2).isEqualToDate(date1)

        if isSameDay {
            switch self {
            case .ByDate:
                return isLater
            case .ByPopular:
                return event1.votes_num > event2.votes_num
            }
        } else {
            return isLater
        }
    }
}

enum EventsListScope {
    case Feed
    case Favourite
    case MyEvents

    func fetchEvents(byPage page: Int, overwrite: Bool) -> Promise<Void> {
        switch self {
        case .Feed:
            if EventService.isLastPageOfFeed {
                return Promise<Void>()
            }
            return EventService.fetchFeed(page, overwrite: overwrite)
        case .Favourite:
            if EventService.isLastPageOfFavourites {
                return Promise<Void>()
            }
            return EventService.fetchFavourite(page, overwrite: overwrite)
        default:
            fatalError()
        }
    }
    func getEvents() -> Results<EventModel> {
        switch self {
        case .Feed:
            return EventService.getFeed()
        case .Favourite:
            return EventService.getFavourite()
        default:
            fatalError()
        }
    }
}

enum FetchingStates: Int {
    case None = 0
    case StartRequest = 1
    case FinishRequest = 2
    case NoInternet = 3
}


struct EventsListFiltersState {
    var search: String?
    var dateFrom: NSDate?
    var dateTo: NSDate?
    // for scope: .Feed, .Favourite
    var sortBy: EventsListSortType
    var onlyFree: Bool
    // for scope: .MyEvents
    var statusMap: [EventModelStatusTypes: Bool]?
}

struct EventsListState {
    var scope: EventsListScope
    var fetchingState: FetchingStates
    var events: [EventModel]
    var page: Int
    var filters: EventsListFiltersState
}


class EventsListViewModel {

    var state: EventsListState

    var navigateEventDetails: NavigationFuncWithID
    var navigateEventDetailsMap: NavigationFuncWithID
    var displaySlideMenu: NavigationFunc
    var displaySlideFeedFilters: NavigationFunc
    var hideSlideFeedFilters: NavigationFunc
    var displayEmptyList: NavigationFunc
    var hideEmptyList: NavigationFunc


    init(scope: EventsListScope) {
        let filtersState = EventsListFiltersState(search: nil, dateFrom: nil, dateTo: nil, sortBy: .ByDate, onlyFree: false, statusMap: [.Active: false, .Inactive: false, .OnReview: false, .Finished: false])
        self.state = EventsListState(scope: scope, fetchingState: .None, events: [], page: 0, filters: filtersState)

        self.initDataFetching()
    }


    func initDataFetching() {
        // 1. start request
        // 2. update fetchState -> display loading cells
        // 3. finish request -> delete database -> add new
        // 4. update fetchState -> display data | display EmptyPage if isEmpty
        // !. error request -> catch error
        // !. update fetchState -> display data | display EmptyPage if isEmpty

        let scope = self.state.scope
        let filters = self.state.filters

        self.state.fetchingState = .StartRequest
        self.didUpdate?()

        self.state.scope
            .fetchEvents(byPage: 1, overwrite: true)
            .then { _ -> Void in
                let events = self.filterEvents(scope.getEvents())
                self.state = EventsListState(scope: scope, fetchingState: .FinishRequest, events: events, page: 1, filters: filters)
                self.didUpdate?()
            }
            .error { err in
                // catch NoInternet here
                let events = self.filterEvents(scope.getEvents()) // old instances
                self.state = EventsListState(scope: scope, fetchingState: .NoInternet, events: events, page: 0, filters: filters)
                self.didUpdate?()
                
            }
    }


    //MARK: - Events
    var didUpdate: (() -> Void)?


    //MARK: - Inputs
    func loadNextPage() {
        let nextPage = self.state.page + 1
        self.state.scope
            .fetchEvents(byPage: nextPage, overwrite: false)
            .then { _ -> Void in
                let events = self.filterEvents(self.state.scope.getEvents())
                self.state.page = nextPage
                self.state.events = events
                self.didUpdate?()
            }
    }
    func onClickEvent(event: EventModel) {
        self.navigateEventDetails?(id: event.id)
    }
    func onChangeFilters(newState: EventsListFiltersState) {
        self.state.filters = newState
        self.state.events = self.filterEvents(self.state.scope.getEvents())
        self.hideSlideFeedFilters!() // return to FeedViewController
        self.didUpdate?()
    }


    private func filterEvents(events: Results<EventModel>) -> [EventModel] {
        var events = events
        let filters = self.state.filters
        if filters.search != nil {
            events = events.filter("title CONTAINS[c] %@", filters.search!)
        }
        if filters.onlyFree {
            events = events.filter("min_price == nil")
        }
        // TODO filters.statusMap
        return events.sort(filters.sortBy.isOrderedBeforeFunc)
    }

}



