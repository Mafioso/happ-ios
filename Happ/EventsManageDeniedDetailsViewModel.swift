//
//  EventsManageDeniedDetailsViewModel.swift
//  Happ
//
//  Created by Aleksei Pugachev on 1/6/17.
//  Copyright © 2017 Sattar Stamkulov. All rights reserved.
//

import Foundation
import PromiseKit
import RealmSwift

class EventsManageDeniedDetailsViewModel {
    
    var navigateBack: NavigationFunc
    var navigateEditEvent: NavigationFuncWithObject
    
    var event: EventModel?
    
    init(event: EventModel) {
        self.event = event
    }

}
