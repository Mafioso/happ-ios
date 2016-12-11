//
//  SelectInterestsViewModel.swift
//  Happ
//
//  Created by MacBook Pro on 10/31/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import Foundation
import PromiseKit
import RealmSwift

/*

class SetupUserInterestsViewModel: SelectUserInterestsViewModel {

    var navigateFeed: NavigationFunc

    func onSave() {
        var promise: Promise<Void>
        if self.selectMutlipleInterestState.isSelectedAll {
            promise = InterestService.setUserAllInterests()
        } else {
            let interestIDs = self.getSelectedInterests().map { $0.id }
            promise = InterestService.setUserInterests(interestIDs).then { _ -> Void in }
        }
        promise.then { _ -> Void in
            self.navigateFeed?()
        }
    }

    override init(navItemIcon: String, navigateNavItem: NavigationFunc) {
        super.init(navItemIcon: navItemIcon, navigateNavItem: navigateNavItem)
    }
}



class SelectUserInterestsViewModel: SelectUserInterestsProtocol {
 
    var navPopoverSelectSubinterests: NavigationFunc


    var dataState: PaginatedDataState {
        didSet {
            if dataState.isFetching { return }
            self.didUpdate?()
        }
    }
    var selectInterestState: SelectInterestState {
        didSet {
            self.didUpdate?()
        }
    }
    var selectMutlipleInterestState: SelectMultipleInterestsState {
        didSet {
            self.didUpdate?()
        }
    }
    var headerState: SelectInterestHeaderState {
        didSet {
            self.didUpdate?()
        }
    }
    var userInterests: [InterestModel] = []


    var didUpdate: UpdateHandlerFunc


    init(navItemIcon: String, navigateNavItem: NavigationFunc) {
        self.dataState = PaginatedDataState(page: 0, items: [], isFetching: false)
        self.selectMutlipleInterestState = SelectMultipleInterestsState(isSelectedAll: false)
        self.selectInterestState = SelectInterestState(selected: [:], opened: nil)
        self.headerState = SelectInterestHeaderState(navItemIcon: navItemIcon, navigateNavItem: navigateNavItem, isHeaderVisible: true, isAllowsMultipleSelection: true)
    }
    
}


class SelectEventInterestViewModel: SelectInterestProtocol {
    
    var navPopoverSelectSubinterests: NavigationFunc

    
    var headerState: SelectInterestHeaderState {
        didSet {
            self.didUpdate?()
        }
    }
    var dataState: PaginatedDataState {
        didSet {
            if dataState.isFetching { return }
            self.didUpdate?()
        }
    }
    var selectInterestState: SelectInterestState {
        didSet {
            self.didUpdate?()
        }
    }
    var title: String


    var didUpdate: UpdateHandlerFunc
    var didSelectInterest: ((interest: InterestModel) -> ())?
    
    
    init(title: String, navItemIcon: String, navigateNavItem: NavigationFunc) {
        self.dataState = PaginatedDataState(page: 0, items: [], isFetching: false)
        self.selectInterestState = SelectInterestState(selected: [:], opened: nil)
        self.headerState = SelectInterestHeaderState(navItemIcon: navItemIcon, navigateNavItem: navigateNavItem, isHeaderVisible: true, isAllowsMultipleSelection: false)

        self.title = title
    }

    func onSave() {
        if let selected = self.getSelectedInterests().first {
            self.didSelectInterest?(interest: selected)
        }
    }
    func getTitle() -> String {
        return self.title
    }
}


*/




struct SelectInterestState: SelectInterestStateProtocol {
    var items: [Object]
    var page: Int
    var isFetching: Bool

    var selected: [InterestModel : [InterestModel]]
    var opened: InterestModel?
}

struct SelectInterestViewModel: SelectInterestViewModelProtocol {
    
    var state: SelectInterestState
    var isHeaderVisible: Bool = true
    var navItem: NavItemType

    var navPopoverSelectSubinterests: NavigationFunc
    var navigateNavItem: NavigationFunc

    func onSave() {
        
    }
}




struct SelectUserInterestsState: SelectUserInterestsStateProtocol {
    var items: [Object]
    var page: Int
    var isFetching: Bool
    
    var selected: [InterestModel : [InterestModel]]
    var opened: InterestModel?
    var isSelectedAll: Bool

    var userInterests: [InterestModel]
}

struct SelectUserInterestsViewModel: SelectUserInterestsViewModelProtocol {

    typealias StateType = SelectUserInterestsState
    var state: SelectUserInterestsState
    var title: String
    var isHeaderVisible: Bool = true
    var navItem: NavItemType

    var navPopoverSelectSubinterests: NavigationFunc
    var navigateNavItem: NavigationFunc


    init(navItem: NavItemType) {
        let cityName = ProfileService.getUserCity().name
        self.title = cityName
        self.navItem = navItem
        self.state = SelectUserInterestsState(items: [], page: 0, isFetching: false, selected: [:], opened: nil, isSelectedAll: false, userInterests: [])
    }
}







