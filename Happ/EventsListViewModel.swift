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


// MARK: - ViewModels
struct EventsManageViewModel: EventsListSectionedViewModelProtocol {
    var state: EventsListSectionedState

    var navigateEventDetails: NavigationFuncWithID
    var navigateEventEdit: NavigationFuncWithObject
    var navigateEventDeniedDetails: NavigationFuncWithObject
    var navigateUpdate: NavigationFunc
    var displaySlideMenu: NavigationFunc
    var displaySlideFilters: NavigationFunc
    var displayEmptyList: NavigationFunc
    var navigateAddEvent: NavigationFunc

    init() {
        self.state = EventsListSectionedState.getInitialState()
    }
    

    func fetchData(page: Int, overwrite: Bool) -> Promise<Void> {
        let filters = self.state.filters
        return EventService.fetchMyEvents(page, overwrite: overwrite, startDate: filters.dateFrom, endDate: filters.dateTo, active: filters.statusMap![.Active]!, inactive: filters.statusMap![.Inactive]!, onreview: filters.statusMap![.OnReview]!, rejected: filters.statusMap![.Rejected]!, finished: filters.statusMap![.Finished]!)
    }
    func getData() -> [Object] {
        return Array(EventService.getStored())
    }
    func isLastPage() -> Bool {
        return EventService.isLastPageOfFeed
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
    var navigateEventEdit: NavigationFuncWithObject
    var navigateEventDeniedDetails: NavigationFuncWithObject
    var navigateUpdate: NavigationFunc
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
    var navigateEventEdit: NavigationFuncWithObject
    var navigateEventDeniedDetails: NavigationFuncWithObject
    var navigateUpdate: NavigationFunc
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
        return Array(EventService.getStored())
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





enum EventsListSortType {
    case ByDate
    case ByPopular
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
//    var convertCurrency: Bool
    // for scope: .MyEvents
    var statusMap: [EventModelStatusTypes: Bool]?

    static func getInitialState() -> EventsListFiltersState {
        return EventsListFiltersState(search: nil, dateFrom: nil, dateTo: nil, time: nil, sortBy: .ByDate, onlyFree: false,  statusMap: [.Active: true, .Inactive: true, .OnReview: true, .Rejected: true, .Finished: true])
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
    mutating func deleteSectionEvent(event: EventModel) {}
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
            let eventDate = event.datetimes.first?.start_time ?? NSDate()
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
    var navigateEventEdit: NavigationFuncWithObject { get set }
    var navigateEventDeniedDetails: NavigationFuncWithObject { get set }
    var navigateUpdate: NavigationFunc { get set }
    var displaySlideMenu: NavigationFunc { get set }
    var displaySlideFilters: NavigationFunc { get set }
    var displayEmptyList: NavigationFunc { get set }

    func onClickEvent(event: EventModel)
    func onEditEvent(event: EventModel)
    func onDeniedDetailsEvent(event: EventModel)
    func onCopyEvent(event: EventModel, onFinish: Bool -> Void)
    func onDeleteEvent(event: EventModel, onFinish: Bool -> Void)
    func onActivateEvent(event: EventModel, activated: Bool, onFinish: Bool -> Void)
    mutating func onChangeFilters(newState: EventsListFiltersState)
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
                switch err {
                case EventErrors.MutexWriteDenied:
                    //do nothing
                    break
                default:
                    var updState = self.state
                    updState.items = self.getData()
                    updState.isFetching = false
                    completion(updState)
                }
            }
    }

    func onClickEvent(event: EventModel) {
        self.navigateEventDetails?(id: event.id)
    }
    
    func onEditEvent(event: EventModel) {
        self.navigateEventEdit?(object: event)
    }
    
    func onDeniedDetailsEvent(event: EventModel) {
        self.navigateEventDeniedDetails?(object: event)
    }
    
    func onDeleteEvent(event: EventModel, onFinish: Bool -> Void) {
        EventService.removeEvent(event.id)
            .then { data -> Void in
                self.navigateUpdate?()
            }
            .error { error in
                onFinish(false)
        }
    }
    
    func onCopyEvent(event: EventModel, onFinish: Bool -> Void) {
        EventService.copyEvent(event.id)
            .then { data -> Void in
                self.navigateUpdate?()
            }
            .error { error in
                onFinish(false)
        }
    }
    
    func onActivateEvent(event: EventModel, activated: Bool = true, onFinish: Bool -> Void) {
        EventService.activateDeactivateEvent(!activated, id: event.id)
            .then { data -> Void in
                onFinish(true)
            }
            .error { error in
                onFinish(false)
        }
    }
    
    mutating func onChangeFilters(newFiltersState: EventsListFiltersState) {
        self.state = StateType.getInitialState()
        self.state.filters = newFiltersState
    }
}
