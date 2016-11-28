//
//  EventDetailsMapController.swift
//  Happ
//
//  Created by MacBook Pro on 11/21/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit
import GoogleMaps


class EventDetailsMapController: UIViewController, MapLocationViewControllerProtocol, GMSMapViewDelegate {

    var viewModel: EventOnMapViewModel!  {
        didSet {
            self.bindToViewModel()
        }
    }


    // outlets
    @IBOutlet weak var viewButtonRouteBackground: UIView!
    @IBOutlet weak var viewButtonLocateBackground: UIView!
    @IBOutlet weak var viewMap: GMSMapView!
    @IBOutlet weak var buttonRoute: UIButton!
    @IBOutlet weak var buttonLocate: UIButton!
    @IBOutlet weak var imageEventCover: UIImageView!
    @IBOutlet weak var labelEventTitle: UILabel!
    @IBOutlet weak var labelEventDate: UILabel!
    @IBOutlet weak var labelEventPrice: UILabel!
    @IBOutlet weak var labelDistance: UILabel!
    @IBOutlet weak var labelEventLocation: UILabel!

    // actions
    @IBAction func clickedOpenEventDetails(sender: UIButton) {
        self.viewModel.onClickOpenEventDetails()
    }
    @IBAction func clickedRouteButton(sender: UIButton) {
        self.handleClickRoute()
    }
    @IBAction func clickedLocateButton(sender: UIButton) {
        self.onClickLocate()
    }

    // variables
    var markers: [GMSMarker] = [] // MapViewControllerProtocol
    var locationState: MapLocationState! //MapLocationViewControllerProtocol



    override func viewDidLoad() {
        super.viewDidLoad()

        self.initMap()
        self.initLocation()
        self.initNavItems()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.updateViews()
        self.extMakeNavBarWhite()
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        self.extMakeNavBarHidden()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        [buttonRoute, buttonLocate, viewButtonRouteBackground, viewButtonLocateBackground].forEach { $0.extMakeCircle() }

        self.onDidMapLayoutSubviews() //MapViewControllerProtocol
    }


    func zoomToUserCity() {
        let userCity = ProfileService.getUserCity()
        CityService.fetchCityLocation(userCity.id)
            .then { data -> Void in
                let location = data as! CLLocation
                self.updateMap(location.coordinate, zoom: 10)
        }
    }
    func updateViews() {
        let event = self.viewModel.event
    
        if let imageURL = event.images.first?.getURL() {
            imageEventCover.hnk_setImageFromURL(imageURL)
        }
        labelEventTitle.text = event.title
        labelEventPrice.text = event.getPrice(.Range)
        labelEventDate.text = HappDateFormats.EventOnFeed.toString(event.start_datetime!)
        labelEventLocation.text = event.address
        labelDistance.text = "? km"

        self.clearMap()
        if let location = self.viewModel.location {
            self.displayMarker(.MyLocation(location: location))
        }
        if let direction = self.viewModel.mapDirection {
            self.displayDirection(direction)
            labelDistance.text = Utils.formatDistance(direction.getDistance(), type: .Metric)
        }
        self.displayMarker(.EventPoint(event: event))
        self.updateMap(self.markers.last!.position, zoom: 14)
    }


    private func bindToViewModel() {
        self.viewModel.didUpdate = { [weak self] _ in
            self?.updateViews()
        }
    }



    // implement MapViewControllerProtocol
    func getMapView() -> GMSMapView {
        return self.viewMap
    }
    // implement MapLocationViewControllerProtocol
    func getLocateButton() -> UIButton {
        return self.buttonLocate
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
            self.viewModel.onFoundLocation(location)
        }
    }


    private func handleClickRoute() {
        // 1. clear map / markerks & polyline
        // 2. clear current location
        // 3. init location -> will init polyline direction
        // 4. update views
        self.viewModel.mapDirection = nil
        self.clearMap()
        self.initLocation()
        self.updateViews()
    }

    private func initNavItems() {
        self.navigationItem.title = "Event location"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "nav-close"), style: .Plain, target: self, action: #selector(handleClickCloseNavItem))
    }
    func handleClickCloseNavItem() {
        self.viewModel.navigateBack?()
    }
}



