//
//  EventsMapViewController.swift
//  Happ
//
//  Created by MacBook Pro on 11/15/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit
import GoogleMaps


enum TempEventPlaces: String {
    case Almaty
    case Astana
    
    func getPlaces() -> [String] {
        switch self {
        case .Almaty:
            return ["Dostyk Plaza", "Mega Almaty", "ЦУМ", "Sova coffee", "KBTU", "Kyrmangazy 54"]
        case .Astana:
            return ["Khan Shatyr", "MEGA", "EXPO", "Nazarbayev University", "Maronno Rosso"]
        }
    }
}


class EventsMapViewController: UIViewController, MapLocationViewControllerProtocol, GMSMapViewDelegate {

    var viewModel: EventsListViewModel!


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

        self.displayEventMarkers()
        self.displayUserCity()
        /*
        if let myLocation = self.locationState.myLocation {
            self.displayMarker(.MyLocation(location: myLocation))
        }
        */

        self.extMakeNavBarWhite()
    }
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.extMakeNavBarVisible()
        self.clearMap()
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
        let events = self.viewModel.getEvents()
        let userCity = ProfileService.getUserCity()
        if let places = TempEventPlaces(rawValue: userCity.name)?.getPlaces() {
            zip(events, places)
                .forEach { event, placeName in
                    MapService.fetchPlaces(placeName)
                        .then { results -> Void in
                            self.displayMarker(.TempEventPlace(event: event, place: results.first!))
                        }
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



