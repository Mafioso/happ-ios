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
import PromiseKit



class MapLocationState {
    var myLocation: CLLocation?
    var isButtonSelected: Bool

    init() {
        self.myLocation = nil
        self.isButtonSelected = false
    }
    init(location: CLLocation) {
        self.myLocation = location
        self.isButtonSelected = true
    }
}


protocol MapLocationViewControllerProtocol: class, MapViewControllerProtocol, CLLocationManagerDelegate {
    var locationState: MapLocationState! { get set }

    func getLocation() -> Promise<CLLocation>
    func zoomToUserCity()
    func initLocation()
    // functions
    func updateMapLocationViews()
    // variables:
    func mapView(mapView: GMSMapView, willMove gesture: Bool)
    func getLocateButton() -> UIButton
    // inputs:
    func onWillCameraMove(gesture: Bool)
    func onClickLocate()
}


extension MapLocationViewControllerProtocol where Self: MapViewControllerProtocol {

    func initLocation() {
        self.locationState = MapLocationState()
        self.getLocation()
            .then { myLocation -> Void in
                self.locationState = MapLocationState(location: myLocation)
                self.displayMarker(.MyLocation(location: myLocation))
                self.updateMapLocationViews()
            }
            .error { err in
                print(".initLocation.error", err)
            }
    }
    func getLocation() -> Promise<CLLocation> {
        return CLLocationManager.promise()
    }
    func updateMapLocationViews() {
        let state = self.locationState
        if  let location = state.myLocation
            where state.isButtonSelected {
            self.updateMap(location.coordinate, zoom: 15)
        }
        self.getLocateButton().selected = state.isButtonSelected
    }
    func zoomToUserCity() {
        let userCity = ProfileService.getUserCity()
        CityService.fetchCityLocation(userCity.id)
            .then { data -> Void in
                let location = data as! CLLocation
                self.updateMap(location.coordinate, zoom: 10)
        }
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
    // - func mapView(mapView: GMSMapView, willMove gesture: Bool)

}
