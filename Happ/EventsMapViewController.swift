//
//  EventsMapViewController.swift
//  Happ
//
//  Created by MacBook Pro on 11/15/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit
import GoogleMaps


class EventsMapViewController: UIViewController {


    // outlets
    @IBOutlet weak var viewMap: GMSMapView!
    @IBOutlet weak var viewLocateBackground: UIView!
    @IBOutlet weak var buttonLocate: UIButton!

    // actions
    @IBAction func clickedLocate(sender: UIButton) {
        self.displayMyLocation()
    }

    // variables
    var markers: [GMSMarker] = []
    var myLocationMarker: GMSMarker?
    var countCameraMoves: Int = 0
    var locationManager: CLLocationManager!


    override func viewDidLoad() {
        super.viewDidLoad()

        self.initMap()
        self.initLocationManager()
        self.displayUserCity()
        self.initNavBarItems()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        buttonLocate.extMakeCircle()
        viewLocateBackground.extMakeCircle()

        self.markers.forEach { marker in
            let view = marker.iconView as! EventOnMap
            view.viewRounded.extMakeCircle()
            view.imageCover.extMakeCircle()
        }
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.extMakeNavBarWhite()

        self.displayMarkers()
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        self.extMakeNavBarVisible()
        
        self.markers.forEach { $0.map = nil }
        self.markers = []
        //self.myLocationMarker?.map = nil
        //self.viewMap.clear()
    }


    private func initMap() {
        let camera = GMSCameraPosition.cameraWithLatitude(41.887, longitude: -87.622, zoom: 1)
        self.viewMap.camera = camera
        self.viewMap.delegate = self
    }
    private func displayMarkers() {

        // create view
        let eventOnMapView = NSBundle.mainBundle().loadNibNamed(EventOnMap.nibName, owner: EventOnMap(), options: nil)!.first as! EventOnMap
        eventOnMapView.labelTitle.text = "Dostyk Plaza"
        eventOnMapView.imageCover.hnk_setImageFromURL(NSURL(string: "https://lh6.googleusercontent.com/-G2hnr1-KAFI/V8sdan3RWnI/AAAAAAAAPA8/s78WdbvglKg84RsL2znVr8NLcqU_Mhq6wCJkC/s455-k-no/")!)
        
        // set constraints
        NSLayoutConstraint(item: eventOnMapView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 39).active = true

        // add to map
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: 43.233018, longitude: 76.955978)
        marker.tracksViewChanges = true
        marker.iconView = eventOnMapView
        marker.map = self.viewMap

        self.markers.append(marker)
    }
    private func displayUserCity() {
        let userCity = ProfileService.getUserCity()
        CityService.fetchCityLocation(userCity.id)
            .then { data -> Void in
                let location = data as! CLLocation
                let updCamera = GMSCameraUpdate.setTarget(location.coordinate)
                self.viewMap.moveCamera(updCamera)
        }
    }
    private func updateLocateButton(isActive: Bool) {
        if isActive {
            self.countCameraMoves = 0
        }

        self.buttonLocate.selected = isActive
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


extension EventsMapViewController: GMSMapViewDelegate {
    func mapView(mapView: GMSMapView, didChangeCameraPosition position: GMSCameraPosition) {
        self.countCameraMoves += 1

        if self.myLocationMarker != nil && self.countCameraMoves > 1 {
            self.updateLocateButton(false)
        }
    }

    func mapView(mapView: GMSMapView, didTapMarker marker: GMSMarker) -> Bool {
        if marker == self.myLocationMarker {
            return false // skip
        }
        return true
    }
}


extension EventsMapViewController: CLLocationManagerDelegate {

    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            self.locationManager.startUpdatingLocation()
        }
    }
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            self.locationManager.stopUpdatingLocation()
            self.displayMyLocation(location)
        }
    }

    private func initLocationManager() {
        self.locationManager = {
            let manager = CLLocationManager()
            manager.delegate = self
            manager.desiredAccuracy = kCLLocationAccuracyBest
            manager.requestWhenInUseAuthorization()
            return manager
        }()

        // we don't use default blue-dot for present current location
        self.viewMap.myLocationEnabled = false

        // if already has authorization
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            self.locationManager.startUpdatingLocation()
        }
    }
    private func updateMyLocationMarker(location: CLLocation) {
        if let oldMarker = self.myLocationMarker {
            oldMarker.map = nil
        }

        self.myLocationMarker = {
            let newMarker = GMSMarker(position: location.coordinate)
            newMarker.icon = UIImage(named: "icon-mylocation")
            newMarker.map = self.viewMap
            return newMarker
        }()
    }
    private func displayMyLocation(location: CLLocation? = nil) {
        if location != nil {
            let camera = GMSCameraPosition(target: location!.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            self.viewMap.camera = camera
            self.updateMyLocationMarker(location!)
            self.updateLocateButton(true)
        } else {
            self.viewMap.animateToLocation(self.myLocationMarker!.position)
            self.updateLocateButton(true)
        }
    }
}







