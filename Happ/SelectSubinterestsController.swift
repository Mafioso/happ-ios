//
//  SelectInterestsSubinterestsTableController.swift
//  Happ
//
//  Created by MacBook Pro on 11/3/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit

class SelectSubinterestsController: UIViewController {

    var viewModel: SelectInterestsViewModel!  {
        didSet {
            self.bindToViewModel()
        }
    }


    // outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buttonClose: UIButton!

    // actions
    @IBAction func clickedClose(sender: UIButton) {
        self.viewModel.closePopover?()
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
    }


    func viewModelDidUpdate() {
        self.tableView.reloadData()
    }
    
    private func bindToViewModel() {
        let superDidUpdate: (() -> ())? = self.viewModel.didUpdate
        self.viewModel.didUpdate = { [weak self] _ in
            superDidUpdate?()
            
            self?.viewModelDidUpdate()
        }
    }
    private func getSubinterestBy(indexPath: NSIndexPath) -> InterestModel {
        return self.getSubinterests()[indexPath.row]
    }
    private func getSubinterests() -> [InterestModel] {
        let interest = self.viewModel.longPressedInterest!
        let subinterests = InterestService.getSubinterestsOf(interest)
        return subinterests
    }

}


extension SelectSubinterestsController: UITableViewDataSource, UITableViewDelegate {
    
    // init select event
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let subinterest = self.getSubinterestBy(indexPath)
        self.viewModel.onSelectSubinterest(subinterest)
    }

    // fill with data
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.getSubinterests().count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let subinterest = self.getSubinterestBy(indexPath)
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)

        cell.textLabel!.text = subinterest.title.uppercaseString
        if self.viewModel.isSubinterestSelected(subinterest) {
            cell.imageView?.hidden = false
            cell.textLabel?.textColor = UIColor.happOrangeColor()
        } else {
            cell.imageView?.hidden = true
            cell.textLabel?.textColor = UIColor.happBlackHalfTextColor()
        }
        return cell
    }
}


