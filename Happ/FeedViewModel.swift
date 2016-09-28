//
//  FeedViewModel.swift
//  Happ
//
//  Created by MacBook Pro on 9/19/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import Foundation
import PromiseKit



class FeedViewModel {

    var events: [EventModel] = []
    var sort: EventSortType = .ByDate

    var navigateEventDetails: NavigationFuncWithID
    var displaySlideMenu: NavigationFunc


    init() {
        // get from local DB
        //self.events = self.getFeed()

        // update from Server
        EventService.fetchFromServer()
            .then { _ -> Void in
                self.events = self.getFeed()
                self.didUpdate?()
            }
    }


    //MARK: - Events
    var didUpdate: (() -> Void)?
    

    //MARK: - Inputs
    func onClickLike(event: EventModel) {
        print(".FeedViewModel.inputs.clickedLikeOnEvent", event.id)
    }
    func onClickEvent(event: EventModel) {
        self.navigateEventDetails!(id: event.id)
    }
    func onSearchUpdate(searchText: String?) {
        if searchText == nil {
            self.events = self.getFeed()
        } else {
            self.events = self.getBySearch(searchText!)
        }
        self.didUpdate?()
    }
    func onChangeSort(sort: EventSortType) {
        self.sort = sort
        self.didUpdate?()
    }


    private func getFeed() -> [EventModel] {
        return Array(EventService.getStoredEvents(self.sort))
    }
    private func getBySearch(text: String) -> [EventModel] {
        // TODO: send search request to Server
        return Array(EventService.getStoredEvents(text, sort: self.sort))
    }
    
}



