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
}


struct EventsListFiltersState {
    var search: String?
    var sortBy: EventsListSortType
    var onlyFree: Bool
    var dateFrom: NSDate?
    var dateTo: NSDate?
}


struct EventsListState {
    var scope: EventsListScope
    var events: [EventModel]
    var page: Int
    var filters: EventsListFiltersState
}


class EventsListViewModel {

    var state: EventsListState

    var navigateEventDetails: NavigationFuncWithID
    var displaySlideMenu: NavigationFunc
    var displaySlideFeedFilters: NavigationFunc
    var hideSlideFeedFilters: NavigationFunc


    init(scope: EventsListScope) {
        let filtersState = EventsListFiltersState(search: nil, sortBy: .ByDate, onlyFree: false, dateFrom: nil, dateTo: nil)
        self.state = EventsListState(scope: scope, events: [], page: 0, filters: filtersState)
        self.loadNextPage() // will load first page
    }


    //MARK: - Events
    var didUpdate: (() -> Void)?


    //MARK: - Inputs
    func loadNextPage() {
        switch self.state.scope {
        case .Feed:
            if self.state.page != 0 && EventService.isLastPageOfFeed {
                return
            }
            self.state.page += 1
            self.fetchFeedEvents()
        case .Favourite:
            if self.state.page != 0 && EventService.isLastPageOfFavourites {
                return
            }
            self.state.page += 1
            self.fetchFavouriteEvents()
        case .MyEvents:
            break
        }
    }
    func onClickEvent(event: EventModel) {
        self.navigateEventDetails!(id: event.id)
    }
    func onChangeFilters(newState: EventsListFiltersState) {
        self.state.filters = newState
        self.state.events = self.getEvents()
        self.hideSlideFeedFilters!() // return to FeedViewController
        self.didUpdate!()
    }


    func getEvents() -> [EventModel] {
        var events: Results<EventModel>!
        switch self.state.scope {
        case .Feed:
            events = EventService.getFeed()
        case .Favourite:
            events = EventService.getFavourite()
        case .MyEvents:
            break
        }
        return self.filterEvents(events)
    }
    func getEventAt(indexPath: NSIndexPath) -> EventModel {
        return self.state.events[indexPath.row]
    }
    func getEventsCount() -> Int {
        return self.state.events.count
    }
    
    
    private func filterEvents(events: Results<EventModel>) -> [EventModel] {
        var events = events
        let filters = self.state.filters
        if filters.search != nil {
            events = events.filter("title CONTAINS %@", filters.search!)
        }
        if filters.onlyFree {
            events = events.filter("min_price == nil")
        }
        return events.sort(filters.sortBy.isOrderedBeforeFunc)
    }


    private func fetchFeedEvents() {
        EventService.fetchFeed(self.state.page)
            .then { _ -> Void in
                self.state.events = self.getEvents()
                self.didUpdate!()
        }
    }
    private func fetchFavouriteEvents() {
        EventService.fetchFavourite(self.state.page)
            .then { _ -> Void in
                self.state.events = self.getEvents()
                self.didUpdate!()
        }
    }

}



