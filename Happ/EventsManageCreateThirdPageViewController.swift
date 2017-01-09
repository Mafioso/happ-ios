//
//  EventsManageCreateSecondPageViewController.swift
//  Happ
//
//  Created by Aleksei Pugachev on 12/24/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit

class EventsManageCreateThirdPageViewController: EventsManageCreateViewController {
    
    @IBOutlet weak var eventPhoneField: UITextField!
    @IBOutlet weak var eventEmailField: UITextField!
    @IBOutlet weak var eventWebsiteField: UITextField!
    @IBOutlet weak var eventTicketsField: UITextField!
    @IBOutlet weak var eventRegistrationField: UITextField!
    @IBOutlet weak var eventAgeFromField: UITextField!
    @IBOutlet weak var eventAgeToField: UITextField!
    
    @IBOutlet var eventPhoneFailureViews: [UIView]!
    @IBOutlet var eventEmailFailureViews: [UIView]!
    @IBOutlet var eventWebsiteFailureViews: [UIView]!
    @IBOutlet var eventTicketsFailureViews: [UIView]!
    @IBOutlet var eventRegistrationFailureViews: [UIView]!
    @IBOutlet var eventAgeToFailureViews: [UIView]!
    
    @IBOutlet weak var eventPhoneTop: NSLayoutConstraint!
    @IBOutlet weak var eventPhoneHeight: NSLayoutConstraint!
    @IBOutlet weak var eventPhoneWrapper: UIView!
    @IBOutlet weak var eventSubmitButton: UIButton!
    @IBOutlet weak var eventSubmitIndicator: UIActivityIndicatorView!
    
    var currentPhoneTag = 1
    var eventPhoneFields: [UITextField] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem?.image = UIImage(named: "nav-back-gray")
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor(hexString: "000000")
        self.navigationItem.title = "Create Event: Submit"
        
        eventPhoneField.delegate = self
        
