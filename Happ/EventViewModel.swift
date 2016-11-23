//
//  EventModelView.swift
//  Happ
//
//  Created by MacBook Pro on 9/19/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import Foundation
import PromiseKit


class EventViewModel {

    var event: EventModel!

    var navigateBack: NavigationFunc
    var navigateEventDetailsMap: NavigationFuncWithID


    init() {
        
    }

    convenience init(event: EventModel) {
        self.init()
        self.event = event
    }

    convenience init(forID: String) {
        self.init()
        self.event = EventService.getByID(forID)

    }


    //MARK: - Events
    var didUpdate: (() -> Void)?
    var displayMoreActionList: (() -> Void)?


    //MARK: - Inputs
    func onLike() {
        let newValue = !self.event.is_upvoted

        // update local
        EventService.setLike(self.event.id, value: newValue)
        self.didUpdate?()

        // update server
        EventService
            .updateLike(self.event.id, value: newValue)
            .then { self.didUpdate?() }
    }
    func onFavourite() {
        let newValue = !self.event.is_in_favourites

        // update local
        EventService.setFavourite(self.event.id, value: newValue)
        self.didUpdate?()

        // update server
        EventService
            .updateFavourite(self.event.id, value: newValue)
            .then { self.didUpdate?() }
    }
    func onUnsubscribeFromInterest() {
        print(".EventViewModel.onClickUnsubscribeFromInterest", self.event.id)
    }
    func onClickDisplayMoreActions() {
        self.displayMoreActionList?()
    }
    func onClickOpenMap() {
        self.navigateEventDetailsMap?(id: self.event.id)
    }


}



