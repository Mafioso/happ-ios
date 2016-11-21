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
        self.viewModel.onClickOpen()
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

        let userCity = ProfileService.getUserCity()
        CityService.fetchCityLocation(userCity.id)
            .then { data -> Void in
                let location = data as! CLLocation
                self.updateMap(location.coordinate, zoom: 15)
        }
        
        self.updateViews()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        buttonRoute.extMakeCircle()
        buttonLocate.extMakeCircle()
        viewButtonRouteBackground.extMakeCircle()
        viewButtonLocateBackground.extMakeCircle()

        self.onDidMapLayoutSubviews()
    }

    
    func updateViews() {
        let event = self.viewModel.event
        self.displayMarker(.EventPoint(event: event))

        if let imageURL = event.images.first {
            imageEventCover.hnk_setImageFromURL(imageURL!)
        }
        labelEventTitle.text = event.title
        labelEventPrice.text = event.getPrice(.Range)
        labelEventDate.text = HappDateFormats.EventOnFeed.toString(event.start_datetime!)
        labelEventLocation.text = event.address
        labelDistance.text = "? km"
    }



    // implement MapViewControllerProtocol
    func getMapView() -> GMSMapView {
        return self.viewMap
    }

}