        cleanFailures()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        fillAll()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        fillAllDid()
    }
    
    override func bindToViewModel(viewModel: EventManageViewModel) {
        viewModel.didFail = {
            self.creationFailed()
        }
    }
    
    func creationFailed() {
        eventSubmitButton.enabled = true
        eventSubmitIndicator.stopAnimating()
        extDisplayAlertView("\(viewModel.isEditing ? "Modifying" : "Creation") of event is failed for some reason, please try again")
    }
    
    override func validate() -> Bool {
        
        cleanFailures()
        var validated = true
        let errorMessageBeginning = "Please fill right following fields: "
        var errorMessage = errorMessageBeginning
        
        var atLeastOnePhone = false
        var phones: [String] = []
        eventPhoneFields.forEach {
            if $0.text?.characters.count >= 10 {
                atLeastOnePhone = true
                phones.append($0.text!)
            }
        }
        if !atLeastOnePhone {
            eventPhoneFailureViews.forEach {
                $0.hidden = false
            }
            validated = false
            errorMessage += "Phone"
        }
        
        var email: String? = nil
        if eventEmailField.text?.characters.count > 0 {
            validateField(eventEmailField, closure: {
                let bool = self.eventEmailField.text!.isValidEmail()
                if bool { email = self.eventEmailField.text! }
                return bool
            }, failureViews: eventEmailFailureViews, disclosureView: nil, validated: &validated, errorMessage: &errorMessage, errorMessageBeginning: errorMessageBeginning, errorMessageField: "Email")
        }
        
        var website: String? = nil
        if eventWebsiteField.text?.characters.count > 0 {
            validateField(eventWebsiteField, closure: {
                let bool = self.eventWebsiteField.text!.isValidURL()
                if bool { website = self.eventWebsiteField.text! }
                return bool
            }, failureViews: eventWebsiteFailureViews, disclosureView: nil, validated: &validated, errorMessage: &errorMessage, errorMessageBeginning: errorMessageBeginning, errorMessageField: "Website")
        }
        
        var tickets: String? = nil
        if eventTicketsField.text?.characters.count > 0 {
            validateField(eventTicketsField, closure: {
                let bool = self.eventTicketsField.text!.isValidEmail()
                if bool { tickets = self.eventTicketsField.text! }
                return bool
            }, failureViews: eventTicketsFailureViews, disclosureView: nil, validated: &validated, errorMessage: &errorMessage, errorMessageBeginning: errorMessageBeginning, errorMessageField: "Tickets link")
        }
        
        var registration: String? = nil
        if eventRegistrationField.text?.characters.count > 0 {
            validateField(eventRegistrationField, closure: {
                let bool = self.eventRegistrationField.text!.isValidEmail()
                if bool { registration = self.eventRegistrationField.text! }
                return bool
            }, failureViews: eventRegistrationFailureViews, disclosureView: nil, validated: &validated, errorMessage: &errorMessage, errorMessageBeginning: errorMessageBeginning, errorMessageField: "Registration")
        }
        
        let ageFrom = eventAgeFromField.text != nil ? Int(eventAgeFromField.text!) : 0
        let ageTo = eventAgeToField.text != nil ? Int(eventAgeToField.text!) : 0
        if ageTo < ageFrom {
            eventAgeToFailureViews.forEach {
                $0.hidden = false
            }
            validated = false
            errorMessage += errorMessage != errorMessageBeginning ? ", Age to" : "Age to"
        }
        
        if !validated {
            self.extDisplayAlertView(errorMessage)
        }else{
            eventSubmitButton.enabled = false
            eventSubmitIndicator.startAnimating()
            viewModel.onSubmitBySelectPhones(phones, andEmail: email, andWebsite: website, andTickets: tickets, andRegistration: registration, andAgeFrom: ageFrom == 0 ? nil : ageFrom, andAgeTo: ageTo == 0 ? nil : ageTo)
        }
        
        return validated
        
    }
    
    private func cleanFailures() {
        eventPhoneFailureViews.forEach {
            $0.hidden = true
        }
        eventEmailFailureViews.forEach {
            $0.hidden = true
        }
        eventWebsiteFailureViews.forEach {
            $0.hidden = true
        }
        eventTicketsFailureViews.forEach {
            $0.hidden = true
        }
        eventRegistrationFailureViews.forEach {
            $0.hidden = true
        }
        eventAgeToFailureViews.forEach {
            $0.hidden = true
        }
    }
    
    private func fillAll() {
        if viewModel.email != nil { eventEmailField.text = viewModel.email }
        if viewModel.website != nil { eventWebsiteField.text = viewModel.website }
        if viewModel.tickets != nil { eventTicketsField.text = viewModel.tickets }
        if viewModel.registration != nil { eventRegistrationField.text = viewModel.registration }
        if viewModel.ageFrom != nil { eventAgeFromField.text = String(viewModel.ageFrom!) }
        if viewModel.ageTo != nil { eventAgeToField.text = String(viewModel.ageTo!) }
    }
    
    private func fillAllDid() {
        viewModel.phones.forEach {
            self.appendPhoneField($0)
        }
    }
    
    private func appendPhoneField(withText: String? = nil) {
        
        let newPhoneFrame = CGRect(x: 0, y: eventPhoneHeight.constant - 45, width: eventPhoneWrapper.frame.width, height: 44)
        
        let newPhoneFieldWrapper = UIView(frame: newPhoneFrame)
        newPhoneFieldWrapper.backgroundColor = UIColor(hexString: "F9F9F9")
        newPhoneFieldWrapper.tag = currentPhoneTag
        
        let newPhoneField = UITextField(frame: newPhoneFrame)
        newPhoneField.frame.origin.y = 0
        newPhoneField.textColor = eventPhoneField.textColor
        newPhoneField.font = eventPhoneField.font
        newPhoneField.keyboardType = eventPhoneField.keyboardType
        newPhoneField.tintColor = UIColor(hexString: "D3D3D3")
        newPhoneField.tag = currentPhoneTag
        
        eventPhoneFields.append(newPhoneField)
        
        let newPhoneDeleteButton = UIButton(type: .System)
        newPhoneDeleteButton.frame = CGRect(x: eventPhoneWrapper.frame.width - 44, y: 0, width: 44, height: 44)
        newPhoneDeleteButton.setImage(UIImage(named: "icon-remove"), forState: .Normal)
        newPhoneDeleteButton.tintColor = UIColor(hexString: "FD6E6E")
        newPhoneDeleteButton.addTarget(self, action: #selector(self.deletePhoneField), forControlEvents: .TouchUpInside)
        newPhoneDeleteButton.tag = currentPhoneTag
        
        newPhoneFieldWrapper.addSubview(newPhoneField)
        newPhoneFieldWrapper.addSubview(newPhoneDeleteButton)
        eventPhoneWrapper.addSubview(newPhoneFieldWrapper)
        
        eventPhoneTop.constant = eventPhoneHeight.constant
        eventPhoneHeight.constant += 45
        
        currentPhoneTag += 1
        
        dispatch_after(dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), Int64(NSEC_PER_SEC/2)), dispatch_get_main_queue()) {
            if withText != nil {
                newPhoneField.text = withText
            }else{
                newPhoneField.becomeFirstResponder()
            }
        }
        
    }
    
    func deletePhoneField(sender: UIButton) {
        let phoneFieldToDelete = eventPhoneWrapper.subviews.filter {
            return $0.tag == sender.tag
        }
        phoneFieldToDelete.first?.removeFromSuperview()
        
        let phoneFieldViewToDelete = eventPhoneFields.filter {
            return $0.tag == sender.tag
        }
        if let phoneFieldViewToDelete = phoneFieldViewToDelete.first {
            if let index = eventPhoneFields.indexOf(phoneFieldViewToDelete) {
                eventPhoneFields.removeAtIndex(index)
            }
        }
        
        eventPhoneWrapper.subviews.forEach {
            if $0.tag > sender.tag {
                $0.frame.origin.y -= 45
            }
        }
        eventPhoneTop.constant -= 45
        eventPhoneHeight.constant -= 45
    }
    
}

extension EventsManageCreateThirdPageViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField == eventPhoneField {
            appendPhoneField()
        }
    }
    
}
