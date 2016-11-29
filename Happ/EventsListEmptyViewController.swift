
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

    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var buttonAction: UIButton!
    
    @IBAction func clickedActionButton(sender: UIButton) {
        self.handleClickAction()
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        self.extMakeNavBarWhite()
        self.initNavBarItems()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        buttonAction.extMakeCircle()
    }


    func viewModelDidUpdate() {
        let state = self.viewModel.state
        if  state.fetchingState == .FinishRequest &&
            !state.events.isEmpty {
            self.navigationController?.popViewControllerAnimated(true)
        }
        
        buttonAction.titleLabel?.text = self.getActionTitle()
        buttonAction.imageView?.image = self.getActionIcon()
        labelDescription.text = self.getDescription()
    }


    private func getNavTitle() -> String {
        switch self.viewModel.state.scope {
        case .Favourite:
            return "Favourite"
        case .Feed:
            return "Feed"
        case .MyEvents:
            return "My Events"
        }
    }
    private func getDescription() -> String {
        switch self.viewModel.state.scope {
        case .Favourite:
            return "You don’t have any favourited event"
        case .Feed:
            return "There are no events for selected interests"
        case .MyEvents:
            return "You have not created any event yet"
        }
    }
    private func getActionTitle() -> String {
        switch self.viewModel.state.scope {
        case .Favourite:
            return "Find Awesome Events"
        case .Feed:
            return "Add More Interests"
        case .MyEvents:
            return "Add First Event"
        }
    }
    private func getActionIcon() -> UIImage {
        switch self.viewModel.state.scope {
        case .Favourite:
            return UIImage(named: "icon-star")!
        case .Feed:
            return UIImage(named: "icon-search")!
        case .MyEvents:
            return UIImage(named: "icon-add")!
        }
    }
    private func handleClickAction() {
        switch self.viewModel.state.scope {
        case .Favourite:
            self.viewModel.navigateFeed?()
        case .Feed:
            self.viewModel.navigateSelectInterests?()
        default:
            self.viewModel.navigateCreateEvent?()
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
        self.navigationItem.title = self.getNavTitle()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "nav-menu"), style: .Plain, target: self, action: #selector(handleClickMenuNavItem))
    }
    func handleClickMenuNavItem() {
        self.viewModel.displaySlideMenu?()
    }
}



