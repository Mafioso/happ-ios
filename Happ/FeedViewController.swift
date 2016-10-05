//
//  FeedCollectionViewController.swift
//  Happ
//
//  Created by MacBook Pro on 9/19/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit
import Foundation


private let reuseIdentifier = "Cell"
private let segueEmbeddedTableID = "embeddedTable"



class FeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {


    var viewModel: FeedViewModel! {
        didSet {
            self.bindToViewModel()
        }
    }

    
    // outlets
    @IBOutlet weak var tableView: UITableView!



    override func viewDidLoad() {
        super.viewDidLoad()

        self.initNavigationBarItems()
        self.initTableView()

        self.viewModelDidUpdate()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.extMakeNavBarWhite()
    }


    private func bindToViewModel() {
        self.viewModel.didUpdate = { [weak self] _ in
            self?.viewModelDidUpdate()
        }
    }

    func viewModelDidUpdate() {
        self.tableView.reloadData()
    }


    private func initTableView() {
        self.tableView.dataSource = self
        self.tableView.delegate = self

        self.tableView.registerNib(UINib(nibName: EventTableCell.nibName, bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        self.tableView.estimatedRowHeight = 265
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }


    // MARK: UITableViewDataSource

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let eventsCount = self.viewModel.getEventsCount()
        print(".FeedViewController.numberOfRow", eventsCount)
        return eventsCount
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! EventTableCell

        // configure cell
        let event = self.viewModel.getEventAt(indexPath)
        cell.setup(event)
        cell.onClickLikeButton = self.viewModel.onClickLike

        // paginating
        if indexPath.row == self.viewModel.getEventsCount() - 1 {
            self.viewModel.loadNextPage()
        }

        return cell
    }


    // MARK: UITableViewDelegate

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let event = self.viewModel.getEventAt(indexPath)
        self.viewModel.onClickEvent(event)
    }

}



extension FeedViewController {
    
    private func initNavigationBarItems() {
        let menuNavButton = UIBarButtonItem(image: UIImage(named: "burger-menu"), style: .Plain, target: self, action: #selector(FeedViewController.onClickMenuNavbutton))
        let filterNavitem = UIBarButtonItem(image: UIImage(named: "filter-menu"), style: .Plain, target: self, action: #selector(FeedViewController.onClickFiltersNavbutton))

        self.navigationItem.leftBarButtonItem = menuNavButton
        self.navigationItem.rightBarButtonItem = filterNavitem
    }

    func onClickMenuNavbutton() {
        self.viewModel.displaySlideMenu!()
    }

    func onClickFiltersNavbutton() {
        self.viewModel.displaySlideFeedFilters!()
    }
}






