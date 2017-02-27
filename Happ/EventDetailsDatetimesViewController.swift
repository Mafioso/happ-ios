//
//  EventDetailsDatetimesViewController.swift
//  Happ
//
//  Created by MacBook Pro on 2/27/17.
//  Copyright © 2017 Sattar Stamkulov. All rights reserved.
//

import UIKit


let loc_close_on_start_yes = NSLocalizedString("After the event, the entrance is open", comment: "Text near the lock icon when is open on EventDetailsDatetime")
let loc_close_on_start_no = NSLocalizedString("After the event, the entrance is closed", comment: "Text near the lock icon when is closed on EventDetailsDatetime")

enum EventCloseOnStart {
    case Open
    case Close

    static func getFor(event: EventModel) -> EventCloseOnStart {
        return event.is_close_on_start ? .Close : .Open
    }
    func getText() -> String {
        switch self {
        case .Open:
            return loc_close_on_start_yes
        case .Close:
            return loc_close_on_start_no
        }
    }
    func getIcon() -> String {
        switch self {
        case .Open:
            return "icon-lock-open"
        case .Close:
            return "icon-lock-close"
        }
    }
}


class EventDetailsDatetimesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var labelDateRange: UILabel!
    @IBOutlet weak var labelTimeRange: UILabel!
    @IBOutlet weak var labelCloseOnStart: UILabel!
    @IBOutlet weak var imageCloseOnStartIcon: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    
    var viewModel: EventDatetimesViewModel! {
        didSet {
            self.bindToViewModel()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self

        self.automaticallyAdjustsScrollViewInsets = false

        self.viewModelDidUpdate()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.extMakeNavBarTransparrent()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    private func viewModelDidUpdate() {
        self.tableView.reloadData()
    }

    private func bindToViewModel() {
        self.viewModel.didUpdate = { [weak self] _ in
            self?.viewModelDidUpdate()
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let event = self.viewModel.event
        return event.event_datetimes.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! EventDatetimesTableViewCell
        let event = self.viewModel.event
        let datetime = event.event_datetimes[indexPath.row]
        let closeOnStart = EventCloseOnStart.getFor(event)

        cell.labelDateRange.text = HappEventDateFormats.EventDate(datetime: datetime).toString()
        cell.labelTimeRange.text = HappEventDateFormats.EventTimeRange(datetime: datetime).toString()
        cell.labelCloseOnStart.text = closeOnStart.getText()
        cell.imageCloseOnStartIcon.image = UIImage(named: closeOnStart.getIcon())!

        return cell
    }

}