enum NavItemType {
    case Back
    case Menu
    
    func getIcon() -> UIImage {
        switch self {
        case .Back:
            return UIImage(named: "nav-back-gray")!
        case .Menu:
            return UIImage(named: "nav-menu-gray")!
        }
    }
    func getIconSecond() -> UIImage {
        switch self {
        case .Back:
            return UIImage(named: "nav-back")!
        case .Menu:
            return UIImage(named: "nav-menu")!
        }
    }
}

enum SelectInterestSelectionTypes {
    case NonSelected
    case SelectedSome(numberOfSelected: Int, count: Int)
    case SelectedAll
}


// MARK: STATEs
protocol SelectInterestStateProtocol: PaginatedDataStateProtocol {
    var selected: [InterestModel: [InterestModel]] { get set }
    var opened: InterestModel? { get set }
}

protocol SelectMultipleInterestsStateProtocol: SelectInterestStateProtocol {
    var isSelectedAll: Bool { get set }
}

protocol SelectUserInterestsStateProtocol: SelectMultipleInterestsStateProtocol {
    var userInterests: [InterestModel] { get set }
}



// MARK: VIEW MODELs
protocol SelectInterestViewModelProtocol: PaginatedDataViewModelProtocol {
    associatedtype StateType: SelectInterestStateProtocol
    var state: StateType { get set }

    //MARK: - Inputs
    func onSave()
    mutating func onScroll(offset: Int)
    mutating func willSelect()
    mutating func onSelectInterest(interest: InterestModel)
    mutating func onSelectSubinterest(subinterest: InterestModel)
    mutating func onOpenSubinterests(for interest: InterestModel)
    mutating func onCloseSubinterests()
    func getSelectionType(interest: InterestModel) -> SelectInterestSelectionTypes
    func getSelectedInterests() -> [InterestModel]
    func isInterestSelected(interest: InterestModel) -> Bool
    func isSubinterestSelected(subinterest: InterestModel) -> Bool

    var isHeaderVisible: Bool { get set }
    var navItem: NavItemType { get set }
    var navigateNavItem: NavigationFunc { get set }
    var navPopoverSelectSubinterests: NavigationFunc { get set }
    
}

protocol SelectMultipleInterestsViewModelProtocol: SelectInterestViewModelProtocol {
    associatedtype StateType: SelectMultipleInterestsStateProtocol

    var title: String { get set }

    mutating func setSelectedInterests(interests: [InterestModel])
    mutating func onSelectAll()
}

protocol SelectUserInterestsViewModelProtocol: SelectMultipleInterestsViewModelProtocol {
    associatedtype StateType: SelectUserInterestsStateProtocol
    func fetchAllUserInterests(page: Int) -> Promise<Void>
    func getAllUserInterests() -> [InterestModel]
    func updateSelectedInterests(originState: Self.StateType) -> Self.StateType
}




//  MARK: VIEW MODELs extension
extension SelectMultipleInterestsViewModelProtocol where Self: PaginatedDataViewModelProtocol, Self: SelectUserInterestsViewModelProtocol {

    // 1. clean interests in DB
    // 2. fetch ALL PAGES of User Interests 
    // 3. get from DB and store in `userInterests`
    // 4. start fetching Interests by PAGES
    // 5. update `selected` with user interests

    mutating func onLoadFirstDataPage(completion: ((Self.StateType) -> Void)) {
        if self.state.page == 0 {
            self.fetchAllUserInterests()
                .then { _ -> Void in
                    let userInterests = self.getAllUserInterests()
                    self.state.userInterests = userInterests
                    self.onLoadNextDataPage(completion)
                }
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
                // update with user's saved interests
                updState = self.updateSelectedInterests(updState)
                completion(updState)
        }
    }
    func fetchData(page: Int, overwrite: Bool) -> Promise<Void> {
        return InterestService.fetchAll(page, overwrite: false) // prevent from overwrite
    }
    func fetchAllUserInterests(page: Int = 1) -> Promise<Void> {
        return Promise { resolve, reject in
            InterestService.fetchUserInterests(page, overwrite: page == 1)
                .then { _ -> Void in
                    if InterestService.isLastPage {
                        resolve()
                    } else {
                        self.fetchAllUserInterests(page + 1)
                            .then { resolve() }
                    }
                }
                .error { err in
                    reject(err)
                }
        }
    }
    func getAllUserInterests() -> [InterestModel] {
        return Array(InterestService.getAllStored())
    }
    func updateSelectedInterests(originState: Self.StateType) -> Self.StateType {
        // add only subinterest which not be added when parent didn't exists
        var updSelected = originState.selected
        let interests = originState.userInterests

        let newParents = interests
            .filter { $0.parent_id != nil }
            .map { InterestService.getParentOf($0) }
            .filter { $0 != nil && updSelected[$0!] == nil }
            .map { $0! }

        newParents.forEach { parent in
            let newSubinterests = InterestService
                .getSubinterestsOf(parent)
                .filter { interests.indexOf($0) != nil }
            updSelected.updateValue(newSubinterests, forKey: parent)
        }

        var updState = originState
        updState.selected = updSelected
        return updState
    }


