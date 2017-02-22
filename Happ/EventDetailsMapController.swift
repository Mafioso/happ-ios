//
//  EventDetailsMapController.swift
//  Happ
//
//  Created by MacBook Pro on 11/21/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit
import GoogleMaps
import PromiseKit


let loc_event_location = NSLocalizedString("Event location", comment: "Title of EventLocation NavBar")


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
    @IBOutlet weak var viewDistanceContainer: UIView!
    @IBOutlet weak var viewLocationContainer: UIView!
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


    let constConstraintID = "leadingSuperview"


    override func viewDidLoad() {
        super.viewDidLoad()

        self.initNavItems()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.updateEventInfo()
        self.initMapView()
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        [buttonRoute, buttonLocate, viewButtonRouteBackground, viewButtonLocateBackground].forEach { $0.extMakeCircle() }

        self.onDidMapLayoutSubviews() //MapViewControllerProtocol
    }

    func initMapView() {
        // initMap
        // displayEventPoint (add point + zoom)
        // initLocation -> (add point)

        let event = self.viewModel.event
        self.clearMap()
        self.initMap()

        self.displayMarker(.EventPoint(event: event))
        self.updateMap(self.markers.last!.position, zoom: 14)

        firstly { _ -> Promise<CLLocation> in
            self.locationState = MapLocationState()
            return self.getLocation()
        }
        .then { location -> Void in
            self.locationState = MapLocationState(location: location)
            self.viewModel.location = location
            self.displayMarker(.MyLocation(location: location))
        }
    }

    func updateMapView() {
        // clear map
        // add Event point
        // add Direction
        // add Location point + zoom

        let event = self.viewModel.event
        self.clearMap()
        self.displayMarker(.EventPoint(event: event))
        if let direction = self.viewModel.mapDirection {
            labelDistance.text = Utils.formatDistance(direction.getDistance(), type: .Metric)
            labelDistance.layoutIfNeeded()
            let width = labelDistance.frame.width + CGFloat(15);
            self.showEventInfoDistance(width)
            self.displayDirection(direction)
        }
        if let location = self.viewModel.location {
            self.displayMarker(.MyLocation(location: location))
            self.updateMapLocationViews()
        } else {
            self.updateMap(self.markers.last!.position, zoom: 14)
        }
    }

    func updateRouteOnMap() {
        firstly { _ -> Promise<CLLocation> in
            self.getLocation()
        }
        .then { myLocation -> Promise<MapDirection> in
            self.locationState = MapLocationState(location: myLocation)
            self.viewModel.location = myLocation
            
            let eventLocation = CLLocation(geopoint: self.viewModel.event.geopoint!)
            return MapService.fetchDirection(myLocation, to: eventLocation)
        }
        .then { direction -> Void in
            self.viewModel.mapDirection = direction
        }
        .then { _ -> Void in
            self.updateMapView()
        }
    }

    func updateEventInfo() {
        let event = self.viewModel.event
        
        if let imageURL = event.images.first?.getURL() {
            imageEventCover.hnk_setImageFromURL(imageURL)
            imageEventCover.layer.masksToBounds = true
        }
        labelEventTitle.text = event.title
        labelEventPrice.text = HappEventPriceFormats.EventMinPrice(event: event).toString()
        labelEventDate.text = HappEventDateFormats.EventDate(datetime: event.datetimes.first!).toString()
        labelEventLocation.text = event.address
        self.hideEventInfoDistance()
    }


    private func bindToViewModel() {
        self.viewModel.didUpdate = { [weak self] _ in
            self?.updateMapView()
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


    private func hideEventInfoDistance() {
        viewDistanceContainer.hidden = true
        self.addConstraintToDistanceView(0)
    }
    private func showEventInfoDistance(width: CGFloat) {
        viewDistanceContainer.hidden = false
        self.addConstraintToDistanceView(width)
    }
    private func removeConstraintFromDistanceView() {
        viewLocationContainer.constraints
            .filter { $0.identifier == constConstraintID }
            .forEach { $0.active = false }
    }
    private func addConstraintToDistanceView(width: CGFloat) {
        self.removeConstraintFromDistanceView()

        let constraint = NSLayoutConstraint(item: labelEventLocation, attribute: .Leading, relatedBy: .Equal, toItem: viewLocationContainer, attribute: .Leading, multiplier: 1.0, constant: width)
        constraint.identifier = constConstraintID
        constraint.active = true
        viewLocationContainer.addConstraint(constraint)
        viewLocationContainer.layoutIfNeeded()
    }


    private func handleClickRoute() {
        self.updateRouteOnMap()
    }

    private func initNavItems() {
        self.navigationItem.title = loc_event_location
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "nav-close"), style: .Plain, target: self, action: #selector(handleClickCloseNavItem))
    }
    func handleClickCloseNavItem() {
        self.viewModel.navigateBack?()
    }
}



