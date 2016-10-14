//
//  EventDetailsController.swift
//  Happ
//
//  Created by Aigerim'sMac on 21.09.16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit

class EventDetailsController: UIViewController {

    var viewModel: EventViewModel! {
        didSet {
            self.bindToViewModel()
        }
    }


    // outlets
    @IBOutlet weak var imageBackground: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelPriceMinimum: UILabel!
    @IBOutlet weak var labelDateRange: UILabel!
    @IBOutlet weak var labelLocation: UILabel!
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var labelAuthorName: UILabel!
    @IBOutlet weak var labelAuthorDetails: UILabel!
    @IBOutlet weak var imageAuthorPhoto: UIImageView!
    
    @IBOutlet weak var buttonInfoDate: UIButton!
    @IBOutlet weak var buttonInfoPrice: UIButton!
    @IBOutlet weak var buttonInfoLocation: UIButton!
    @IBOutlet weak var buttonUpvote: UIButton!
    @IBOutlet weak var buttonWantToGo: UIButton!

    @IBOutlet weak var tableViewInfo: UITableView!

    // actions
    @IBAction func clickedWantToGoButton(sender: UIButton) {
    }
    @IBAction func clickedUpvote(sender: UIButton) {
    }
    
    


    override func viewDidLoad() {
        super.viewDidLoad()

        [buttonInfoDate, buttonInfoPrice, buttonInfoLocation]
            .forEach { button in
                //button.layer.cornerRadius = 0.5 * button.bounds.size.width
                //button.clipsToBounds = true

                //button.layer.masksToBounds = true
        }
        [buttonUpvote, buttonWantToGo]
            .forEach { button in
                button.layer.cornerRadius = 20
                button.layer.masksToBounds = true
        }


        self.initNavigationBarItems()
        self.viewModelDidUpdate()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.extMakeStatusBarWhite()
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        self.extMakeStatusBarDefault()
    }
    

    func viewModelDidUpdate() {
        if let event = viewModel.event {

            if let image = event.images[0] {
                imageBackground.hnk_setImageFromURL(image)
            }

            labelTitle.text = event.title
            labelDescription.text = event.description_text
            // TODO
            labelDateRange.text = HappDateFormats.EventOnFeed.toString(event.start_datetime!)
            labelLocation.text = event.address
            labelPriceMinimum.text = event.getPrice(.MinPrice)
        }
    }

    private func bindToViewModel() {
        self.viewModel.didUpdate = { [weak self] _ in
            self?.viewModelDidUpdate()
        }
    }


    private func initNavigationBarItems() {
        let navBarBack = HappNavBarItem(position: .Left, icon: "back")
        navBarBack.button.addTarget(self, action: #selector(handleClickNavBarBack), forControlEvents: .TouchUpInside)
        self.view.addSubview(navBarBack)
        
        let navBarFavourite = HappNavBarItem(position: .Right, icon: "fav-icon")
        navBarFavourite.button.addTarget(self, action: #selector(handleClickNavBarFavourite), forControlEvents: .TouchUpInside)
        self.view.addSubview(navBarFavourite)
    }
    func handleClickNavBarFavourite() {
        // todo
    }
    func handleClickNavBarBack() {
        self.viewModel.navigateBack?()
    }
}



