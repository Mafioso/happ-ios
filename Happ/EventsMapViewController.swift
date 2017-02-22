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


let loc_events_near_you = NSLocalizedString("Events near you", comment: "Title of NavBar for EventsMapViewController")


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
    var progressView: UIProgressView!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.edgesForExtendedLayout = .None

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

        self.zoomToUserCity()
        self.initProgressBar()
        self.handleChangeMapView()
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
    func clusterManager(clusterManager: GMUClusterManager, didTapCluster cluster: GMUCluster) {
        let map = self.getMapView()
        let newCamera = GMSCameraPosition.cameraWithTarget(cluster.position, zoom: map.camera.zoom + 1)
        let update = GMSCameraUpdate.setCamera(newCamera)
        map.moveCamera(update)
    }

    func initMapCluster() {
        let iconGenerator = GMUDefaultClusterIconGenerator()
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = ClusterRenderer(mapView: self.getMapView(), clusterIconGenerator: iconGenerator)
        renderer.delegate = self
        self.clusterManager = GMUClusterManager(map: self.getMapView(), algorithm: algorithm,renderer: renderer)
        self.clusterManager.setDelegate(self, mapDelegate: self)
    }
    func initLocation() {
        firstly { _ -> Promise<CLLocation> in
            self.locationState = MapLocationState()
            return self.getLocation()
        }
        .then { myLocation -> Void in
            self.locationState = MapLocationState(location: myLocation)
            self.displayMarker(.MyLocation(location: myLocation))
            self.updateMapLocationViews()
        }
        .error { err in
            print(".initLocation.error", err)
        }
    }

    func handleChangeMapView() {
        guard !self.viewModel.state.isFetching else { return }

        let center = self.getMapCenter()
        let radius = self.getMapRadius()
        print(".mapView.change", center.coordinate, radius)
        
        self.startProgressBar()
        self.viewModel.onChangeMapPosition(center, radius: radius) { AsyncState in
            self.viewModel.state = AsyncState
            self.finishProgressBar()
        }
    }

    func startProgressBar() {
        self.progressView.hidden = false
        self.progressView.progress = 0.0
        let third: Double = 1/3
        UIView.animateKeyframesWithDuration(5.0, delay: 0, options: .CalculationModeLinear,animations: {
            UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: third, animations: {
                self.progressView.progress = 0.1
            })
            UIView.addKeyframeWithRelativeStartTime(third, relativeDuration: third, animations: {
                self.progressView.progress = 0.3
            })
            UIView.addKeyframeWithRelativeStartTime(2*third, relativeDuration: third, animations: {
                self.progressView.progress = 0.5
            })
            }, completion: nil)
    }
    func finishProgressBar() {
        self.progressView.layer.removeAllAnimations()
        UIView.animateWithDuration(1.0, animations: {
            self.progressView.progress = 1.0
        }, completion: { _ in
            self.hideProgressBar()
        })
    }
    func hideProgressBar() {
        UIView.animateWithDuration(1.0, animations: {
            self.progressView.hidden = true
        }, completion: nil)
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
        self.viewModel.onChangeFilters(filters) // it clears state
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

    
    private func displayEventMarkers() {
        let events = self.viewModel.state.items
        print(".displayEvents.count: ", events.count)

        let tmpClusterMarkers = events.map { ClusterMarker(event: $0) }
        self.clusterManager.clearItems()
        self.clusterManager.addItems(tmpClusterMarkers)
        self.clusterMarkerks = tmpClusterMarkers
        self.clusterManager.cluster()
    }

    private func initNavBarItems() {
        self.navigationItem.title = loc_events_near_you
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "nav-menu"), style: .Plain, target: self, action: #selector(handleClickMenuNavItem))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "nav-filter-gray"), style: .Plain, target: self, action: #selector(handleClickFilterNavItem))
    }
    private func initProgressBar() {
        self.progressView = {
            let p = UIProgressView(progressViewStyle: .Default)
            let width = UIScreen.mainScreen().bounds.width
            p.frame = CGRectMake(0, 64, width, p.frame.height)
            p.progressTintColor = UIColor.happOrangeColor()
            self.view.addSubview(p)
            return p
        }()
        print("..progress.init.", self.progressView.frame)
    }
    
    func handleClickMenuNavItem() {
        self.viewModel.displaySlideMenu?()
    }
    func handleClickFilterNavItem() {
    }
}



