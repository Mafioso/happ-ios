//
//  FeedViewModel.swift
//  Happ
//
//  Created by MacBook Pro on 9/19/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import Foundation
import PromiseKit


/*
enum EventSortType {
    case ByDate
    case ByPopular
    
    func getSelectOptionTitle(currentSort: EventSortType) -> String {
        var title: String
        switch self {
        case .ByDate:
            title = "Date"
        case .ByPopular:
            title = "Popular"
        }
        return title + (self == currentSort ? " ✔︎" : "")
    }
    
    func isOrderedBeforeFunc(event1: EventModel, event2: EventModel) -> Bool {
        let date1 = event1.start_datetime
        let date2 = event2.start_datetime
        let diff = NSCalendar.currentCalendar().components([.Day, .Hour], fromDate: date1!, toDate: date2!, options: [])
        let isSameDay = diff.day == 0
        
        switch self {
        case .ByDate:
            if isSameDay {
                return false
            }
            return true
        case .ByPopular:
            return false
        }
    }
}
*/


enum FeedTabs {
    case Feed
    case Favourite
}

struct FeedState {
    var tab: FeedTabs
    var events: [EventModel]
    var page: Int
    // var filtersModel: TODO
}


class FeedViewModel {

    var state = FeedState(tab: .Feed, events: Array(EventService.getFeed()), page: 1)

    var navigateEventDetails: NavigationFuncWithID
    var displaySlideMenu: NavigationFunc
    var displaySlideFeedFilters: NavigationFunc


    init() {
        
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
    func onClickLike(event: EventModel) {
        print(".FeedViewModel.inputs.onClickLike", event.id)
    }
    func onClickFavourite(event: EventModel) {
        print(".FeedViewModel.inputs.onClickFavourite", event.id)
    }
    func onClickEvent(event: EventModel) {
        self.navigateEventDetails!(id: event.id)
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
                self.state.events = Array(EventService.getFeed())
                self.didUpdate?()
        }
    }

    
}



