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
    
    // actions

    // variables
    var tableView: UITableView!


    override func viewDidLoad() {
        super.viewDidLoad()


        self.displayNavigationBar()

        self.tableView.registerNib(UINib(nibName: EventTableCell.nibName, bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.estimatedRowHeight = 265
        self.tableView.rowHeight = UITableViewAutomaticDimension

        self.viewModelDidUpdate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == segueEmbeddedTableID {
            let destController = segue.destinationViewController as! UITableViewController
            self.tableView = destController.tableView
        }
    }


    private func bindToViewModel() {
        self.viewModel.didUpdate = { [weak self] _ in
            self?.viewModelDidUpdate()
        }
    }

    func viewModelDidUpdate() {
        self.tableView.reloadData()
    }


    // MARK: UITableViewDataSource

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let eventsCount = self.viewModel.events.count
        print(".FeedViewController.numberOfRow", eventsCount)
        return eventsCount
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! EventTableCell

        // configure cell
        let event = self.viewModel.events[indexPath.row]
        cell.setup(event)
        cell.onClickLikeButton = self.viewModel.clickedLikeOnEvent
        
        return cell
    }


    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let event = self.viewModel.events[indexPath.row]
        self.viewModel.clickedOnEvent(event)
    }

}



extension FeedViewController {
    
    private func displayNavigationBar() {
        self.navigationController?.navigationBar.backgroundColor = UIColor.whiteColor()

        let menuButton = UIBarButtonItem(image: UIImage(named: "menu-tab"), style: .Plain, target: self, action: #selector(FeedViewController.handleClickOnMenu))
        let filterButton = UIBarButtonItem(title: "Right", style: .Plain, target: self, action: nil)
        
        self.navigationItem.leftBarButtonItem = menuButton
        self.navigationItem.rightBarButtonItem = filterButton
    }

    func handleClickOnMenu() {
        self.viewModel.displaySlideMenu!()
    }
}




