//
//  SelectInterestsSubinterestsTableController.swift
//  Happ
//
//  Created by MacBook Pro on 11/3/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit




protocol SelectSubinterestsDataSource {
    func selectSubinterestsItems() -> [InterestModel]
    func selectSubinterestsIsSelected(subinterest: InterestModel) -> Bool
    func selectSubinterestsCellHeight() -> CGFloat
}
protocol SelectSubinterestsDelegate {
    func selectSubinterestsDidClose()
    func selectSubinterests(didSelect subinterest: InterestModel)
}







class SelectSubinterestsController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var delegate: SelectSubinterestsDelegate?
    var dataSource: SelectSubinterestsDataSource?


    // outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buttonClose: UIButton!

    // actions
    @IBAction func clickedClose(sender: UIButton) {
        self.delegate?.selectSubinterestsDidClose()
        self.extBackOnPopover()
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        if  self.tableView.constraints.filter({ $0.identifier == "height" }).first == nil,
            let cellHeight = self.dataSource?.selectSubinterestsCellHeight() {

            let screenSize = UIScreen.mainScreen().bounds
            let buttonSize = CGFloat(52)
            let height = screenSize.height - cellHeight - buttonSize

            let heightConstraint = NSLayoutConstraint(item: self.tableView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: height)
            heightConstraint.identifier = "height"
            heightConstraint.active = true
            self.tableView.updateConstraints()
        }
    }


    func updateView() {
        self.tableView.reloadData()
    }



    // init select event
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let subinterest = self.getSubinterestBy(indexPath)
        self.delegate?.selectSubinterests(didSelect: subinterest)
        self.updateView()
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
        if  let isSelected = self.dataSource?.selectSubinterestsIsSelected(subinterest)
            where isSelected == true {

            cell.imageView?.hidden = false
            cell.textLabel?.textColor = UIColor.happOrangeColor()
        } else {
            cell.imageView?.hidden = true
            cell.textLabel?.textColor = UIColor.happBlackHalfTextColor()
        }
        return cell
    }
    


    private func getSubinterestBy(indexPath: NSIndexPath) -> InterestModel {
        return self.getSubinterests()[indexPath.row]
    }
    private func getSubinterests() -> [InterestModel] {
        guard let items = self.dataSource?.selectSubinterestsItems() else { return [] }
        return items
    }
}


