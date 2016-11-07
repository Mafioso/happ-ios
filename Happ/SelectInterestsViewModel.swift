//
//  SelectInterestsViewModel.swift
//  Happ
//
//  Created by MacBook Pro on 10/31/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import Foundation


enum InterestSelectionTypes {
    case NonSelected
    case SelectedOne
    case SelectedAll
    case SelectedSome(numberOfSelected: Int, count: Int)
}


protocol SelectInterestsVMProtocol {
    func selectInterestsIsAllowsMultipleSelection() -> Bool
    func selectInterestsGetTitle() -> String
    func selectInterestsOnSave(scope: SelectInterestsScope, selectedInterests: [InterestModel]) -> Void
}
enum SelectInterestsScope {
    case EventManage
    case NextToSelectCity
    case MenuChangeInterests
    case NextToMenuChangeCity
}


class SelectInterestsViewModel {

    var scope: SelectInterestsScope
    var parentViewModel: SelectInterestsVMProtocol
    var isHeaderVisible: Bool

    var interests: [InterestModel] = []
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

        InterestService.fetchFromServer()
            .then { _ -> Void in
                self.interests = self.getInterests()

                print(".fetchInterests.done", self.interests.count, self.didUpdate)
                self.didUpdate?()
        }
    }



    //MARK: - Events
    var didUpdate: (() -> Void)?


    //MARK: - Inputs
    func onSelectAll() {
        self.selectedInterests = [:]
        self.interests.forEach { interest in
            self.selectedInterests.updateValue([], forKey: interest)
        }
        self.didUpdate?()
    }
    func onSave() {
        let selectedInterestsMap: [[InterestModel]] = self.selectedInterests
            .map { (key, value) in
                return (value.isEmpty) ? [key] : value
            }
        let selectedInterests: [InterestModel] = selectedInterestsMap.flatMap { $0 }

        print("..onSave", selectedInterests)
        self.parentViewModel.selectInterestsOnSave(self.scope, selectedInterests:  selectedInterests)
    }
    func onScroll(offset: Int) {
        let isNowHeaderVisible = offset < 138
        if self.isHeaderVisible != isNowHeaderVisible {
            self.isHeaderVisible = isNowHeaderVisible
            self.didUpdate?()
        }
    }
    func onSelectInterest(interest: InterestModel) {
        let isSelected = self.selectedInterests.keys.contains(interest)
        if !self.isAllowsMultipleSelection() { // clear all previous values
            self.selectedInterests = [:]
        }

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
        print("..onClose")
        self.longPressedInterest = nil
        self.didUpdate?()
    }


    func getInterestSelectionTypeFor(interest: InterestModel) -> InterestSelectionTypes {
        if let selectedSubinterests = self.selectedInterests[interest] {
            if selectedSubinterests.isEmpty {
                return .SelectedOne
            } else if selectedSubinterests.count == interest.children.count {
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
        return Array(InterestService.getAllStored())
    }
}


