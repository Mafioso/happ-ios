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
    @IBOutlet weak var viewMap: UIView!
    @IBOutlet weak var viewLocateBackground: UIView!
    @IBOutlet weak var buttonLocate: UIButton!
    
    // actions
    @IBAction func clickedLocate(sender: UIButton) {
        
    }
    
    // variables
    var markers: [GMSMarker] = []


    override func viewDidLoad() {
        super.viewDidLoad()

        viewLocateBackground.extMakeCircle()
        buttonLocate.extMakeCircle()

        self.initMap()
        self.initNavBarItems()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.displayMarkers()
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.markers.forEach { $0.map = nil }
        self.markers = []
    }



    private func displayMarkers() {
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
        marker.title = "Sydney"
        marker.snippet = "Australia"
        marker.map = self.viewMap as? GMSMapView

        self.markers.append(marker)
    }
    private func initMap() {
        let camera = GMSCameraPosition.cameraWithLatitude(-33.86, longitude: 151.20, zoom: 4.0)
        let mapView = GMSMapView.mapWithFrame(CGRect.zero, camera: camera)
        mapView.myLocationEnabled = true
        //self.viewMap = mapView
        view = mapView

        ///view = mapView
        if #available(iOS 9.0, *) {
            self.loadViewIfNeeded()
        } else {
            // TODO
        }
    }
    private func initNavBarItems() {
        self.navigationItem.title = "Events near you"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "nav-menu-gray"), style: .Plain, target: self, action: #selector(handleClickMenuNavItem))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "nav-filter-gray"), style: .Plain, target: self, action: #selector(handleClickMenuNavItem))
    }
    func handleClickMenuNavItem() {
       // self.viewModel.displaySlideMenu?() TODO uncomment
    }
}



