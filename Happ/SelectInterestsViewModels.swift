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




// MARK: - SelectEventInterest
struct SelectEventInterestState: SelectInterestStateProtocol {
    var items: [InterestModel]
    var isFetching: Bool
    var selected: [InterestModel : [InterestModel]]
    var opened: InterestModel?

    static func getInitialState() -> SelectEventInterestState {
        return SelectEventInterestState(items: [], isFetching: false, selected: [:], opened: nil)
    }
}
struct SelectEventInterestViewModel: SelectInterestViewModelProtocol {
    var state: SelectEventInterestState

    var isHeaderVisible: Bool = true
    var navItem: NavItemType = .Back

    var navPopoverSelectSubinterests: NavigationFunc
    var navigateNavItem: NavigationFunc
    var navigateAfterSave: NavigationFunc


    init() {
        self.state = SelectEventInterestState.getInitialState()
    }

    func onSave() {
        // do nothing
    }
    
    func getSelectedInterest() -> InterestModel? {
        return self.getSelectedInterests().first
    }
    
}



// MARK: - SelectUserInterests
struct SelectUserInterestsState: SelectUserInterestsStateProtocol {
    var items: [InterestModel]
    var isFetching: Bool

    var selected: [InterestModel : [InterestModel]]
    var opened: InterestModel?
    var isSelectedAll: Bool

    var userInterests: [InterestModel]
    
    static func getInitialState() -> SelectUserInterestsState {
        return SelectUserInterestsState(items: [], isFetching: false, selected: [:], opened: nil, isSelectedAll: false, userInterests: [])
    }
}

struct SelectUserInterestsViewModel: SelectUserInterestsViewModelProtocol {

    typealias StateType = SelectUserInterestsState
    var state: SelectUserInterestsState
    var title: String
    var isHeaderVisible: Bool = true
    var navItem: NavItemType

    var navPopoverSelectSubinterests: NavigationFunc
    var navigateNavItem: NavigationFunc
    var navigateAfterSave: NavigationFunc


    init(navItem: NavItemType) {
        let cityName = ProfileService.getUserCity().name
        self.title = cityName
        self.navItem = navItem
        self.state = SelectUserInterestsState.getInitialState()
    }

    func onSave() {
        var promise: Promise<Void>
        if self.state.isSelectedAll {
            promise = InterestService.setUserAllInterests()
        } else {
            let interestIDs = self.getSelectedInterests().map { $0.id }
            promise = InterestService.setUserInterests(interestIDs)
                .then { _ -> Void in }
        }
        promise.then { self.navigateAfterSave?() }
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
protocol SelectInterestStateProtocol {
    var items: [InterestModel] { get set }
    var isFetching: Bool { get set }
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
protocol SelectInterestViewModelProtocol {
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

    mutating func onInitLoadingData(completion: ((Self.StateType) -> Void))
    func fetchData(overwrite flagValue: Bool) -> Promise<Void>
    func getData() -> [InterestModel]

    var isHeaderVisible: Bool { get set }
    var navItem: NavItemType { get set }
    var navigateNavItem: NavigationFunc { get set }
    var navPopoverSelectSubinterests: NavigationFunc { get set }
    
}

protocol SelectMultipleInterestsViewModelProtocol: SelectInterestViewModelProtocol {
    associatedtype StateType: SelectMultipleInterestsStateProtocol

    var title: String { get set }

    mutating func makeSelectedInterests(interests: [InterestModel]) -> [InterestModel: [InterestModel]]
    mutating func onSelectAll()
}

protocol SelectUserInterestsViewModelProtocol: SelectMultipleInterestsViewModelProtocol {
    associatedtype StateType: SelectUserInterestsStateProtocol

    var navigateAfterSave: NavigationFunc { get set }
}




//  MARK: VIEW MODELs extension
extension SelectMultipleInterestsViewModelProtocol where Self: SelectUserInterestsViewModelProtocol {

    // 1. clean interests in DB
    // 2. fetch ALL PAGES of User Interests 
    // 3. get from DB and store in `userInterests`
    // 4. fetch ALL PAGES of Interests
    // 5. update `selected` with user interests

    mutating func onInitLoadingData(completion: ((Self.StateType) -> Void)) {
        var userInterests: [InterestModel] = []

        self.state.isFetching = true
        InterestService.fetchUserInterests(overwrite: true)
            .then { _ -> Void in
                userInterests = self.getData()
            }
            .then {
                return self.fetchData(overwrite: false)
            }
            .then { _ -> Void in
                let parentInterests = self.getData()
                let allInterestsCount = InterestService.getStored().count
                var updState = self.state
                updState.items = parentInterests
                updState.isFetching = false
                updState.userInterests = userInterests
                updState.selected = self.makeSelectedInterests(userInterests)
                updState.isSelectedAll = (allInterestsCount == userInterests.count)
                completion(updState)
            }
    }
}



extension SelectMultipleInterestsViewModelProtocol {

    mutating func onSelectAll() {
        self.state.isSelectedAll = !self.state.isSelectedAll
        self.state.selected = [:]
    }


    mutating func willSelect() {
        if self.state.isSelectedAll {
            self.state.isSelectedAll = false
            self.state.selected = [:]
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

    mutating func makeSelectedInterests(interests: [InterestModel]) -> [InterestModel: [InterestModel]] {
        var result: [InterestModel: [InterestModel]] = [:]

        interests.forEach { item in
            if item.parent_id == nil {
                result.updateValue([], forKey: item)

            } else if let parent = InterestService.getParentOf(item) {
                if var prevValue = result[parent] {
                    prevValue.append(item)
                    result.updateValue(prevValue, forKey: parent)
                } else {
                    result.updateValue([item], forKey: parent)
                }
            }
        }

        return result
    }
}



extension SelectInterestViewModelProtocol {
    mutating func onInitLoadingData(completion: ((Self.StateType) -> Void)) {
        self.state.isFetching = true
        self.fetchData(overwrite: false)
            .then { _ -> Void in
                var updState = self.state
                updState.items = self.getData()
                updState.isFetching = false
                completion(updState)
            }
    }
    func getData() -> [InterestModel] {
        return Array(InterestService.getStored().filter("parent_id == nil"))
    }
    func fetchData(overwrite flagValue: Bool) -> Promise<Void> {
        return InterestService.fetch(overwrite: flagValue)
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



