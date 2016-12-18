//
//  SelectCityViewModel.swift
//  Happ
//
//  Created by MacBook Pro on 10/15/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import Foundation
import PromiseKit
import RealmSwift


// MARK: - SelectCityOnSetupViewModel
struct SelectCityOnSetupState: SelectCityStateProtocol {
    var items: [Object]
    var page: Int
    var isFetching: Bool

    var selectedID: String?
    var search: String?
}

struct SelectCityOnSetupViewModel: SelectCityViewModelProtocol {
    var state: SelectCityOnSetupState {
        didSet {
            print(".[VM].update", state)
        }
    }

    var navigateBack: NavigationFunc
    
    init() {
        self.state = SelectCityOnSetupState(items: [], page: 0, isFetching: false, selectedID: nil, search: nil)
    }
}



// MARK: - MenuChangeUserCityViewModel
struct SelectCityOnMenuState: SelectCityStateProtocol {
    var items: [Object]
    var page: Int
    var isFetching: Bool
    
    var selectedID: String?
    var search: String?
}
struct SelectCityOnMenuViewModel: SelectCityViewModelProtocol {
    var state: SelectCityOnSetupState

    mutating func onLoadFirstDataPage(completion: ((SelectCityOnSetupState) -> Void)) {
        if self.state.page == 0 {
            // 1. delete previous cities except current
            let userCity = ProfileService.getUserCity()
            let exceptIDs = [userCity.id]
            CityService.deleteAllStored(exceptIDs)
            // 2. start fetching
            self.onLoadNextDataPage(completion)
        }
    }
    func fetchData(page: Int, overwrite: Bool) -> Promise<Void> {
        // prevent from overwriting
        return CityService.fetchCities(page, overwrite: false)
    }

    
    init() {
        let userCity = ProfileService.getUserCity()
        self.state = SelectCityOnSetupState(items: [], page: 0, isFetching: false, selectedID: userCity.id, search: nil)
    }
}








// MARK: - State Protocol
protocol SelectCityStateProtocol: PaginatedDataStateProtocol {
    var selectedID: String? { get set }
    var search: String? { get set }
}

// MARK: - ViewModel Protocol
protocol SelectCityViewModelProtocol: PaginatedDataViewModelProtocol {
    associatedtype StateType: SelectCityStateProtocol
    var state: StateType { get set }

    mutating func onSelectCity(city: CityModel)
    mutating func onChangeSearch(search: String?, completion: ((StateType) -> Void))
    func fetchCitiesByName() -> Promise<Void>
    func selectedCity() -> CityModel?
}



// MARK: - ViewModel extension
extension SelectCityViewModelProtocol {
    mutating func onSelectCity(city: CityModel) {
        self.state.selectedID = city.id
    }
    mutating func onChangeSearch(search: String?, completion: ((Self.StateType) -> Void)) {
        let searchValue = (search == "") ? nil : search

        var updState = self.state
        updState.search = searchValue

        if searchValue != nil {
            // filter local items using `search`
            let localItems = self.getData()
            updState.items = localItems

            // fetch from server by `search`
            self.fetchCitiesByName()
                .then { _ -> Void in
                    var updState = self.state
                    updState.items = self.getData()
                    completion(updState)
            }
        }

        self.state = updState
    }
    func fetchCitiesByName() -> Promise<Void> {
        let searchValue = self.state.search!
        return CityService.fetchCitiesByName(searchValue)
    }
    func selectedCity() -> CityModel? {
        guard let id = self.state.selectedID else { return nil }
        return CityService.getCity(id)
    }

    // extends PaginatedDataProtocol
    func isLastPage() -> Bool {
        return CityService.isLastPage
    }
    func fetchData(page: Int, overwrite: Bool) -> Promise<Void> {
        return CityService.fetchCities(page, overwrite: overwrite)
    }
    func getData() -> [Object] {
        var cities = CityService.getCities()
        if let search = self.state.search {
            cities = cities.filter("name CONTAINS[c] %@", search)
        }
        return Array(cities)
    }
    func willLoadNextDataPage() -> Bool {
        let isLastPage = self.state.page > 0 && self.isLastPage()
        let isSearchingNow = self.state.search != nil
        if isSearchingNow || isLastPage || self.state.isFetching {
            return false
        } else {
            return true
        }
    }
}




