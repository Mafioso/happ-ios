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
    func onLike() {
        print(".EventViewModel.onClickLike", self.event.id,
              "\(self.event.is_upvoted) - \(self.event.is_in_favourites)")
        
        EventService
            .setLike(self.event.id, value: !self.event.is_upvoted)

            .then { _ -> Void in
                let _event = EventService.getByID(self.event.id)!
                print("\(_event.is_upvoted) - \(_event.is_in_favourites)")

                //self.didUpdate?()
        }
    }
    func onFavourite() {
        print(".EventViewModel.onClickFavourite", self.event.id)
        EventService
            .setFavourite(self.event.id, value: !self.event.is_in_favourites)
            .then { _ in self.didUpdate?() }
    }
    func onUnsubscribeFromInterest() {
        print(".EventViewModel.onClickUnsubscribeFromInterest", self.event.id)
    }
    func onClickDisplayMoreActions() {
        self.displayMoreActionList?()
    }
    
    
}



