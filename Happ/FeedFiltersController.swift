//
//  FeedFiltersController.swift
//  Happ
//
//  Created by MacBook Pro on 10/4/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit
import WTLCalendarView

class FeedFiltersController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableDateRange: UITableView!
    @IBOutlet weak var constraintsTableHeight: NSLayoutConstraint!
    @IBOutlet var radios: [UISwitch]!
    @IBOutlet weak var radioIsFree: UISwitch!
    @IBOutlet weak var radioIsPopular: UISwitch!
    @IBOutlet weak var radioIsConvert: UISwitch!
    @IBOutlet weak var datetime: UIView!
    @IBOutlet weak var calendarView: CalendarView!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var timeOK: UIButton!
    @IBOutlet weak var top: NSLayoutConstraint!
    
    let cellDateDisplayID = "cellDisplayDate"
    
    var viewModel: EventsListViewModel!
    var beginDate: NSDate?
    var finishDate: NSDate?
    var time: NSDate?

    @IBAction func clickedTimeOK(sender: AnyObject) {
        time = timePicker.date
        tableDateRange.reloadData()
        reapplyFilters()
        closeDateTime()
    }
    
    @IBAction func clickedResetFilters(sender: AnyObject) {
        beginDate = nil
        finishDate = nil
        time = nil
        
        calendarView.setBeginDate(nil, finishDate: nil)
        timePicker.date = NSDate(timeIntervalSince1970: 60 * 60 * 20)
        tableDateRange.reloadData()
        searchBar.text = ""
        
        radios.forEach {
            $0.setOn(false, animated: true)
        }
        
        reapplyFilters()
        closeDateTime()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()

        tableDateRange.dataSource = self
        tableDateRange.delegate = self
        
        calendarView.delegate = self
        
        searchBar.delegate = self

        self.extHideKeyboardWhenTappedAround()
    }
    
    private func closeDateTime() {
        top.constant = 30
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseIn, animations: {
            self.view.layoutIfNeeded()
            self.datetime.alpha = 0
        }, completion: nil)
    }
    
    private func configureUI() {
        if #available(iOS 9.0, *) {
            UITextField.appearanceWhenContainedInInstancesOfClasses([UISearchBar.self]).backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.2)
            UITextField.appearanceWhenContainedInInstancesOfClasses([UISearchBar.self]).textColor = UIColor.whiteColor()
        } else {
            UITextField.my_appearanceWhenContainedIn(UISearchBar.self).backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.2)
            UITextField.my_appearanceWhenContainedIn(UISearchBar.self).textColor = UIColor.whiteColor()
        }
        
        timePicker.setValue(UIColor.whiteColor(), forKeyPath: "textColor")
        timePicker.timeZone = NSTimeZone(abbreviation: "GMT")
        timePicker.date = NSDate(timeIntervalSince1970: 60 * 60 * 20)
        for subview in timePicker.subviews {
            if subview.frame.height <= 5 {
                subview.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.33)
                subview.tintColor = UIColor.whiteColor().colorWithAlphaComponent(0.33)
                subview.layer.borderColor = UIColor.whiteColor().colorWithAlphaComponent(0.33).CGColor
                subview.layer.borderWidth = 0.5
            }
        }
        if let pickerView = timePicker.subviews.first {
            for subview in pickerView.subviews {
                if subview.frame.height <= 5 {
                    subview.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.33)
                    subview.tintColor = UIColor.whiteColor().colorWithAlphaComponent(0.33)
                    subview.layer.borderColor = UIColor.whiteColor().colorWithAlphaComponent(0.33).CGColor
                    subview.layer.borderWidth = 0.5
                }
            }
        }
        
        radios.forEach {
            $0.backgroundColor = UIColor(hexString: "ffebe0")
            $0.layer.cornerRadius = 16
            $0.addTarget(self, action: #selector(self.reapplyFilters), forControlEvents: .ValueChanged)
        }
    }

    @objc private func reapplyFilters() {
        let search: String? = searchBar.text
        let sortBy: EventsListSortType = radioIsPopular.on ? .ByPopular : .ByDate

        let filters = EventsListFiltersState(search: search, dateFrom: beginDate, dateTo: finishDate, time: time, sortBy: sortBy, onlyFree: radioIsFree.on, convertCurrency: radioIsConvert.on, statusMap: nil)
        self.viewModel.onChangeFilters(filters)
    }
    
}


extension FeedFiltersController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(self.cellDateDisplayID) as! FeedFilterDateCell
        
        cell.labelFirst.text = ""
        cell.labelSecond.text = ""
        cell.spacerFirst.hidden = true
        cell.spacerSecond.hidden = true
        
        switch indexPath.row {
            case 0:
                cell.labelTitle.text = "Select date"
                if beginDate != nil {
                    cell.spacerFirst.hidden = false
                    let formatter = NSDateFormatter()
                    formatter.dateFormat = "dd MMM"
                    cell.labelFirst.text = formatter.stringFromDate(beginDate!)
                    if finishDate != nil {
                        cell.spacerSecond.hidden = false
                        cell.labelSecond.text = formatter.stringFromDate(finishDate!)
                    }
                }
            break
            case 1:
                cell.labelTitle.text = "Select time"
                if time != nil {
                    cell.spacerFirst.hidden = false
                    let formatter = NSDateFormatter()
                    formatter.timeZone = NSTimeZone(abbreviation: "GMT")
                    formatter.dateFormat = "H:mm"
                    cell.labelFirst.text = formatter.stringFromDate(time!)
                }
            break
            default: break
        }
        
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.row {
            case 0:
                timePicker.alpha = 0
                timeOK.alpha = 0
                calendarView.alpha = 1
            break
            case 1:
                timePicker.alpha = 1
                timeOK.alpha = 1
                calendarView.alpha = 0
            break
            default: break
        }
        
        if ScreenSize.SCREEN_HEIGHT < 667 {
            top.constant = 30 + (ScreenSize.SCREEN_HEIGHT - 667)
        }
        
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseIn, animations: {
            self.view.layoutIfNeeded()
            self.datetime.alpha = 1
        }, completion: nil)
    }
    
}

extension FeedFiltersController: CalendarViewDelegate {

    func calendarView(calendarView: CalendarView, didUpdateBeginDate beginDate: NSDate?) {
        self.beginDate = beginDate
        tableDateRange.reloadData()
        reapplyFilters()
    }
    
    func calendarView(calendarView: CalendarView, didUpdateFinishDate finishDate: NSDate?) {
        self.finishDate = finishDate
        tableDateRange.reloadData()
        reapplyFilters()
        if finishDate != nil {
            closeDateTime()
        }
    }
    
}

extension FeedFiltersController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        reapplyFilters()
    }
    
}




