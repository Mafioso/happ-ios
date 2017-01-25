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

    enum Info: Int {
        case Site = 0
        case Email = 1
        case Phone = 2
        
        func value(event: EventModel) -> String? {
            switch self {
            case .Site:
                return event.web_site
            case .Email:
                return event.email
            case .Phone:
                return event.phones.first
            }
        }
        
        func icon() -> String {
            switch self {
            case .Site:
                return "icon-web"
            case .Email:
                return "icon-email"
            case .Phone:
                return "icon-phone"
            }
        }
    }

    
    var event: EventModel!

    var navigateBack: NavigationFunc
    var navigateEventDetailsMap: NavigationFuncWithID
    var openWebPage: NavigationFuncWithURL


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


    func event_info(type: Info) -> String? {
        return type.value(self.event)
    }
    func event_info_types() -> [EventViewModel.Info] {
        return [Info.Site, Info.Email, Info.Phone].filter {$0.value(event) != nil}
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



