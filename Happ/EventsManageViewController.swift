//
//  EventsManageViewController.swift
//  Happ
//
//  Created by MacBook Pro on 11/11/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit



class EventsManageViewController: UITableViewController {

    var viewModel: EventsListViewModel! {
        didSet {
            self.bindToViewModel()
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        self.initTableView()
        self.initNavBarItems()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.extMakeNavBarWhite()
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.extMakeNavBarVisible()
    }


    func initTableView() {
        self.tableView.registerNib(UINib(nibName: EventCompactTableCell.nibName, bundle: nil), forCellReuseIdentifier: "cell")
        self.tableView.rowHeight = CGFloat(125)
    }

    func viewModelDidUpdate() {
        self.tableView.reloadData()
    }

    private func bindToViewModel() {
        self.viewModel.didUpdate = { [weak self] _ in
            self?.viewModelDidUpdate()
        }
    }

    private func initNavBarItems() {
        self.navigationItem.title = "My Events"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "nav-menu"), style: .Plain, target: self, action: #selector(handleClickMenuNavItem))
    }
    func handleClickMenuNavItem() {
        self.viewModel.displaySlideMenu?()
    }



    // data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("...events", self.viewModel.getEventsCount())
        return self.viewModel.getEventsCount()
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! EventCompactTableCell

        // configure cell
        let event = self.viewModel.getEventAt(indexPath)
        
        cell.labelTitle.text = event.title
        if let interest = event.interests.first {
            cell.labelInterest.text = interest.title
        }
        if let url = event.images.first {
            cell.imageCover.hnk_setImageFromURL(url!)
        }

        switch event.getStatus() {
        case .Active:
            //cell.
            break
        default:
            break
        }
        
        
        return cell
    }
}



