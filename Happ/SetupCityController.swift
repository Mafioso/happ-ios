//
//  AfterSignupController.swift
//  Happ
//
//  Created by MacBook Pro on 11/8/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//


import UIKit
import GoogleMaps


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
    @IBOutlet weak var viewMap: GMSMapView!

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

        self.initMap()
        self.viewModelDidUpdate()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.extMakeNavBarHidden()
        self.extMakeStatusBarWhite()
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.extMakeNavBarVisible()
        self.extMakeStatusBarDefault()
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
        self.updateMap()
    }


    private func initMap() {
        let camera = GMSCameraPosition.cameraWithLatitude(51.15092055, longitude: 71.4388595154859, zoom: 1)
        self.viewMap.camera = camera
        self.viewMap.settings.scrollGestures = false
        self.viewMap.settings.zoomGestures = false
        self.viewMap.settings.tiltGestures = false
        self.viewMap.settings.rotateGestures = false
    }
    private func updateMap() {
        if let city = self.viewModel.citySelected {
            CityService.fetchCityLocation(city.id)
                .then { data -> Void in
                    let location = data as! CLLocation
                    let updCamera = GMSCameraUpdate.setTarget(location.coordinate, zoom: 11)
                    self.viewMap.animateWithCameraUpdate(updCamera)
            }
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



