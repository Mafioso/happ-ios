//
//  FeedViewModel.swift
//  Happ
//
//  Created by MacBook Pro on 9/19/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import Foundation
import PromiseKit


enum FeedSortType {
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

enum FeedTabs {
    case Feed
    case Favourite
}


struct FeedFiltersState {
    var search: String?
    var sortBy: FeedSortType
    var onlyFree: Bool
    var dateFrom: NSDate?
    var dateTo: NSDate?
}


struct FeedState {
    var tab: FeedTabs
    var events: [EventModel]
    var page: Int
    var filters: FeedFiltersState
}


class FeedViewModel {

    var state: FeedState

    var navigateEventDetails: NavigationFuncWithID
    var displaySlideMenu: NavigationFunc
    var displaySlideFeedFilters: NavigationFunc
    var hideSlideFeedFilters: NavigationFunc


    init() {
        let filtersState = FeedFiltersState(search: nil, sortBy: .ByDate, onlyFree: false, dateFrom: nil, dateTo: nil)
        self.state = FeedState(tab: .Feed, events: [], page: 1, filters: filtersState)

        self.fetchFeedEvents()
    }


    //MARK: - Events
    var didUpdate: (() -> Void)?


    //MARK: - Inputs
    func loadNextPage() {
        switch self.state.tab {
        case .Feed:
            if !EventService.isLastPageOfFeed {
                self.state.page += 1
                self.fetchFeedEvents()
            }
        case .Favourite:
            if !EventService.isLastPageOfFavourites {
                self.state.page += 1
                // self.fetchFavouriteEvents() TODO
            }
        }
    }
    func onChangeTab(tab: FeedTabs) {
        if self.state.tab != tab {
            self.state.tab = tab
            self.state.page = 0
            switch tab {
            case .Feed:
                self.fetchFeedEvents()
            case .Favourite:
                // self.fetchFavouriteEvents() TODO
                break
            }
        }
    }
    func onClickEvent(event: EventModel) {
        self.navigateEventDetails!(id: event.id)
    }
    func onChangeFilters(newState: FeedFiltersState) {
        self.state.filters = newState
        self.state.events = self.getEvents()
        self.hideSlideFeedFilters!() // return to FeedViewController
        self.didUpdate!()
    }


    func getEvents() -> [EventModel] {
        var events = EventService.getFeed()
        let filters = self.state.filters

        if filters.search != nil {
            events = events.filter("title CONTAINS %@", filters.search!)
        }
        if filters.onlyFree {
            events = events.filter("min_price == nil")
        }
        return events.sort(filters.sortBy.isOrderedBeforeFunc)
    }

    func getEventAt(indexPath: NSIndexPath) -> EventModel {
        return self.state.events[indexPath.row]
    }
    func getEventsCount() -> Int {
        return self.state.events.count
    }
    private func fetchFeedEvents() {
        EventService.fetchFeed(self.state.page)
            .then { _ -> Void in
                self.state.events = self.getEvents()
                self.didUpdate!()
        }
    }


}



