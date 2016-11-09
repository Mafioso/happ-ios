//
//  AfterSignupController.swift
//  Happ
//
//  Created by MacBook Pro on 11/8/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//


import UIKit


class SetupCityController: UIViewController {

    var viewModel: SetupCityAndInterestsViewModel!  {
        didSet {
            self.bindToViewModel()
        }
    }
    var viewModelSelectCity: SelectCityOnSetupViewModel! {
        didSet {
            self.bindToSelectCityViewModel()
        }
    }


    // outlets
    @IBOutlet weak var buttonSave: UIButton!
    @IBOutlet weak var imageGeoIndicator: UIImageView!
    @IBOutlet weak var labelSelectedCityName: UILabel!

    // actions
    @IBAction func clickedSave(sender: UIButton) {
        self.viewModel.onSaveCityPage()
    }
    @IBAction func clickedSelectCity(sender: UIButton) {
        self.viewModel.onClickSelectCity()
    }


    // constants
    let selectedCityNamePlaceholder = "NOT SELECTED"


    override func viewDidLoad() {
        super.viewDidLoad()

        self.viewModelDidUpdate()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.extMakeNavBarHidden()
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.extMakeNavBarVisible()
    }


    func viewModelDidUpdate() {
        print(".VMdidUpdate")

        self.imageGeoIndicator.hidden = true // TODO
        if let city = self.viewModel.citySelected {
            self.labelSelectedCityName.text = city.name
            self.buttonSave.enabled = true
        } else {
            self.labelSelectedCityName.text = self.selectedCityNamePlaceholder
            self.buttonSave.enabled = false
        }
    }


    private func bindToViewModel() {
        self.viewModel.didUpdate = { [weak self] _ in
            self?.viewModelDidUpdate()
        }
    }
    private func bindToSelectCityViewModel() {
        self.viewModelSelectCity.didLoad = { [weak self] _ in
            // self?.viewModelSelectCityDidLoad()
        }
        self.viewModelSelectCity.didSelectCity = { [weak self] (city: CityModel) in
            self?.viewModel.onSelectCity(city)
        }
    }


}



