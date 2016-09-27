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
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var buttonFilter: UIButton!
    @IBOutlet weak var buttonSort: UIButton!

    // actions
    @IBAction func clickedButtonFilter(sender: UIButton) {
    }
    @IBAction func clickedButtonSort(sender: UIButton) {
        self.displaySelectSort()
    }


    // variables
    var tableView: UITableView!


    override func viewDidLoad() {
        super.viewDidLoad()


        self.displayNavigationBar()
        self.displaySearchBar()

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
        cell.onClickLikeButton = self.viewModel.onClickLike

        return cell
    }


    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let event = self.viewModel.events[indexPath.row]
        self.viewModel.onClickEvent(event)
    }

}



extension FeedViewController {
    
    private func displayNavigationBar() {
        self.navigationController?.navigationBar.backgroundColor = UIColor.whiteColor()

        let menuButton = UIBarButtonItem(image: UIImage(named: "menu-tab"), style: .Plain, target: self, action: #selector(FeedViewController.handleClickOnMenu))

        self.navigationItem.leftBarButtonItem = menuButton
    }

    func handleClickOnMenu() {
        self.viewModel.displaySlideMenu!()
    }
}


extension FeedViewController: UISearchBarDelegate {

    // MARK: Search

    private func displaySearchBar() {
        self.definesPresentationContext = true
        searchBar.delegate = self
    }

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        self.viewModel.onSearchUpdate(searchText)
    }


    // MARK: Sort

    func displaySelectSort() {
        let currentSort = self.viewModel.sort

        let popupSelectController = UIAlertController(title: "Sort by", message: nil, preferredStyle: .ActionSheet)

        let actionByDate = UIAlertAction(title: EventSortType.ByDate.getSelectOptionTitle(currentSort), style: .Default, handler: {_ in
            self.viewModel.onChangeSort(.ByDate)
        })
        let actionByPopular = UIAlertAction(title: EventSortType.ByPopular.getSelectOptionTitle(currentSort), style: .Default, handler: {_ in
            self.viewModel.onChangeSort(.ByPopular)
        })
        let actionCancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)

        popupSelectController.addAction(actionByDate)
        popupSelectController.addAction(actionByPopular)
        popupSelectController.addAction(actionCancel)

        self.presentViewController(popupSelectController, animated: true, completion: nil)
    }
}




