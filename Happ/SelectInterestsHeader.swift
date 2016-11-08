//
//  SelectInterestsHeader.swift
//  Happ
//
//  Created by MacBook Pro on 11/1/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit

class SelectInterestsHeader: UICollectionReusableView {

    var viewModel: SelectInterestsViewModel! {
        didSet {
            self.bindToViewModel()
        }
    }


    // outlets
    @IBOutlet weak var viewForMultipleSelection: UIView!
    @IBOutlet weak var viewForSingleSelection: UIView!
    @IBOutlet weak var labelForName: UILabel!
    @IBOutlet weak var buttonNavItem: UIButton!
    @IBOutlet weak var buttonSelectAll: UIButton!


    // actions
    @IBAction func clickedSelectAll(sender: UIButton) {
        self.viewModel.onSelectAll()
    }
    @IBAction func clickedNavItem(sender: UIButton) {
        self.viewModel.onClickNavItem()
    }

    

    func viewModelDidUpdate() {
        // init
        if self.viewModel.isAllowsMultipleSelection() {
            self.viewForMultipleSelection.hidden = false
            self.viewForSingleSelection.hidden = true
            self.labelForName.text = self.viewModel.getTitle()
        } else {
            self.viewForMultipleSelection.hidden = true
            self.viewForSingleSelection.hidden = false
        }
        self.initNavItems()
        

        // update
        if self.viewModel.scope == .MenuChangeInterests {
            self.buttonNavItem.hidden = !self.viewModel.isHeaderVisible
        } else {
            self.buttonNavItem.hidden = true
        }
    }

    private func bindToViewModel() {
        let superDidUpdate: (() -> ())? = self.viewModel.didUpdate
        self.viewModel.didUpdate = { [weak self] _ in
            superDidUpdate?()

            self?.viewModelDidUpdate()
        }
    }


    private func initNavItems() {
        switch self.viewModel.scope {
        case .MenuChangeInterests:
            self.buttonNavItem.setImage(UIImage(named: "nav-menu-gray"), forState: .Normal)
        case .EventManage:
            self.buttonNavItem.setImage(UIImage(named: "nav-back-gray"), forState: .Normal)
        default:
            break
        }
    }
}


