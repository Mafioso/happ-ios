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
import SwiftyJSON


struct MapPlace {
    let name: String
    let photoRef: String
    let address: String
    let location: CLLocation
}

struct MapDirection {
    // NOTE: Route without waypoints contains only one leg in `legs` array
    let legSteps: [JSON]
    let overviewPolylinePoints: String

    func getDistance() -> Double {
        return self.legSteps
            .reduce(0.0, combine: { (var acc, step) in
                acc += step["distance", "value"].doubleValue
                return acc
            })
    }
}

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
    func clearMap()
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

    func displayDirection(direction: MapDirection) {
        let path = GMSPath(fromEncodedPath: direction.overviewPolylinePoints)
        let polyline = GMSPolyline(path: path)
        polyline.strokeColor = UIColor.happOrangeColor()
        polyline.map = self.getMapView()
    }
    func displayMarker(mapMarker: MapMarkerType) {
        var marker = GMSMarker()
        
        switch mapMarker {
        case .MyLocation(let location):
            marker.position = location.coordinate
            marker.icon = UIImage(named: "icon-mylocation")
            marker.map = self.getMapView()

        case .EventPoint(let event):
            let location = CLLocation(geopoint: event.geopoint!)
            marker.position = location.coordinate
            marker.icon = UIImage(named: "icon-position")
            marker.map = self.getMapView()

        case .Event(let event):
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
            let location = CLLocation(geopoint: event.geopoint!)

            // add to map
            marker.groundAnchor = CGPoint(x: 0, y: 1)
            marker.position = location.coordinate
            marker.iconView = eventOnMapView
            marker.userData = event.id
            marker.map = self.getMapView()

        }
        self.markers.append(marker)
        print("..map.displayMarker", self.markers.count)
    }

    func clearMap() {
        self.getMapView().clear()
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


