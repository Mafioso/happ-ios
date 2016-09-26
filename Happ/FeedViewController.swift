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

        print(".viewDidLoad")

        self.tableView.registerNib(UINib(nibName: EventTableCell.nibName, bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        tableView.estimatedRowHeight = 265
        tableView.rowHeight = UITableViewAutomaticDimension

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
        // Create the navigation bar
        let navigationBar = UINavigationBar(frame: CGRectMake(0, 20, self.view.frame.size.width, 44)) // Offset by 20 pixels vertically to take the status bar into account
        navigationBar.backgroundColor = UIColor.whiteColor()

        // Create a navigation item with a title
        let navigationItem = UINavigationItem()
        navigationItem.title = "Title"
        
        // Create left and right button for navigation item
        let leftButton = UIBarButtonItem(image: UIImage(named: "menu-tab"), style: .Plain, target: self, action: #selector(FeedViewController.handleClickOnMenu))
        let rightButton = UIBarButtonItem(title: "Right", style: .Plain, target: self, action: nil)

        // Create two buttons for the navigation item
        navigationItem.leftBarButtonItem = leftButton
        navigationItem.rightBarButtonItem = rightButton
        
        // Assign the navigation item to the navigation bar
        navigationBar.items = [navigationItem]
        
        // Make the navigation bar a subview of the current view controller
        self.view.addSubview(navigationBar)
    }

    func handleClickOnMenu() {
        self.viewModel.displaySlideMenu!()
    }
}




