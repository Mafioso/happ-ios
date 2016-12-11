//
//  PaginatedDataProtocol.swift
//  Happ
//
//  Created by MacBook Pro on 12/5/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import Foundation
import RealmSwift
import PromiseKit



protocol PaginatedDataStateProtocol {
    var page: Int { get set }
    var items: [Object] { get set }
    var isFetching: Bool { get set }
}

protocol PaginatedDataViewModelProtocol {
    associatedtype StateType: PaginatedDataStateProtocol
    var state: StateType { get set }

    mutating func onLoadFirstDataPage(completion: ((Self.StateType) -> Void))
    mutating func onLoadNextDataPage(completion: ((Self.StateType) -> Void))
    func willLoadNextDataPage() -> Bool
    // should implement:
    func isLastPage() -> Bool
    func fetchData(page: Int, overwrite: Bool) -> Promise<Void>
    func getData() -> [Object]
}

extension PaginatedDataViewModelProtocol {
    mutating func onLoadFirstDataPage(completion: ((Self.StateType) -> Void)) {
        if self.state.page == 0 {
            self.onLoadNextDataPage(completion)
        }
    }
    mutating func onLoadNextDataPage(completion: ((Self.StateType) -> Void)) {
        self.state.isFetching = true

        let nextPage = self.state.page + 1
        self.fetchData(nextPage, overwrite: nextPage == 1)
            .then { _ -> Void in
                var updState = self.state
                updState.page = nextPage
                updState.items = self.getData()
                updState.isFetching = false
                completion(updState)
        }
    }
    func willLoadNextDataPage() -> Bool {
        let isLastPage = self.state.page > 0 && self.isLastPage()
        if isLastPage || self.state.isFetching {
            return false
        } else {
            return true
        }
    }
}



