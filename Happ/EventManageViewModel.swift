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
    //var navigateSelectInterest: ((SelectInterestProtocol, loadInMenu: Bool) -> NavigationFunc)?

    var event: EventModel
    var isEditing: Bool

    //MARK: - Events
    var didUpdate: (() -> Void)?

    //MARK: - Inputs
    func onSelectInterest(interest: InterestModel) {
        self.event.interests.append(interest)
        self.didUpdate?()
    }
    func onClickSelectInterest() {
        let title = self.event.title
        //let selectInterestViewModel = SelectEventInterestViewModel(title: title, navItemIcon: "nav-back-gray", navigateNavItem: self.navigateBack)
        //let navigateTo = self.navigateSelectInterest?(selectInterestViewModel, loadInMenu: false)
        //navigateTo!()
    }


    init() {
        self.event = EventModel()
        self.isEditing = false

    }
    convenience init(event: EventModel) {
        self.init()
        self.event = event
        self.isEditing = true
    }

    
    

}


