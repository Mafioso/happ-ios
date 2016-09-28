//
//  ProfileViewController.swift
//  Happ
//
//  Created by MacBook Pro on 9/28/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit

class SelectCityInterestsViewController: UIViewController {

    var viewModel: SelectCityInterestsViewModel! {
        didSet {
            self.bindToViewModel()
        }
    }

    // outlets
    @IBOutlet weak var constraintsSelectCityHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintsSelectInterestsHeight: NSLayoutConstraint!
    @IBOutlet weak var tableInterests: UITableView!


    // actions
    @IBAction func clickedSelectCity(sender: UIButton) {
        self.viewModel.onClickSelectCity()
    }


    // constants
    let segueTableSubInterestID = "SubInterestTable"
    let cellInterestID = "InterestCell"


    // variables
    var tableSubInterests: UITableView!



    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableInterests.dataSource = self
        self.tableInterests.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == segueTableSubInterestID {
            let dest = sender?.destinationViewController as! UITableViewController
            self.tableSubInterests = dest.tableView
            self.tableSubInterests.dataSource = self
            self.tableSubInterests.delegate = self
        }
    }


    private func bindToViewModel() {
        self.viewModel.didUpdateInterests = { [weak self] _ in
            self?.tableInterests.reloadData()
        }
    }

}


extension SelectCityInterestsViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = self.getNumberOfInterests()
        return count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let interest = self.getInterest(indexPath)

        let cell = self.tableInterests.dequeueReusableCellWithIdentifier(cellInterestID, forIndexPath: indexPath) as! InterestCell
        cell.labelInterest.text = interest.title
        // cell.imageCover =

        return cell
    }


    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let interest = self.getInterest(indexPath)
        self.viewModel.onSelectInterest(interest)
    }


    private func getInterest(indexPath: NSIndexPath) -> InterestModel {
        return self.viewModel.interests[indexPath.row]
    }

    private func getNumberOfInterests() -> Int {
        return self.viewModel.interests.count
    }
}




