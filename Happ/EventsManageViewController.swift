//
//  EventsManageViewController.swift
//  Happ
//
//  Created by MacBook Pro on 11/11/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit



class EventsManageViewController: UITableViewController {

    var viewModel: EventsManageViewModel! {
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
        self.tableView.registerNib(UINib(nibName: EventManageTableCell.nibName, bundle: nil), forCellReuseIdentifier: "cell")
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
        let cell = self.tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! EventManageTableCell
        let event = self.viewModel.getEventAt(indexPath)
        var cellInflator: EventManageTableCellInflator

        // set cell data
        cell.labelTitle.text = event.title
        if let interest = event.interests.first {
            cell.labelInterest.text = interest.title
        }
        cell.labelAddress.text = event.address
        cell.labelPrice.text = event.getPrice(.Range)
        cell.labelUpvoteCount.text = String(event.votes_num)
        cell.imageUpvoteIcon.image = event.getUpvoteIcon()
        cell.imageFavIcon.image = event.getFavIcon()
        if let url = event.images.first {
            cell.imageCover.hnk_setImageFromURL(url!)
        }
        if let color = event.color {
            cell.viewDetailsContainer.backgroundColor = UIColor(hexString: color)
        }

        // set cell styles
        switch event.getStatus() {
        case .Active:
            cellInflator = EventManageTableCellInflator(status: true, statusImageIcon: .Active, statistic: true, detailsDenied: false, detailsNormal: true, styleFilter: .None)
        case .Inactive:
            cellInflator = EventManageTableCellInflator(status: true, statusImageIcon: .Inactive, statistic: true, detailsDenied: false, detailsNormal: true, styleFilter: .None)
        case .OnReview:
            cellInflator = EventManageTableCellInflator(status: true, statusImageIcon: .OnReview, statistic: false, detailsDenied: false, detailsNormal: true, styleFilter: .None)
        case .Finished:
            cellInflator = EventManageTableCellInflator(status: true, statusImageIcon: nil, statistic: true, detailsDenied: false, detailsNormal: true, styleFilter: .BlackAndWhite)
        case .Rejected:
            cellInflator = EventManageTableCellInflator(status: true, statusImageIcon: .Rejected, statistic: false, detailsDenied: true, detailsNormal: false, styleFilter: .Red)
        }
        cellInflator.updateCell(cell)
        

        // set handlers
        cell.onClick = {[weak self] _ in
            self?.viewModel.onClickEvent(event)
        }
        cell.onEdit = {[weak self] _ in
            self?.viewModel.onEdit(event)
        }
        cell.onShowHide = {[weak self] _ in
            self?.viewModel.onShowHide(event)
        }
        cell.onDelete = {[weak self] _ in
            self?.viewModel.onDelete(event)
        }
        cell.onShowDeniedDetails = {[weak self] _ in
            self?.viewModel.onShowDeniedDetails(event)
        }

        return cell
    }
}



