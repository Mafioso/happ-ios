//
//  EventsMapViewController.swift
//  Happ
//
//  Created by MacBook Pro on 11/15/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit
import GoogleMaps




class EventsMapViewController: UIViewController, MapLocationViewControllerProtocol, GMSMapViewDelegate {


    // outlets
    @IBOutlet weak var viewMap: GMSMapView!
    @IBOutlet weak var viewLocateBackground: UIView!
    @IBOutlet weak var buttonLocate: UIButton!

    // actions
    @IBAction func clickedLocate(sender: UIButton) {
        self.onClickLocate()
    }

    // variables
    var markers: [GMSMarker] = []
    var locationState: MapLocationState!


    override func viewDidLoad() {
        super.viewDidLoad()

        self.hidesBottomBarWhenPushed = true

        self.initMap()
        self.initLocation()

        self.initNavBarItems()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        buttonLocate.extMakeCircle()
        viewLocateBackground.extMakeCircle()

        self.onDidMapLayoutSubviews()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.displayEventMarkers()
        self.displayUserCity()
        /*
        if let myLocation = self.locationState.myLocation {
            self.displayMarker(.MyLocation(location: myLocation))
        }
        */

        self.extMakeNavBarWhite()
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        self.extMakeNavBarVisible()
        self.destroyMarkers()
    }


    // implementations MapLocationViewControllerProtocol
    func getMapView() -> GMSMapView {
        return self.viewMap
    }
    func getLocateButton() -> UIButton {
        return self.buttonLocate
    }
    // ---
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            self.startLocationDetecting()
        }
    }
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            self.stopLocationDetecting()
            
            self.locationState = MapLocationState(locationManager: manager, location: location)
            self.updateMapLocationViews()
            self.displayMarker(.MyLocation(location: location))
        }
    }
    func mapView(mapView: GMSMapView, willMove gesture: Bool) {
        self.onWillCameraMove(gesture)
    }
    // end ---



    private func displayEventMarkers() {
        self.displayMarker(.Event(event: EventService.getFeed().first! ))
        //EventService.getFeed().forEach { self.displayMarker(.Event(event: $0 )) }
    }
    private func displayUserCity() {
        let userCity = ProfileService.getUserCity()
        CityService.fetchCityLocation(userCity.id)
            .then { data -> Void in
                let location = data as! CLLocation
                self.updateMap(location.coordinate, zoom: 13)
        }
    }


    private func initNavBarItems() {
        self.navigationItem.title = "Events near you"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "nav-menu"), style: .Plain, target: self, action: #selector(handleClickMenuNavItem))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "nav-filter-gray"), style: .Plain, target: self, action: #selector(handleClickFilterNavItem))
    }
    func handleClickMenuNavItem() {
       // self.viewModel.displaySlideMenu?() TODO uncomment
    }
    func handleClickFilterNavItem() {
    }
}



