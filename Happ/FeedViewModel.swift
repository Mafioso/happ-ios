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


    init() {
        EventService.fetchFromServer()
            .then { _ -> Void in
                EventService.getEvents().forEach({ model in
                    print(".event", model)
                })
            }
    }


    //MARK: - Events
    var didUpdate: (() -> Void)?
    
    
    //MARK: - Inputs
   
    
}
