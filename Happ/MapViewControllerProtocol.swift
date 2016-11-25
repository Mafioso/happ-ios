//
//  MapViewControllerProtocol.swift
//  Happ
//
//  Created by MacBook Pro on 11/24/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps



enum MapMarkerType {
    case MyLocation(location: CLLocation)
    case EventPoint(event: EventModel)
    case Event(event: EventModel)
}

protocol MapViewControllerProtocol: class, GMSMapViewDelegate {
    func initMap()
    // variables:
    var markers: [GMSMarker] { get set }
    func getMapView() -> GMSMapView
    // actions:
    func updateMap(coordinate: CLLocationCoordinate2D, zoom: Float)
    func displayMarker(mapMarker: MapMarkerType)
    func destroyMarkers()
    // inputs:
    func onDidMapLayoutSubviews()
}

extension MapViewControllerProtocol where Self: UIViewController {

    func initMap() {
        let camera = GMSCameraPosition.cameraWithLatitude(41.887, longitude: -87.622, zoom: 1)
        self.getMapView().camera = camera
        self.getMapView().delegate = self
        self.getMapView().myLocationEnabled = false
        //NOTE: we don't use default blue-dot for present my location
    }

    func updateMap(coordinate: CLLocationCoordinate2D, zoom: Float) {
        let updCamera = GMSCameraUpdate.setTarget(coordinate, zoom: zoom)
        self.getMapView().animateWithCameraUpdate(updCamera)
    }
    
    func displayMarker(mapMarker: MapMarkerType) {
        var marker = GMSMarker()
        
        switch mapMarker {
        case .MyLocation(let location):
            marker.position = location.coordinate
            marker.icon = UIImage(named: "icon-mylocation")
            marker.map = self.getMapView()

        case .EventPoint(let event):
            let eventLocation = CLLocation(latitude: 43.233018, longitude: 76.955978)
            marker.position = eventLocation.coordinate
            marker.icon = UIImage(named: "icon-position")
            marker.map = self.getMapView()
            
        case .Event(let event):
            // create view
            let eventOnMapView = NSBundle.mainBundle().loadNibNamed(EventOnMap.nibName, owner: EventOnMap(), options: nil)!.first as! EventOnMap
            eventOnMapView.labelTitle.text = event.title
            if let colorValue = event.color {
                let color = UIColor(hexString: colorValue)
                eventOnMapView.viewRounded.backgroundColor = color
                eventOnMapView.viewTriangle.backgroundColor = color
            }
            if  let imageURL = event.images.first {
                eventOnMapView.imageCover.hnk_setImageFromURL(imageURL!)
            }
            let eventLocation = CLLocation(latitude: 43.233018, longitude: 76.955978)

            // add to map
            marker.groundAnchor = CGPoint(x: 0, y: 1)
            marker.position = eventLocation.coordinate
            marker.iconView = eventOnMapView
            marker.userData = event.id
            marker.map = self.getMapView()
        }
        self.markers.append(marker)
        print("..map.displayMarker", self.markers.count)
    }

    func destroyMarkers() {
        self.markers.forEach { $0.map = nil }
        self.markers = []
    }
    
    func onDidMapLayoutSubviews() {
        print("..map.onDidMapLayoutSubviews", self.markers.count)
        self.markers.forEach { marker in
            if let view = marker.iconView as? EventOnMap {
                view.viewRounded.extMakeCircle()
                view.imageCover.extMakeCircle()
            }
        }
    }
}


