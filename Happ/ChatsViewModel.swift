//
//  EventsMapViewModel.swift
//  Happ
//
//  Created by MacBook Pro on 12/19/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import Foundation
import PromiseKit
import RealmSwift

struct ChatsState: PaginatedDataStateProtocol {
    var page: Int
    var items: [Object]
    var isFetching: Bool

    static func getInitialState() -> ChatsState {
        return ChatsState(page: 0, items: [], isFetching: false)
    }
}

struct ChatsViewModel: PaginatedDataViewModelProtocol {
    var state: ChatsState
    var manager = false

    var navigateAsk: NavigationFuncWithObject
    var navigateChat: NavigationFuncWithObject
    var navigateEvents: NavigationFunc
    var navigateEventCreate: NavigationFunc
    var displaySlideMenu: NavigationFunc
    var displaySlideFilters: NavigationFunc

    init() {
        self.state = ChatsState.getInitialState()
    }
    
    func isLastPage() -> Bool {
        return ChatService.isLastPage
    }
    
    func fetchData(page: Int, overwrite flagValue: Bool) -> Promise<Void> {
        return ChatService.fetchChats(page, overwrite: flagValue, manager: self.manager)
    }
    
    func getData() -> [Object] {
        return Array(ChatService.getChats())
    }
}