    func onSave() {
        if self.state.isSelectedAll {
            InterestService.setUserAllInterests()
        } else {
            let interestIDs = self.getSelectedInterests().map { $0.id }
            InterestService.setUserInterests(interestIDs).then { _ -> Void in }
        }
    }
}

extension SelectMultipleInterestsViewModelProtocol where Self: PaginatedDataViewModelProtocol {

    mutating func onSelectAll() {
        self.state.isSelectedAll = !self.state.isSelectedAll
    }


    mutating func willSelect() {
        if self.state.isSelectedAll {
            self.state.isSelectedAll = false
        }
    }
    func getSelectionType(interest: InterestModel) -> SelectInterestSelectionTypes {
        if self.state.isSelectedAll {
            return .SelectedAll

        } else if let selectedSubinterests = self.state.selected[interest] {
            if  selectedSubinterests.isEmpty ||
                selectedSubinterests.count == interest.children.count {
                return .SelectedAll

            } else {
                return .SelectedSome(
                    numberOfSelected: selectedSubinterests.count,
                    count: interest.children.count)
            }

        } else {
            return .NonSelected
        }
    }

    mutating func setSelectedInterests(interests: [InterestModel]) {
        var updSelected: [InterestModel: [InterestModel]] = [:]

        interests.forEach { item in
            if item.parent_id == nil {
                updSelected.updateValue([], forKey: item)
                
            } else if let parent = InterestService.getParentOf(item) {
                if var prevValue = updSelected[parent] {
                    prevValue.append(item)
                    updSelected.updateValue(prevValue, forKey: parent)
                } else {
                    updSelected.updateValue([item], forKey: parent)
                }
            }
        }

        self.state.selected = updSelected
    }
}



extension SelectInterestViewModelProtocol where Self: PaginatedDataViewModelProtocol {
    func isLastPage() -> Bool {
        return InterestService.isLastPage
    }
    func getData() -> [Object] {
        return Array(InterestService.getAllStored().filter("parent_id == nil"))
    }
    func fetchData(page: Int, overwrite: Bool) -> Promise<Void> {
        return InterestService.fetchAll(page, overwrite: overwrite)
    }


    mutating func onScroll(offset: Int) {
        let isNowHeaderVisible = offset < 138
        self.isHeaderVisible = isNowHeaderVisible
    }

    mutating func willSelect() {
        self.state.selected = [:]
    }
    mutating func onSelectInterest(interest: InterestModel) {
        self.willSelect()

        var updSelected = self.state.selected

        let isSelected = self.isInterestSelected(interest)
        if isSelected {
            updSelected.removeValueForKey(interest)
        } else {
            updSelected.updateValue([], forKey: interest)
        }

        self.state.selected = updSelected
    }
    mutating func onSelectSubinterest(subinterest: InterestModel) {
        guard let interest = InterestService.getParentOf(subinterest) else { return }
        self.willSelect()

        var updSelected = self.state.selected

        if var selectedSubinterests = updSelected[interest] {
            if let indexOfAlreadySelected = selectedSubinterests.indexOf(subinterest) {
                selectedSubinterests.removeAtIndex(indexOfAlreadySelected)
            } else {
                selectedSubinterests.append(subinterest)
            }
            updSelected.updateValue(selectedSubinterests, forKey: interest)

        } else {
            updSelected[interest] = [subinterest]
        }

        self.state.selected = updSelected
    }

    mutating func onOpenSubinterests(for interest: InterestModel) {
        self.state.opened = interest
    }
    mutating func onCloseSubinterests() {
        self.state.opened = nil
    }

    func getSelectionType(interest: InterestModel) -> SelectInterestSelectionTypes {
        if let selectedSubinterests = self.state.selected[interest] {
            if  selectedSubinterests.isEmpty ||
                selectedSubinterests.count == interest.children.count {
                return .SelectedAll
            } else {
                return .SelectedSome(
                    numberOfSelected: selectedSubinterests.count,
                    count: interest.children.count)
            }
        } else {
            return .NonSelected
        }
    }
    func getSelectedInterests() -> [InterestModel] {
        return self.state.selected
            .map { (key, value) in return (value.isEmpty) ? [key] : value }
            .flatMap { $0 }
    }

    func isSubinterestSelected(subinterest: InterestModel) -> Bool {
        if let interest = InterestService.getParentOf(subinterest) {
            return self.state.selected[interest]?.indexOf(subinterest) != nil
        } else {
            return false
        }
    }
    func isInterestSelected(interest: InterestModel) -> Bool {
        return self.state.selected.indexForKey(interest) != nil
    }

}



