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



class EventsManageViewModel {

    var navigateEventDetails: NavigationFuncWithID
    var displaySlideMenu: NavigationFunc
    var displaySlideManageFilter: NavigationFunc


    // variables
    var events: [EventModel]

    init() {
        self.events = []
        
        // self.loadNextPage()
    }
    
    
    //MARK: - Events
    var didUpdate: (() -> Void)?


    //MARK: - Inputs
    
}
