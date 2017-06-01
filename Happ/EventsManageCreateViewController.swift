//
//  EventManageFirstPageViewController.swift
//  Happ
//
//  Created by Aleksei Pugachev on 12/23/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

let loc_my_events_create = NSLocalizedString("Create Event", comment: "Title of NavBar on EventsManageCreateViewController")


// Prototype
class EventsManageCreateViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBAction func clickedNextButton(sender: UIButton) {
        if validate() {
            viewModel.navigateNext?()
        }
    }
    
    var viewModel: EventManageViewModel!  {
        didSet {
            self.bindToViewModel(viewModel)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initNavBarItems()
        automaticallyAdjustsScrollViewInsets = false
        
        self.extHideKeyboardWhenTappedAround()
        self.extMakeStatusBarDefault()
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
    
    internal func bindToViewModel(viewModel: EventManageViewModel) {}
    
    internal func validate() -> Bool {
        return false
    }
    
    internal func validateField(field: UITextField? = nil, closure: (Void -> Bool)? = nil, failureViews: [UIView], disclosureView: UIView?, inout validated: Bool, inout errorMessage: String, errorMessageBeginning: String, errorMessageField: String) {
        if closure != nil {
            if !closure!() {
                failField(failureViews, disclosureView: disclosureView, validated: &validated, errorMessage: &errorMessage, errorMessageBeginning: errorMessageBeginning, errorMessageField: errorMessageField)
            }
        }else{
            if field?.text?.characters.count < 1 {
                failField(failureViews, disclosureView: disclosureView, validated: &validated, errorMessage: &errorMessage, errorMessageBeginning: errorMessageBeginning, errorMessageField: errorMessageField)
            }
        }
    }
    
    private func failField(failureViews: [UIView], disclosureView: UIView?, inout validated: Bool, inout errorMessage: String, errorMessageBeginning: String, errorMessageField: String) {
        failureViews.forEach {
            $0.hidden = false
        }
        disclosureView?.tintColor = UIColor.happErrorColor()
        validated = false
        errorMessage += errorMessage != errorMessageBeginning ? ", \(errorMessageField)" : errorMessageField
    }

    private func initNavBarItems() {
        self.navigationItem.title = loc_my_events_create
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "nav-close"), style: .Plain, target: self, action: #selector(handleBackNavItem))
        //self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon-presentation"), style: .Plain, target: self, action: #selector(handlePresentationButton))
    }

    @objc private func handleBackNavItem() {
        self.viewModel.navigateBack?()
    }
    
    @objc private func handlePresentationButton() {
        // TODO
    }
    
}
