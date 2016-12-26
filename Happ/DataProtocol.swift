//
//  DataProtocol.swift
//  Happ
//
//  Created by MacBook Pro on 12/25/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import Foundation
import RealmSwift
import PromiseKit



protocol DataStateProtocol {
    associatedtype ItemType: Object
    var items: [ItemType] { get set }
    var isFetching: Bool { get set }
}

protocol DataViewModelProtocol {
    associatedtype StateType: DataStateProtocol
    var state: StateType { get set }

    mutating func onInitLoadingData(completion: ((Self.StateType) -> Void))
    func fetchData(overwrite flagValue: Bool) -> Promise<Void>
    func getData() -> [StateType.ItemType]

    func isInitLoadingData() -> Bool
}

extension DataViewModelProtocol {
    mutating func onInitLoadingData(completion: ((Self.StateType) -> Void)) {
        self.state.isFetching = true
        self.fetchData(overwrite: true)
            .then { _ -> Void in
                var updState = self.state
                updState.items = self.getData()
                updState.isFetching = false
                completion(updState)
        }
    }
    func isInitLoadingData() -> Bool {
        return self.state.isFetching && self.state.items.isEmpty
    }
}



