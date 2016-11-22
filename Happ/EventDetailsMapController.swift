//
//  EventDetailsMapController.swift
//  Happ
//
//  Created by MacBook Pro on 11/21/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit
import GoogleMaps


class EventDetailsMapController: UIViewController, MapViewControllerProtocol {

    var viewModel: EventOnMapViewModel!


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
    }
    @IBAction func clickedLocateButton(sender: UIButton) {
    }

    // variables
    var markers: [GMSMarker] = []


    override func viewDidLoad() {
        super.viewDidLoad()

        self.initMap()
        self.initNavItems()

        self.updateViews()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

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
                self.updateMap(location.coordinate, zoom: 15)
        }
    }
    func updateViews() {
        let event = self.viewModel.event
    
        if let imageURL = event.images.first {
            imageEventCover.hnk_setImageFromURL(imageURL!)
        }
        labelEventTitle.text = event.title
        labelEventPrice.text = event.getPrice(.Range)
        labelEventDate.text = HappDateFormats.EventOnFeed.toString(event.start_datetime!)
        labelEventLocation.text = event.address
        labelDistance.text = "? km"

        self.displayMarker(.EventPoint(event: event))
        self.updateMap(self.markers.last!.position, zoom: 12)
    }



    // implement MapViewControllerProtocol
    func getMapView() -> GMSMapView {
        return self.viewMap
    }


    private func initNavItems() {
        self.navigationItem.title = "Event location"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "nav-close"), style: .Plain, target: self, action: #selector(handleClickCloseNavItem))
    }
    func handleClickCloseNavItem() {
        self.viewModel.navigateBack?()
    }
}



