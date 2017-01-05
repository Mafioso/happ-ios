//
//  EventsMapViewController.swift
//  Happ
//
//  Created by MacBook Pro on 11/15/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit
import GoogleMaps
import PromiseKit


class ClusterMarker: NSObject, GMUClusterItem {
    var position: CLLocationCoordinate2D
    var event: EventModel

    init(event: EventModel) {
        self.event = event
        self.position = CLLocation(geopoint: self.event.geopoint!).coordinate
    }
}

class ClusterRenderer: GMUDefaultClusterRenderer {}


class EventsMapViewController: UIViewController, MapLocationViewControllerProtocol, GMUClusterManagerDelegate, GMUClusterRendererDelegate, GMSMapViewDelegate, FeedFiltersDelegate {


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
    var clusterMarkerks: [ClusterMarker] = []
    var locationState: MapLocationState!
    var clusterManager: GMUClusterManager!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. initMap with userCity.geopoint
        // 2. fetch current location -> display marker myLocation
        // 3. get Center & Radius -> fetch events -> display cluster marker of events
        
        self.initMap()
        self.initMapCluster()
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

    func renderer(renderer: GMUClusterRenderer, didRenderMarker marker: GMSMarker) {
        if let view = marker.iconView as? EventOnMap {
            view.viewRounded.extMakeCircle()
            view.imageCover.extMakeCircle()
        }
    }

    func renderer(renderer: GMUClusterRenderer, willRenderMarker marker: GMSMarker) {
        if let clusterMarker = marker.userData as? ClusterMarker {
            let event = clusterMarker.event
            var color: UIColor = UIColor.happBlackQuarterTextColor()
            if  let image = event.images.first,
                let colorCode = image.color {
                color = UIColor(hexString: colorCode)
            }

            // create view
            let eventOnMapView = EventOnMap.initView(color)
            eventOnMapView.labelTitle.text = event.title
            eventOnMapView.viewRounded.backgroundColor = color
            if  let image = event.images.first,
                let imageURL = image.getURL() {
                eventOnMapView.imageCover.hnk_setImageFromURL(imageURL)
            }

            marker.groundAnchor = CGPoint(x: 0, y: 1)
            marker.iconView = eventOnMapView
        }
    }

    func initMapCluster() {
        let iconGenerator = GMUDefaultClusterIconGenerator()
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = ClusterRenderer(mapView: self.getMapView(), clusterIconGenerator: iconGenerator)
        renderer.delegate = self
        self.clusterManager = GMUClusterManager(map: self.getMapView(), algorithm: algorithm,renderer: renderer)
        self.clusterManager.setDelegate(self, mapDelegate: self)
    }

    func handleChangeMapView() {
        guard !self.viewModel.state.isFetching else { return }

        let center = self.getMapCenter()
        let radius = self.getMapRadius()
        print(".mapView.change", center.coordinate, radius)
        self.viewModel.onChangeMapPosition(center, radius: radius) { AsyncState in
            self.viewModel.state = AsyncState
        }
    }

    func updateView() {
        guard self.isViewLoaded() else { return }

        self.clearMap()
        self.displayEventMarkers()
        if let myLocation = self.locationState.myLocation {
            self.displayMarker(.MyLocation(location: myLocation))
        }
    }

    
    // implement FeedFiltersDelegate
    func didChangeFilters(filters: EventsListFiltersState) {
        self.viewModel.onChangeFilters(filters) // it clear state
        // TODO self.initDataLoading() // fetch items into state
    }


    func getMapCenter() -> CLLocation {
        let cameraCoord = self.getMapView().camera.target
        return CLLocation(latitude: cameraCoord.latitude, longitude: cameraCoord.longitude)
    }
    func getMapRadius() -> Int {
        let cameraLocation = self.getMapCenter()
        let mapRegion = self.getMapView().projection.visibleRegion()
        let bottomLeft = CLLocation(latitude: mapRegion.nearLeft.latitude, longitude: mapRegion.nearLeft.longitude)
        return Int(cameraLocation.distanceFromLocation(bottomLeft))
    }


    // implementations MapLocationViewControllerProtocol
    func getMapView() -> GMSMapView {
        return self.viewMap
    }
    func getLocateButton() -> UIButton {
        return self.buttonLocate
    }
    func mapView(mapView: GMSMapView, didTapMarker marker: GMSMarker) -> Bool {
        if let clusterMarker = marker.userData as? ClusterMarker {
            self.viewModel.navigateEventDetailsMap?(id: clusterMarker.event.id)
            return true

        } else if let eventID = marker.userData as? String {
            self.viewModel.navigateEventDetailsMap?(id: eventID)
            return true

        } else {
            return false
        }
    }
    func mapView(mapView: GMSMapView, willMove gesture: Bool) {
        self.onWillCameraMove(gesture)
        self.handleChangeMapView()
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
        print(".displayEvents.count: ", events.count)

        var tmpClusterMarkers: [ClusterMarker] = []
        let eventPromises: [Promise<Void>] = events.map { event in
            return Promise { resolve, reject in
                EventService
                    .updateGeoPointIfNotExists(event)
                    .then { event -> Void in
                        //self.displayMarker(.Event(event: event))
                        let cm = ClusterMarker(event: event)
                        tmpClusterMarkers.append(cm)
                        resolve()
                    }
                    .error { err in
                        switch err {
                        case EventLocationError.NoAddress:
                            print(".displayEvent.error", err, event.title)
                            resolve()
                        case EventLocationError.AddressNotFound:
                            print(".displayEvent.error", err, event.title)
                            resolve()
                        default:
                            reject(err)
                            break;
                        }
                    }
            }
        }

        when(eventPromises)
        .then { _ -> Void in
            self.clusterManager.clearItems()
            self.clusterManager.addItems(tmpClusterMarkers)
            self.clusterMarkerks = tmpClusterMarkers
        }
        .then { _ -> Void in
            self.clusterManager.cluster()
        }
        .error { err in
            print(".displayEvents.when.error", err)
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



