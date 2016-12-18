//
//  EventsMapViewController.swift
//  Happ
//
//  Created by MacBook Pro on 11/15/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit
import GoogleMaps


class EventsMapViewController: UIViewController, MapLocationViewControllerProtocol, GMSMapViewDelegate, FeedFiltersDelegate {


    var viewModel: EventsMapViewModel!  {
        didSet {
            self.updateView()
        }
    }


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

        self.displayUserCity()
        self.extMakeNavBarWhite()
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.extMakeNavBarVisible()
    }

    func updateView() {

        self.clearMap()
        self.displayEventMarkers()
        /*
         if let myLocation = self.locationState.myLocation {
         self.displayMarker(.MyLocation(location: myLocation))
         }
         */
    }
    
    
    // implement FeedFiltersDelegate
    func didChangeFilters(filters: EventsListFiltersState) {
        self.viewModel.onChangeFilters(filters)
    }


    // implementations MapLocationViewControllerProtocol
    func getMapView() -> GMSMapView {
        return self.viewMap
    }
    func getLocateButton() -> UIButton {
        return self.buttonLocate
    }
    func mapView(mapView: GMSMapView, didTapMarker marker: GMSMarker) -> Bool {
        if let eventID = marker.userData as? String {
            self.viewModel.navigateEventDetailsMap?(id: eventID)
            return true
        }
        return false
    }
    func mapView(mapView: GMSMapView, willMove gesture: Bool) {
        self.onWillCameraMove(gesture)
    }
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        manager.delegate = nil
        if let location = locations.first {
            self.locationState = MapLocationState(locationManager: manager, location: location)
            self.updateMapLocationViews()
            self.displayMarker(.MyLocation(location: location))
        }
    }


    private func displayEventMarkers() {
        let events = self.viewModel.state.items
        events
            .map { $0 as! EventModel }
            .forEach { event in
                EventService.updateGeoPointIfNotExists(event)
                    .then { event -> Void in
                        self.displayMarker(.Event(event: event))
                    }
            }
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
        self.viewModel.displaySlideMenu?()
    }
    func handleClickFilterNavItem() {
    }
}



