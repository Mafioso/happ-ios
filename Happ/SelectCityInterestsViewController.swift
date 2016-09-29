//
//  ProfileViewController.swift
//  Happ
//
//  Created by MacBook Pro on 9/28/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit

class SelectCityInterestsViewController: UIViewController, UIScrollViewDelegate {

    var viewModel: SelectCityInterestsViewModel! {
        didSet {
            self.bindToViewModel()
        }
    }

    // outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var constraintsSelectCityHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintsTableHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintsSelectInterestsHeight: NSLayoutConstraint!
    @IBOutlet weak var tableInterests: UITableView!
    @IBOutlet weak var viewFooterOfSelectCity: UIView!
    @IBOutlet weak var viewHeaderOfSelectInterests: UIView!
    @IBOutlet weak var viewCity: UIView!
    @IBOutlet weak var viewNoCity: UIView!
    @IBOutlet weak var labelYourCityIs: UILabel!


    // actions
    @IBAction func clickedSelectCity(sender: UIButton) {
        self.viewModel.onClickSelectCity()
    }
    @IBAction func clickedChangeCity(sender: UIButton) {
        self.viewModel.onClickSelectCity()
    }
    @IBAction func clickedDoneButton(sender: UIButton) {
        self.viewModel.onClickDone()
    }



    // constants
    let cellInterestID = "InterestCell"
    let cellSubInterestID = "SubInterestCell"


    // variables




    override func viewDidLoad() {
        super.viewDidLoad()

        self.scrollView.delegate = self
        self.tableInterests.dataSource = self
        self.tableInterests.delegate = self
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.navigationBar.hidden = true
        if self.viewModel.selectedCity != nil {
            self.displaySelectedCityView()
        }
        self.updateFooterHeaderDisplay()
    }


    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.updateScrollViewHeight()
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.updateFooterHeaderDisplay()
    }


    private func bindToViewModel() {
        self.viewModel.didUpdate = { [weak self] _ in
            self?.tableInterests.reloadData()
            self?.updateScrollViewHeight() // after table updates
        }
    }

    private func displaySelectedCityView() {
        print(".displaySelectedCityView")

        self.labelYourCityIs.text = self.viewModel.selectedCity!.name
        UIView.transitionFromView(self.viewNoCity, toView: self.viewCity, duration: 0.3, options: UIViewAnimationOptions.ShowHideTransitionViews, completion: nil)
    }

    private func updateScrollViewHeight() {
        let windowHeight = UIScreen.mainScreen().bounds.size.height - 20
        let tableFrameHeight = self.tableInterests.frame.height
        let tableContentHeight = self.tableInterests.contentSize.height

        constraintsSelectCityHeight.constant = windowHeight
        constraintsSelectInterestsHeight.constant = max(windowHeight, windowHeight - tableFrameHeight + tableContentHeight, tableContentHeight)

        constraintsTableHeight.constant = self.tableInterests.contentSize.height

        print(".usvh",
              constraintsTableHeight.constant,
              self.tableInterests.frame.height, self.tableInterests.contentSize.height,
              constraintsSelectInterestsHeight.constant)
    }

    private func updateFooterHeaderDisplay() {
        let h = UIScreen.mainScreen().bounds.size.height
        let offset = self.scrollView.contentOffset

        if offset.y < h*0.7 {
            self.viewFooterOfSelectCity.hidden = false
            self.viewHeaderOfSelectInterests.hidden = true

        } else {
            self.viewFooterOfSelectCity.hidden = true
            self.viewHeaderOfSelectInterests.hidden = false

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
        let isSelected = self.viewModel.selectedInterests[interest] != nil

        let cell = self.tableInterests.dequeueReusableCellWithIdentifier(cellInterestID, forIndexPath: indexPath) as! InterestCell
        cell.labelInterest.text = interest.title
        cell.viewIsSelected.hidden = !isSelected
        // cell.imageCover =

        print("..", tableView.frame.height, tableView.contentSize.height)

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




