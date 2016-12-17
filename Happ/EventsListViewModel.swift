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

    func fetchEvents(byPage page: Int, overwrite: Bool, filters: EventsListFiltersState? = nil) -> Promise<Void> {
        switch self {
        case .Feed:
            if EventService.isLastPageOfFeed {
                return Promise<Void>()
            }
            if filters == nil {
                return EventService.fetchFeed(page, overwrite: overwrite)
            }else{
                return EventService.fetchFeed(page, overwrite: overwrite, onlyFree: filters!.onlyFree, popular: filters?.sortBy == .ByPopular, startDate: filters!.dateFrom, endDate: filters!.dateTo, startTime: filters!.time)
            }
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


struct EventsListFiltersState {
    var search: String?
    var dateFrom: NSDate?
    var dateTo: NSDate?
    var time: NSDate?
    // for scope: .Feed, .Favourite
    var sortBy: EventsListSortType
    var onlyFree: Bool
    var convertCurrency: Bool
    // for scope: .MyEvents
    var statusMap: [EventModelStatusTypes: Bool]?
}

struct EventsListState {
    var scope: EventsListScope
    var fetchingState: RequestStates
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
    var navigateFeed: NavigationFunc
    var navigateSelectInterests: NavigationFunc
    var navigateCreateEvent: NavigationFunc


    init(scope: EventsListScope) {
        let filtersState = EventsListFiltersState(search: nil, dateFrom: nil, dateTo: nil, time: nil, sortBy: .ByDate, onlyFree: false, convertCurrency: false, statusMap: [.Active: false, .Inactive: false, .OnReview: false, .Finished: false])
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
        
        self.state.page = 1

        self.state.scope
            .fetchEvents(byPage: 1, overwrite: true, filters: filters)
            .then { _ -> Void in
                let events = scope.getEvents().filter { _ in return true }
                self.state = EventsListState(scope: scope, fetchingState: .FinishRequest, events: events, page: 1, filters: filters)
                self.didUpdate?()
            }
            .error { err in
                // catch NoInternet here
                let events = scope.getEvents().filter { _ in return true }
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
            .fetchEvents(byPage: nextPage, overwrite: false, filters: self.state.filters)
            .then { _ -> Void in
                let events = self.state.scope.getEvents()
                self.state.page = nextPage
                self.state.events = events.filter { _ in return true }
                self.didUpdate?()
            }
    }
    
    func onClickEvent(event: EventModel) {
        self.navigateEventDetails?(id: event.id)
    }
    
    func onChangeFilters(newState: EventsListFiltersState) {
        self.state.filters = newState
        self.initDataFetching()
    }

}



