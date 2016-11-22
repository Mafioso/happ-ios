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


class EventsExploreViewModel {

    var navigateEventDetails: NavigationFuncWithID
    var displaySlideMenu: NavigationFunc


    // variables
    var page: Int
    var events: [EventModel]

    init() {
        self.page = 0
        self.events = []
        
        self.loadNextPage()
    }


    //MARK: - Events
    var didUpdate: (() -> Void)?


    //MARK: - Inputs
    func loadNextPage() {
        if self.page != 0 && EventService.isLastPageOfExplore {
            return
        }
        self.page += 1
        self.fetchEvents()
    }
    func onClickEvent(event: EventModel) {
        self.navigateEventDetails?(id: event.id)
    }


    func getEvents() -> [EventModel] {
        return Array(EventService.getExplore())
    }
    private func fetchEvents() {
        EventService.fetchExplore(self.page)
            .then { _ -> Void in
                self.events = self.getEvents()
                print(".exploreVM.fetch.done", self.events.count)
                self.didUpdate?()
        }
    }
}


