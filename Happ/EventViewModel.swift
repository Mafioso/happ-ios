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
    func onClickLike() {
        print(".EventViewModel.inputs.onClickLike", self.event.id)
        EventService
            .setLike(self.event.id, value: !self.event.is_upvoted)
            .then { _ in self.didUpdate?() }
    }
    func onClickFavourite() {
        print(".EventViewModel.inputs.onClickFavourite", self.event.id)
        EventService
            .setFavourite(self.event.id, value: !self.event.is_in_favourites)
            .then { _ in self.didUpdate?() }
    }
    func onClickUnsubscribeFromInterest() {
        print(".EventViewModel.inputs.onClickUnsubscribeFromInterest", self.event.id)
    }
    func onClickDisplayMoreActions() {
        self.displayMoreActionList?()
    }
    
    
}



