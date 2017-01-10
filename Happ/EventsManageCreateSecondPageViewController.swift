//
//  EventsManageCreateSecondPageViewController.swift
//  Happ
//
//  Created by Aleksei Pugachev on 12/24/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit

class EventsManageCreateSecondPageViewController: EventsManageCreateViewController {
    
    @IBOutlet weak var eventCityField: UITextField!
    @IBOutlet weak var eventPlaceField: UITextField!
    @IBOutlet weak var eventPriceFromField: UITextField!
    @IBOutlet weak var eventPriceToField: UITextField!
    @IBOutlet weak var eventCurrencyField: UITextField!
    @IBOutlet weak var eventDateStartField: UITextField!
    @IBOutlet weak var eventDateEndField: UITextField!
    @IBOutlet weak var eventTimeFromField: UITextField!
    @IBOutlet weak var eventTimeToField: UITextField!
    @IBOutlet weak var eventContinuingSwitch: UISwitch!
    
    @IBOutlet var eventCityFailureViews: [UIView]!
    @IBOutlet var eventPlaceFailureViews: [UIView]!
    @IBOutlet var eventPriceFromFailureViews: [UIView]!
    @IBOutlet var eventPriceToFailureViews: [UIView]!
    @IBOutlet var eventCurrencyFailureViews: [UIView]!
    @IBOutlet var eventDateStartFailureViews: [UIView]!
    @IBOutlet var eventDateEndFailureViews: [UIView]!
    @IBOutlet var eventTimeFromFailureViews: [UIView]!
    @IBOutlet var eventTimeToFailureViews: [UIView]!
    
    @IBOutlet weak var eventCityDisclosure: UIImageView!
    @IBOutlet weak var eventPlaceDisclosure: UIImageView!
    @IBOutlet weak var eventCurrencyDisclosure: UIImageView!
    
    @IBOutlet weak var eventDateStartBorder: UIView!
    @IBOutlet weak var eventDateEndBorder: UIView!
    @IBOutlet weak var eventTimeFromBorder: UIView!
    @IBOutlet weak var eventTimeToBorder: UIView!
    
    @IBAction func clickedCitySelect(sender: AnyObject) {
        self.viewModel.onClickSelectCity()
    }
    
    @IBAction func clickedCurrencySelect(sender: AnyObject) {
        self.viewModel.onClickSelectCurrency()
    }
    
    @IBAction func clickedPlaceSelect(sender: AnyObject) {
        self.viewModel.onClickSelectPlace()
    }
    
