//
//  SelectInterestsViewModel.swift
//  Happ
//
//  Created by MacBook Pro on 10/31/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import Foundation
import PromiseKit


enum InterestSelectionTypes {
    case NonSelected
    case SelectedSome(numberOfSelected: Int, count: Int)
    case SelectedAll
}


protocol SelectInterestsVMProtocol {
    func selectInterestsIsAllowsMultipleSelection() -> Bool
    func selectInterestsGetTitle() -> String
    func selectInterestsOnSave(selectedInterests: [InterestModel]) -> Void
    func selectInterestsOnSaveAll() -> Void
}



enum SelectInterestsScope {
    case EventManage
    case Setup
    case MenuChangeInterests
    case NextToMenuChangeCity
}


class SelectInterestsViewModel {

    var scope: SelectInterestsScope
    var parentViewModel: SelectInterestsVMProtocol
    var isHeaderVisible: Bool
    var interestsPage: Int = 1

    var interests: [InterestModel] = []
    var isSelectedAll: Bool = false
    var longPressedInterest: InterestModel?
    var selectedInterests: [InterestModel: [InterestModel]] = [:]
    /*
     [Interest1: nil]    <- not selected
     [Interest1: []]     <- selected all SubInterests
     [Interest1: [SubInterest1, SubInterest2]]   <- selected some of SubInterests
     */

    
    var navigateBack: NavigationFunc
    var displaySlideMenu: NavigationFunc
    var navPopoverSelectSubinterests: NavigationFunc


    init(scope: SelectInterestsScope, parentViewModel: SelectInterestsVMProtocol) {
        self.scope = scope
        self.parentViewModel = parentViewModel
        self.isHeaderVisible = true

        if scope == .MenuChangeInterests {
            let userProfile = ProfileService.getUserProfile()
            let userInterests = Array(userProfile.interests)
            self.selectedInterests = InterestService.getGroupedByParents(userInterests)
        }

        self.fetchInterests() // load first page
    }



    //MARK: - Events
    var didUpdate: (() -> Void)?


    //MARK: - Inputs
    func onLoadNextPage() {
        if self.interestsPage > 1 && CityService.isLastPage {
            return
        }
        self.interestsPage += 1
        self.fetchInterests()
    }
    func onClickNavItem() {
        switch self.scope {
        case .MenuChangeInterests:
            self.displaySlideMenu?()
        case .EventManage:
            self.navigateBack?()
        default:
            break
        }
    }
    func onSelectAll() {
        self.isSelectedAll = !self.isSelectedAll
        self.selectedInterests = [:]
        self.didUpdate?()
    }
    func onSave() {
        if self.isSelectedAll {
            self.parentViewModel.selectInterestsOnSaveAll()
        } else {
            let value = self.selectedInterests
                            .map { (key, value) in return (value.isEmpty) ? [key] : value }
                            .flatMap { $0 }
            self.parentViewModel.selectInterestsOnSave(value)
        }
    }
    func onScroll(offset: Int) {
        let isNowHeaderVisible = offset < 138
        if self.isHeaderVisible != isNowHeaderVisible {
            self.isHeaderVisible = isNowHeaderVisible
            self.didUpdate?()
        }
    }
    func onSelectInterest(interest: InterestModel) {
        if !self.isAllowsMultipleSelection() { // clear all previous values
            self.selectedInterests = [:]
        }
        if self.isSelectedAll {
            self.isSelectedAll = false
            self.selectedInterests = [:]
        }

        let isSelected = self.selectedInterests.keys.contains(interest)
        if !isSelected {
            self.selectedInterests.updateValue([], forKey: interest)
        } else {
            self.selectedInterests.removeValueForKey(interest)
        }
        self.didUpdate?()
    }
    func onLongPressInterest(interest: InterestModel) {
        self.longPressedInterest = interest
        self.didUpdate?()
    }
    func onSelectSubinterest(subinterest: InterestModel) {
        if let interest = InterestService.getParentOf(subinterest) {
            if !self.isAllowsMultipleSelection() { // clear all previous values
                self.selectedInterests = [:]
            }
            if self.isSelectedAll {
                self.isSelectedAll = false
                self.selectedInterests = [:]
            }

            if var selectedSubinterests = self.selectedInterests[interest] {
                if let indexOfSubinterest = selectedSubinterests.indexOf(subinterest) {
                    selectedSubinterests.removeAtIndex(indexOfSubinterest)
                } else {
                    selectedSubinterests.append(subinterest)
                }
                self.selectedInterests.updateValue(selectedSubinterests, forKey: interest)
            } else {
                self.selectedInterests[interest] = [subinterest]
            }
            
            self.didUpdate?()
        }
    }
    func onClosePopoverSelectSubinterests() {
        self.longPressedInterest = nil
        self.didUpdate?()
    }


    func getInterestSelectionTypeFor(interest: InterestModel) -> InterestSelectionTypes {
        if self.isSelectedAll {
            return .SelectedAll
        } else if let selectedSubinterests = self.selectedInterests[interest] {
            if  selectedSubinterests.isEmpty
                || selectedSubinterests.count == interest.children.count {
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
    func isSubinterestSelected(subinterest: InterestModel) -> Bool {
        if let interest = InterestService.getParentOf(subinterest) {
            return self.selectedInterests[interest]?.indexOf(subinterest) != nil
        } else {
            return false
        }
    }


    func getTitle() -> String {
        return self.parentViewModel.selectInterestsGetTitle()
    }
    func isAllowsMultipleSelection() -> Bool {
        return self.parentViewModel.selectInterestsIsAllowsMultipleSelection()
    }
    private func getInterests() -> [InterestModel] {
        return Array(InterestService.getAllStored().filter("parent_id == nil"))
    }
    private func fetchInterests() -> Promise<Void> {
        return InterestService.fetchFromServer(self.interestsPage)
            .then { _ -> Void in
                self.interests = self.getInterests()
                self.didUpdate?()
        }
    }
}


