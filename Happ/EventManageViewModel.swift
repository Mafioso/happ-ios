//
//  EventManageViewModel.swift
//  Happ
//
//  Created by MacBook Pro on 10/18/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import Foundation
import PromiseKit


class EventManageViewModel {

    var navigateBack: NavigationFunc
    var navigateNext: NavigationFunc
    var navigateSubmit: NavigationFunc

    var event: EventModel
    var isEditing: Bool


    init() {
        self.event = EventModel()
        self.isEditing = false
    }
    init(event: EventModel) {
        self.event = event
        self.isEditing = true
    }

}


extension EventManageViewModel: SelectInterestsVMProtocol {
    func selectInterestsIsAllowsMultipleSelection() -> Bool {
        return false
    }
    func selectInterestsGetTitle() -> String {
        return self.event.title
    }
    func selectInterestsOnSave(scope: SelectInterestsScope, selectedInterests: [InterestModel]) {
        // TODO
        // self.event.interests = selectedInterests
    }
}
