//
//  MapLocationViewControllerProtocol.swift
//  Happ
//
//  Created by MacBook Pro on 11/24/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import Foundation

import UIKit
import GoogleMaps



class MapLocationState {
    var locationManager: CLLocationManager
    var myLocation: CLLocation?
    var isButtonSelected: Bool


    init(locationManager: CLLocationManager) {
        self.locationManager = locationManager
        self.myLocation = nil
        self.isButtonSelected = false
    }
    init(locationManager: CLLocationManager, location: CLLocation) {
        self.locationManager = locationManager
        self.myLocation = location
        self.isButtonSelected = true
    }
}


protocol MapLocationViewControllerProtocol: class, MapViewControllerProtocol, CLLocationManagerDelegate {
    var locationState: MapLocationState! { get set }

    func initLocation()
    // functions
    func startLocationDetecting()
    func stopLocationDetecting()
    func updateMapLocationViews()
    // variables:
    func getLocateButton() -> UIButton
    // inputs:
    func onWillCameraMove(gesture: Bool)
    func onClickLocate()
}


extension MapLocationViewControllerProtocol where Self: MapViewControllerProtocol {

    func initLocation() {
        let manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        self.locationState = MapLocationState(locationManager: manager)

        // if already has authorization
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            self.startLocationDetecting()
        }
    }
    func startLocationDetecting() {
        dispatch_async(dispatch_get_main_queue()) {
            let manager = self.locationState.locationManager
            manager.startUpdatingLocation()
        }
    }
    func stopLocationDetecting() {
        dispatch_async(dispatch_get_main_queue()) {
            let manager = self.locationState.locationManager
            manager.stopUpdatingLocation()
        }
    }
    func updateMapLocationViews() {
        let state = self.locationState
        if  let location = state.myLocation
            where state.isButtonSelected {
            self.updateMap(location.coordinate, zoom: 15)
        }
        self.getLocateButton().selected = state.isButtonSelected
    }


    // inputs
    func onWillCameraMove(gesture: Bool) {
        if gesture { // moved by User using gestures
            self.locationState.isButtonSelected = false
            self.updateMapLocationViews()
        }
    }
    func onClickLocate() {
        let state = self.locationState
        state.isButtonSelected = true
        self.updateMapLocationViews()
    }

    // handlers
    // NOTE:

}
