//
//  EventsManageViewModel.swift
//  Happ
//
//  Created by MacBook Pro on 11/11/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import Foundation
import RealmSwift
import PromiseKit



class EventsManageViewModel: EventsListViewModel { // TODO remove it

    // TODO uncomment
    // var navigateEventDetails: NavigationFuncWithID
    // var displaySlideMenu: NavigationFunc
    var displaySlideManageFilter: NavigationFunc


    // variables
    // var events: [EventModel]

    init() {
        super.init(scope: .Favourite)
    }

    
    //MARK: - Events

    // TODO uncomment
    // var didUpdate: (() -> Void)?


    //MARK: - Inputs
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
}


