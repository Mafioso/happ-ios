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



struct SelectCityOnSetupState: SelectCityStateProtocol {
    var items: [Object]
    var page: Int
    var isFetching: Bool

    var selectedID: String?
    var search: String?
}
struct SelectCityOnSetupViewModel: PaginatedDataViewModelProtocol, SelectCityViewModelProtocol {
    var state: SelectCityOnSetupState {
        didSet {
            print(".[VM].update", state)
        }
    }

    init() {
        self.state = SelectCityOnSetupState(items: [], page: 0, isFetching: false, selectedID: nil, search: nil)
    }
}


struct SetupUserCityViewModel {

    var selectedCity: CityModel?

    var navigateSelectCity: NavigationFunc
    var navigateBack: NavigationFunc
    var navigateSelectInterests: NavigationFunc


    init() {
    }

    //MARK: - Inputs
    func onClickSelectCity() {
        self.navigateSelectCity?()
    }
    func onClickSave() {
        CityService
            .setUserCity(self.selectedCity!.id)
            .then { _ in self.navigateSelectInterests?() }
    }
    mutating func onSelectCity(city: CityModel) {
        self.selectedCity = city
        self.navigateBack?()
    }
}


/*

class MenuChangeUserCityViewModel: SelectCityProtocol {
    var dataState: PaginatedDataState {
        didSet {
            if dataState.isFetching { return }
            self.didUpdate?()
        }
    }
    var selectCityState: SelectCityState {
        didSet {
            if oldValue.search != selectCityState.search { return }
            self.didChangeCity?()
        }
    }
    var didUpdate: UpdateHandlerFunc
    var didChangeCity: UpdateHandlerFunc

    
    init() {
        let userCity = ProfileService.getUserCity()

        self.dataState = PaginatedDataState(page: 0, items: [], isFetching: false)
        self.selectCityState = SelectCityState(selected: userCity, search: nil)
    }
}
extension SelectCityProtocol where Self: MenuChangeUserCityViewModel {
    mutating func onLoadFirstDataPage() {
        if self.dataState.page == 0 {
            // delete all except UserCity
            let userCity = ProfileService.getUserCity()
            let exceptIDs = [userCity.id]
            CityService.deleteCitiesLocal(exceptIDs)
            self.onLoadNextDataPage()
        }
    }
    func fetchData(page: Int, overwrite: Bool) -> Promise<Void> {
        // prevent from overwriting
        return CityService.fetchCities(page, overwrite: false)
    }
}

*/



protocol SelectCityStateProtocol: PaginatedDataStateProtocol {
    var selectedID: String? { get set }
    var search: String? { get set }
}


protocol SelectCityViewModelProtocol {
    associatedtype SelectCityStateType: SelectCityStateProtocol
    var state: SelectCityStateType { get set }

    mutating func onSelectCity(city: CityModel)
    mutating func onChangeSearch(search: String?)
    func fetchCitiesByName() -> Promise<Void>
    func selectedCity() -> CityModel?
}

extension SelectCityViewModelProtocol where Self: PaginatedDataViewModelProtocol {
    mutating func onSelectCity(city: CityModel) {
        self.state.selectedID = city.id
    }
    mutating func onChangeSearch(search: String?) {
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
                    let serverItems = self.getData()
                    self.state.items = serverItems
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




