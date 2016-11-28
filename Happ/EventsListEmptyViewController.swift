
//
//  EventsListEmptyVViewController.swift
//  Happ
//
//  Created by MacBook Pro on 11/27/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit



class EventsListEmptyViewController: UIViewController {

    var viewModel: EventsListViewModel! {
        didSet {
            self.bindToViewModel()
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        self.extMakeNavBarWhite()
        self.initNavBarItems()
    }


    func viewModelDidUpdate() {
        let state = self.viewModel.state
        if  state.fetchingState == .FinishRequest &&
            !state.events.isEmpty {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }


    private func bindToViewModel() {
        let superDidUpdate = self.viewModel.didUpdate
        self.viewModel.didUpdate = { [weak self] _ in
            self?.viewModelDidUpdate()
            superDidUpdate?()
        }
    }

    private func initNavBarItems() {
        self.navigationItem.title = "Feed"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "nav-menu"), style: .Plain, target: self, action: #selector(handleClickMenuNavItem))
    }
    func handleClickMenuNavItem() {
        self.viewModel.displaySlideMenu?()
    }
}



