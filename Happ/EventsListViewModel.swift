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




// MARK: - ViewModels
struct EventsMapViewModel: EventsListViewModelProtocol {
    var state: EventsListState

    var navigateEventDetailsMap: NavigationFuncWithID
    var navigateEventDetails: NavigationFuncWithID
    var displaySlideMenu: NavigationFunc
    var displaySlideFilters: NavigationFunc
    var displayEmptyList: NavigationFunc
    

    init() {
        self.state = EventsListState.getInitialState()
    }


    func fetchData(page: Int, overwrite: Bool) -> Promise<Void> {
        let filters = self.state.filters
        return EventService.fetchFeed(page, overwrite: overwrite,
                                      onlyFree: filters.onlyFree, popular: filters.sortBy == .ByPopular, startDate: filters.dateFrom, endDate: filters.dateTo, startTime: filters.time)
    }
    func getData() -> [Object] {
        return Array(EventService.getFeed())
    }
    func isLastPage() -> Bool {
        return EventService.isLastPageOfFeed
    }
}


struct EventsManageViewModel: EventsListSectionedViewModelProtocol {
    var state: EventsListSectionedState

    var navigateEventDetails: NavigationFuncWithID
    var displaySlideMenu: NavigationFunc
    var displaySlideFilters: NavigationFunc
    var displayEmptyList: NavigationFunc
    var navigateAddEvent: NavigationFunc


    init() {
        self.state = EventsListSectionedState.getInitialState()
    }
    
    
    func fetchData(page: Int, overwrite: Bool) -> Promise<Void> {
        let filters = self.state.filters
        return EventService.fetchFeed(page, overwrite: overwrite,
                                      onlyFree: filters.onlyFree, popular: filters.sortBy == .ByPopular, startDate: filters.dateFrom, endDate: filters.dateTo, startTime: filters.time)
    }
    func getData() -> [Object] {
        return Array(EventService.getFeed())
    }
    func isLastPage() -> Bool {
        return EventService.isLastPageOfFeed
    }
    

    func onDelete(event: EventModel) {
        print(".EvntsManageVM.onDelete")
    }
    func onShowHide(event: EventModel) {
        print(".EvntsManageVM.onShowHide")
    }
    func onEdit(event: EventModel) {
        print(".EvntsManageVM.onEdit")
    }
    func onShowDeniedDetails(event: EventModel) {
        print(".EvntsManageVM.onShowDeniedDetails")
    }


    func onClickActionEmptyList() {
        self.navigateAddEvent?()
    }
    func onClickNavItemLeftEmptyList() {
        self.displaySlideMenu?()
    }
    func onClickNavItemRightEmptyList() {
        self.displaySlideFilters?()
    }
    func getScopeEmptyList() -> EventsEmptyListScope {
        return .MyEvents
    }
}


struct FavouritesViewModel: EventsListSectionedViewModelProtocol {
    var state: EventsListSectionedState

    var navigateEventDetails: NavigationFuncWithID
    var displaySlideMenu: NavigationFunc
    var displaySlideFilters: NavigationFunc
    var displayEmptyList: NavigationFunc
    var navigateFeed: NavigationFunc


    init() {
        self.state = EventsListSectionedState.getInitialState()
    }


    func fetchData(page: Int, overwrite: Bool) -> Promise<Void> {
        // TODO use filters
        // let filters = self.state.filters
        return EventService.fetchFavourite(page, overwrite: overwrite)
    }
    func getData() -> [Object] {
        return Array(EventService.getFavourite())
    }
    func isLastPage() -> Bool {
        return EventService.isLastPageOfFavourites
    }


    func onClickActionEmptyList() {
        self.navigateFeed?()
    }
    func onClickNavItemLeftEmptyList() {
        self.displaySlideMenu?()
    }
    func onClickNavItemRightEmptyList() {
        self.displaySlideFilters?()
    }
    func getScopeEmptyList() -> EventsEmptyListScope {
        return .Favourite
    }
}


struct FeedViewModel: EventsListSectionedViewModelProtocol {
    var state: EventsListSectionedState

    var navigateEventDetails: NavigationFuncWithID
    var displaySlideMenu: NavigationFunc
    var displaySlideFilters: NavigationFunc
    var displayEmptyList: NavigationFunc
    var navigateSelectInterests: NavigationFunc


    init() {
        self.state = EventsListSectionedState.getInitialState()
    }


    func fetchData(page: Int, overwrite: Bool) -> Promise<Void> {
        let filters = self.state.filters
        return EventService.fetchFeed(page, overwrite: overwrite,
                                      onlyFree: filters.onlyFree, popular: filters.sortBy == .ByPopular, startDate: filters.dateFrom, endDate: filters.dateTo, startTime: filters.time)
    }
    func getData() -> [Object] {
        return Array(EventService.getFeed())
    }
    func isLastPage() -> Bool {
        return EventService.isLastPageOfFeed
    }

    
    func onClickActionEmptyList() {
        self.navigateSelectInterests?()
    }
    func onClickNavItemLeftEmptyList() {
        self.displaySlideMenu?()
    }
    func onClickNavItemRightEmptyList() {
        self.displaySlideFilters?()
    }
    func getScopeEmptyList() -> EventsEmptyListScope {
        return .Feed
    }
}






