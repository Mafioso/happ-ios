//
//  AfterSignupController.swift
//  Happ
//
//  Created by MacBook Pro on 11/8/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//


import UIKit
import GoogleMaps


let loc_select_city_placeholder = NSLocalizedString("NOT SELECTED", comment: "Placeholder used in SetupCityController")


class SetupCityController: UIViewController, SelectCityDelegate, SelectCityDataSource {

    var viewModel: SetupUserCityViewModel!  {
        didSet {
            self.updateView()
        }
    }


    // outlets
    @IBOutlet weak var buttonSave: UIButton!
    @IBOutlet weak var imageGeoIndicator: UIImageView!
    @IBOutlet weak var labelSelectedCityName: UILabel!
    @IBOutlet weak var viewMap: GMSMapView!

    // actions
    @IBAction func clickedSave(sender: UIButton) {
        self.viewModel.onClickSave()
    }
    @IBAction func clickedSelectCity(sender: UIButton) {
        self.viewModel.onClickSelectCity()
    }


    // constants
    let selectedCityNamePlaceholder = loc_select_city_placeholder


    override func viewDidLoad() {
        super.viewDidLoad()

        self.initMap()
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


    func updateView() {
        if !self.isViewLoaded() { return }

        self.imageGeoIndicator.hidden = true // TODO
        if let city = self.viewModel.selectedCity {
            self.labelSelectedCityName.text = city.name
            self.buttonSave.enabled = true
        } else {
            self.labelSelectedCityName.text = self.selectedCityNamePlaceholder
            self.buttonSave.enabled = false
        }
        self.updateMap()
    }

    // SelectCityDelegate & SelectCityDataSource
    func didSelectCity(city: CityModel) {
        self.viewModel.onSelectCity(city)
    }
    func getSelectedCity() -> CityModel? {
        return self.viewModel.selectedCity
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
        if let city = self.viewModel.selectedCity {
            CityService.fetchCityLocation(city.id)
                .then { data -> Void in
                    let location = data as! CLLocation
                    let updCamera = GMSCameraUpdate.setTarget(location.coordinate, zoom: 11)
                    self.viewMap.animateWithCameraUpdate(updCamera)
            }
        }
    }

}



