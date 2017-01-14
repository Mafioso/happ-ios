//
//  EventsManageDeniedDetailsViewController.swift
//  Happ
//
//  Created by Aleksei Pugachev on 1/6/17.
//  Copyright © 2017 Sattar Stamkulov. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

let loc_my_events_details = NSLocalizedString("Event details", comment: "Title of NavBar on EventsManageDeniedDetailsViewController")


class EventsManageDeniedDetailsViewController: UIViewController {
    
    @IBOutlet weak var deniedInfo: UILabel!
    @IBOutlet weak var deniedDetails: UILabel!
    
    @IBAction func clickedEditEvent(sender: AnyObject) {
        viewModel.navigateEditEvent?(object: viewModel.event!)
    }
    
    var viewModel: EventsManageDeniedDetailsViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initNavBarItems()
        automaticallyAdjustsScrollViewInsets = false
        
        self.extHideKeyboardWhenTappedAround()
        
        if let event = viewModel.event {
            let dateF = NSDateFormatter()
            dateF.dateFormat = "d MMMM Y"
            deniedInfo.text = "\(event._rejectionAuthor)\(event._rejectionDate != nil ? ", \(dateF.stringFromDate(event._rejectionDate!))" : "")"
            deniedDetails.text = event._rejectionText
        }else{
            viewModel.navigateBack?()
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.extMakeNavBarWhite()
        IQKeyboardManager.sharedManager().enable = true
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        IQKeyboardManager.sharedManager().enable = false
    }

    private func initNavBarItems() {
        self.navigationItem.title = loc_my_events_details
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "nav-back"), style: .Plain, target: self, action: #selector(handleBackNavItem))
    }
    
    @objc private func handleBackNavItem() {
        self.viewModel.navigateBack?()
    }

}