// MARK: - States
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

    static func getInitialState() -> EventsListFiltersState {
        return EventsListFiltersState(search: nil, dateFrom: nil, dateTo: nil, time: nil, sortBy: .ByDate, onlyFree: false, convertCurrency: false, statusMap: [.Active: false, .Inactive: false, .OnReview: false, .Finished: false])
    }
}


struct EventsListState: EventsListStateProtocol {
    var items: [Object]
    var page: Int
    var isFetching: Bool

    var filters: EventsListFiltersState

    static func getInitialState() -> EventsListState {
        return EventsListState(items: [], page: 0, isFetching: false, filters: EventsListFiltersState.getInitialState())
    }
}
struct EventsListSectionedState: EventsListSectionedStateProtocol {
    var items: [Object] {
        didSet {
            self.updateSections()
        }
    }
    var page: Int
    var isFetching: Bool

    var filters: EventsListFiltersState
    
    var sections: [NSDate]
    var sectionsValue: [[EventModel]]


    func getSectionTitle(sectionIndex: Int) -> String {
        let date = self.sections[sectionIndex]
        return HappDateFormats.EventOnFeed.toString(date).uppercaseString
    }
    func getSectionsCount() -> Int {
        return self.sections.count
    }
    func getSectionEventsCount(sectionIndex: Int) -> Int {
        return self.sectionsValue[sectionIndex].count
    }
    func getSectionEvent(indexPath: NSIndexPath) -> EventModel {
        return self.sectionsValue[indexPath.section][indexPath.row]
    }


    static func getInitialState() -> EventsListSectionedState {
        return EventsListSectionedState(items: [], page: 0, isFetching: false, filters: EventsListFiltersState.getInitialState(), sections: [], sectionsValue: [])
    }


    private mutating func updateSections() {
        let items = self.items as! [EventModel]
        var result: [NSDate: [EventModel]] = [:]

        result = items.reduce(result, combine: { (var acc, event) in
            let eventDate = event.start_datetime!
            let existKey = acc.keys
                .filter { date in
                    let order = NSCalendar.currentCalendar().compareDate(date, toDate: eventDate, toUnitGranularity: .Day)
                    return order == .OrderedSame
                }
                .first
            
            if let key = existKey {
                var updValue = acc[key]!
                updValue.append(event)
                acc.updateValue(updValue, forKey: key)
            } else {
                acc.updateValue([event], forKey: eventDate)
            }
            return acc
        })


        self.sections = result.keys.sort { dateA, dateB in
            return NSCalendar.currentCalendar()
                .compareDate(dateA, toDate: dateB, toUnitGranularity: .Day) == .OrderedAscending
        }
        self.sectionsValue = self.sections.enumerate().map { index, key in
            return result[key]!
        }
    }
}






// MARK: Protocols
protocol EventsListStateProtocol: PaginatedDataStateProtocol {
    var filters: EventsListFiltersState { get set }
    
    static func getInitialState() -> Self
}

protocol EventsListSectionedStateProtocol: EventsListStateProtocol {
    var filters: EventsListFiltersState { get set }

    var sections: [NSDate] { get set }
    var sectionsValue: [[EventModel]] { get set }

    func getSectionTitle(sectionIndex: Int) -> String
    func getSectionsCount() -> Int
    func getSectionEventsCount(sectionIndex: Int) -> Int
    func getSectionEvent(indexPath: NSIndexPath) -> EventModel
    
    static func getInitialState() -> Self
}


protocol EventsEmptyListViewModelProtocol {
    func onClickNavItemLeftEmptyList()
    func onClickNavItemRightEmptyList()
    func onClickActionEmptyList()
    func getScopeEmptyList() -> EventsEmptyListScope
}

protocol EventsListViewModelProtocol: PaginatedDataViewModelProtocol {
    associatedtype StateType: EventsListStateProtocol
    var state: StateType { get set }
    
    var navigateEventDetails: NavigationFuncWithID { get set }
    var displaySlideMenu: NavigationFunc { get set }
    var displaySlideFilters: NavigationFunc { get set }
    var displayEmptyList: NavigationFunc { get set }

    func onClickEvent(event: EventModel)
    mutating func onChangeFilters(newState: EventsListFiltersState)
    func isLoadingFirstDataPage() -> Bool
}

protocol EventsListSectionedViewModelProtocol:
    EventsListViewModelProtocol, EventsEmptyListViewModelProtocol
{
    associatedtype StateType: EventsListSectionedStateProtocol
    var state: StateType { get set }
}


// MARK: Protocols Extensions
extension EventsListViewModelProtocol {
    mutating func onLoadNextDataPage(completion: ((Self.StateType) -> Void)) {
        self.state.isFetching = true

        let nextPage = self.state.page + 1
        self.fetchData(nextPage, overwrite: nextPage == 1)
            .then { _ -> Void in
                var updState = self.state
                updState.page = nextPage
                updState.items = self.getData()
                updState.isFetching = false
                completion(updState)
            }
            .error { err in
                var updState = self.state
                updState.items = self.getData()
                completion(updState)
            }
    }


    func onClickEvent(event: EventModel) {
        self.navigateEventDetails?(id: event.id)
    }
    mutating func onChangeFilters(newFiltersState: EventsListFiltersState) {
        self.state = StateType.getInitialState()
        self.state.filters = newFiltersState
    }
    func isLoadingFirstDataPage() -> Bool {
        return self.state.isFetching && self.state.page == 0
    }
}


/*
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

*/

