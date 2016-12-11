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
}
protocol SelectSubinterestsDelegate {
    func selectSubinterestsDidClose()
    func selectSubinterestsDidSelect(subinterest: InterestModel)
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


    func updateView() {
        self.tableView.reloadData()
    }



    // init select event
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let subinterest = self.getSubinterestBy(indexPath)
        self.delegate?.selectSubinterestsDidSelect(subinterest)
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


