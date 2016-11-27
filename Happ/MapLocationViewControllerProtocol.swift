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
    func updateMapLocationViews()
    // variables:
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus)
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    func mapView(mapView: GMSMapView, willMove gesture: Bool)
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
        // if already has authorization
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            manager.startUpdatingLocation()
        }
        self.locationState = MapLocationState(locationManager: manager)
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
        if self.locationState.myLocation != nil {
            let state = self.locationState
            state.isButtonSelected = true
            self.updateMapLocationViews()
        }
    }

    // NOTE: some functions are not be able to implement in this extension:
    // - func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus)
    // - func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    // - func mapView(mapView: GMSMapView, willMove gesture: Bool)

}
