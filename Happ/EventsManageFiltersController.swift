//
//  FeedFiltersController.swift
//  Happ
//
//  Created by Aleksei Pugachev on 12/23/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit
import WTLCalendarView
import SlideMenuControllerSwift

protocol EventsManageFiltersDelegate {
    func didChangeFilters(filters: EventsListFiltersState)
}

@objc class EventsManageFiltersController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableDateRange: UITableView!
    @IBOutlet weak var constraintsTableHeight: NSLayoutConstraint!
    @IBOutlet var radios: [UISwitch]!
    @IBOutlet weak var datetime: UIView!
    @IBOutlet weak var calendarView: CalendarView!
    @IBOutlet weak var top: NSLayoutConstraint!

    let cellDateDisplayID = "cellDisplayDate"

    var delegate: FeedFiltersDelegate?
    var beginDate: NSDate?
    var finishDate: NSDate?
    var time: NSDate?

    var isKeyboardOpen: Bool = false

    @IBAction func clickedResetFilters(sender: AnyObject) {
        beginDate = nil
        finishDate = nil
        time = nil

        calendarView.setBeginDate(nil, finishDate: nil)
        tableDateRange.reloadData()
        searchBar.text = ""

        radios.forEach {
            $0.setOn(true, animated: true)
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

        let tapGesture = self.extHideKeyboardWhenTappedAround()
        tapGesture.delegate = self
        
        self.initObservers()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        self.deinitObservers()
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
        
        radios.forEach {
            $0.backgroundColor = UIColor(hexString: "ffebe0")
            $0.layer.cornerRadius = 16
            $0.addTarget(self, action: #selector(self.reapplyFilters), forControlEvents: .ValueChanged)
        }
    }

    @objc private func reapplyFilters() {
        
        var statusMap: [EventModelStatusTypes: Bool] = [.Active: true, .Inactive: true, .OnReview: true, .Rejected: true, .Finished: true]
        
        radios.forEach {
            switch $0.tag {
                case 1:
                    statusMap.updateValue($0.on, forKey: .Inactive)
                break
                case 2:
                    statusMap.updateValue($0.on, forKey: .OnReview)
                break
                case 3:
                    statusMap.updateValue($0.on, forKey: .Rejected)
                break
                case 4:
                    statusMap.updateValue($0.on, forKey: .Finished)
                break
                default:
                    statusMap.updateValue($0.on, forKey: .Active)
                break
            }
        }
        
        let filters = EventsListFiltersState(search: "", dateFrom: beginDate, dateTo: finishDate, time: time, sortBy: .ByPopular, onlyFree: false, statusMap: statusMap)
        self.delegate?.didChangeFilters(filters)
    }
}


extension EventsManageFiltersController: SlideMenuControllerDelegate, UIGestureRecognizerDelegate {
    
    // hide keyboard when SlideMenu closes
    func rightWillClose() {
        self.extDismissKeyboard()
    }

    // fix keyboard closing on tap for tableview.didSelectCell
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        return self.isKeyboardOpen
    }

    

    func initObservers() {
        // keyboard
        NSNotificationCenter.defaultCenter()
            .addObserver(self, selector: #selector(self.keyboardWillShow), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter()
            .addObserver(self, selector: #selector(self.keyboardWillHide), name:UIKeyboardWillHideNotification, object: nil);
    }
    
    func keyboardWillShow() {
        self.isKeyboardOpen = true
    }
    
    func keyboardWillHide() {
        self.isKeyboardOpen = false
    }
    
    func deinitObservers() {
        // remove observer
        NSNotificationCenter.defaultCenter()
            .removeObserver(self)
    }
}


extension EventsManageFiltersController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
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
            default: break
        }
        
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.row {
            case 0:
                calendarView.alpha = 1
            break
            default: break
        }
        
        top.constant = -360
        
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseIn, animations: {
            self.view.layoutIfNeeded()
            self.datetime.alpha = 1
        }, completion: nil)
    }
    
}

extension EventsManageFiltersController: CalendarViewDelegate {

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