    func switchContinuity() {
        viewModel.onSelectContinuity(eventContinuingSwitch.on)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        eventContinuingSwitch.addTarget(self, action: #selector(self.switchContinuity), forControlEvents: .ValueChanged)
        
        navigationItem.leftBarButtonItem?.image = UIImage(named: "nav-back-gray")
        navigationItem.leftBarButtonItem?.tintColor = UIColor.blackColor()
        navigationItem.title = "Create Event: Information"

        prepareDatePickerForField(eventDateStartField, tag: 1)
        prepareDatePickerForField(eventDateEndField, tag: 2)
        prepareTimePickerForField(eventTimeFromField, tag: 1)
        prepareTimePickerForField(eventTimeToField, tag: 2)
        
        [eventDateStartField, eventDateEndField, eventTimeFromField, eventTimeToField].forEach {
            $0.delegate = self
        }
        
        cleanFailures()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        fillAll()
    }
    
    override func validate() -> Bool {
        
        cleanFailures()
        var validated = true
        let errorMessageBeginning = "Please fill right following fields: "
        var errorMessage = errorMessageBeginning
        
        validateField(eventCityField, failureViews: eventCityFailureViews, disclosureView: eventCityDisclosure, validated: &validated, errorMessage: &errorMessage, errorMessageBeginning: errorMessageBeginning, errorMessageField: "City")
        validateField(eventPlaceField, failureViews: eventPlaceFailureViews, disclosureView: eventPlaceDisclosure, validated: &validated, errorMessage: &errorMessage, errorMessageBeginning: errorMessageBeginning, errorMessageField: "Place")
        
        let priceFrom = eventPriceFromField.text != nil ? Int(eventPriceFromField.text!) : 0
        let priceTo = eventPriceToField.text != nil ? Int(eventPriceToField.text!) : 0
        if priceTo < priceFrom {
            eventPriceToFailureViews.forEach {
                $0.hidden = false
            }
            validated = false
            errorMessage += errorMessage != errorMessageBeginning ? ", Price to" : "Price to"
        }
        
        validateField(eventCurrencyField, failureViews: eventCurrencyFailureViews, disclosureView: eventCurrencyDisclosure, validated: &validated, errorMessage: &errorMessage, errorMessageBeginning: errorMessageBeginning, errorMessageField: "Currency")
        validateField(eventDateStartField, failureViews: eventDateStartFailureViews, disclosureView: nil, validated: &validated, errorMessage: &errorMessage, errorMessageBeginning: errorMessageBeginning, errorMessageField: "Date start")
        validateField(eventDateEndField, failureViews: eventDateEndFailureViews, disclosureView: nil, validated: &validated, errorMessage: &errorMessage, errorMessageBeginning: errorMessageBeginning, errorMessageField: "Date end")
        validateField(eventTimeFromField, failureViews: eventTimeFromFailureViews, disclosureView: nil, validated: &validated, errorMessage: &errorMessage, errorMessageBeginning: errorMessageBeginning, errorMessageField: "Time from")
        validateField(eventTimeToField, failureViews: eventTimeToFailureViews, disclosureView: nil, validated: &validated, errorMessage: &errorMessage, errorMessageBeginning: errorMessageBeginning, errorMessageField: "Time to")
        
        if !validated {
            self.extDisplayAlertView(errorMessage)
        }else{
            let priceFrom = eventPriceFromField.text != nil ? Int(eventPriceFromField.text!) : nil
            let priceTo = eventPriceToField.text != nil ? Int(eventPriceToField.text!) : nil
            viewModel.onSelectPrice(priceFrom, to: priceTo)
        }
        
        return validated
        
    }
    
    private func cleanFailures() {
        [eventCityFailureViews, eventPlaceFailureViews, eventPriceFromFailureViews, eventPriceToFailureViews, eventCurrencyFailureViews, eventDateStartFailureViews, eventDateEndFailureViews, eventTimeFromFailureViews, eventTimeToFailureViews].forEach {
            $0.forEach {
                $0.hidden = true
            }
        }
        
        [eventCityDisclosure, eventCurrencyField].forEach {
            $0.tintColor = UIColor(hexString: "D3D3D3")
        }
        
        [eventDateStartBorder, eventDateEndBorder, eventTimeFromBorder, eventTimeToBorder].forEach {
            $0.backgroundColor = UIColor.happErrorColor()
        }
    }
    
    private func fillAll() {
        if viewModel.city != nil { eventCityField.text = viewModel.city?.name }
        if viewModel.place != nil { eventPlaceField.text = viewModel.place?.name }
        if viewModel.priceFrom != nil { eventPriceFromField.text = viewModel.priceFrom != nil ? String(viewModel.priceFrom!) : "" }
        if viewModel.priceTo != nil { eventPriceToField.text = viewModel.priceTo != nil ? String(viewModel.priceTo!) : "" }
        if viewModel.currency != nil { eventCurrencyField.text = viewModel.currency?.name }
        if viewModel.dateStart != nil {
            eventDateStartField.text = HappDateFormats.EventOnCreation.toString(viewModel.dateStart!)
            (eventDateStartField.inputView as! UIDatePicker).date = viewModel.dateStart!
        }
        if viewModel.dateEnd != nil {
            eventDateEndField.text = HappDateFormats.EventOnCreation.toString(viewModel.dateEnd!)
            (eventDateEndField.inputView as! UIDatePicker).date = viewModel.dateEnd!
        }
        if viewModel.timeFrom != nil {
            eventTimeFromField.text = HappDateFormats.OnlyTime.toString(viewModel.timeFrom!)
            (eventTimeFromField.inputView as! UIDatePicker).date = viewModel.timeFrom!
        }
        if viewModel.timeTo != nil {
            eventTimeToField.text = HappDateFormats.OnlyTime.toString(viewModel.timeTo!)
            (eventTimeToField.inputView as! UIDatePicker).date = viewModel.timeTo!
        }
        eventContinuingSwitch.setOn(viewModel.continuity, animated: false)
    }
    
    private func prepareDatePickerForField(field: UITextField, tag: Int = 0) {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .Date
        datePicker.minimumDate = NSDate()
        datePicker.addTarget(self, action: #selector(self.dateChanged), forControlEvents: .ValueChanged)
        datePicker.tag = tag
        field.inputView = datePicker
    }
    
    private func prepareTimePickerForField(field: UITextField, tag: Int = 0) {
        let timePicker = UIDatePicker()
        timePicker.datePickerMode = .Time
        timePicker.minuteInterval = 15
        timePicker.addTarget(self, action: #selector(self.timeChanged), forControlEvents: .ValueChanged)
        timePicker.tag = tag
        field.inputView = timePicker
    }
    
}

extension EventsManageCreateSecondPageViewController: SelectCityDelegate, SelectCityDataSource {
    
    func didSelectCity(city: CityModel) {
        eventCityField.text = city.name
        navigationController?.popViewControllerAnimated(true)
        
        viewModel.onSelectCity(city)
    }
    
    func getSelectedCity() -> CityModel? {
        return viewModel.city
    }
    
}

extension EventsManageCreateSecondPageViewController: SelectPlaceDelegate {
    
    func didSelectPlace(place: MapPlace) {
        eventPlaceField.text = place.name
        navigationController?.popViewControllerAnimated(true)
        
        viewModel.onSelectPlace(place)
    }
    
}

extension EventsManageCreateSecondPageViewController: SelectCurrencyValueDelegate {
    
    func didSelectCurrencyValue(currencyValue: CurrencyModel) {
        eventCurrencyField.text = currencyValue.name
        navigationController?.popViewControllerAnimated(true)
        
        viewModel.onSelectCurrency(currencyValue)
    }
    
}

extension EventsManageCreateSecondPageViewController {
    
    func dateChanged(sender: UIDatePicker) {
        switch sender.tag {
            case 1:
                eventDateStartField.text = HappDateFormats.EventOnCreation.toString(sender.date)
                let endDatePicker = eventDateEndField.inputView as! UIDatePicker
                endDatePicker.minimumDate = sender.date
                eventDateEndField.text = ""
                
                viewModel.onSelectDateStart(sender.date)
                viewModel.onSelectDateEnd(nil)
            break
            case 2:
                eventDateEndField.text = HappDateFormats.EventOnCreation.toString(sender.date)
                
                viewModel.onSelectDateEnd(sender.date)
            break
            default: break
        }
    }
    
    func timeChanged(sender: UIDatePicker) {
        switch sender.tag {
            case 1:
                eventTimeFromField.text = HappDateFormats.OnlyTime.toString(sender.date)
                eventTimeToField.text = ""
                
                viewModel.onSelectTimeFrom(sender.date)
                viewModel.onSelectTimeTo(nil)
            break
            case 2:
                eventTimeToField.text = HappDateFormats.OnlyTime.toString(sender.date)
                
                viewModel.onSelectTimeTo(sender.date)
            break
            default: break
        }
    }
    
}

extension EventsManageCreateSecondPageViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(textField: UITextField) {
        switch textField {
            case eventDateStartField:
                eventDateStartBorder.backgroundColor = UIColor.happOrangeColor()
                eventDateStartBorder.hidden = false
            break
            case eventDateEndField:
                eventDateEndBorder.backgroundColor = UIColor.happOrangeColor()
                eventDateEndBorder.hidden = false
            break
            case eventTimeToField:
                eventTimeToBorder.backgroundColor = UIColor.happOrangeColor()
                eventTimeToBorder.hidden = false
            break
            case eventTimeFromField:
                eventTimeFromBorder.backgroundColor = UIColor.happOrangeColor()
                eventTimeFromBorder.hidden = false
            break
            default: break
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        switch textField {
            case eventDateStartField:
                eventDateStartBorder.backgroundColor = UIColor.happErrorColor()
                eventDateStartBorder.hidden = true
            break
            case eventDateEndField:
                eventDateEndBorder.backgroundColor = UIColor.happErrorColor()
                eventDateEndBorder.hidden = true
            break
            case eventTimeToField:
                eventTimeToBorder.backgroundColor = UIColor.happErrorColor()
                eventTimeToBorder.hidden = true
            break
            case eventTimeFromField:
                eventTimeFromBorder.backgroundColor = UIColor.happErrorColor()
                eventTimeFromBorder.hidden = true
            break
            default: break
        }
    }
    
}
