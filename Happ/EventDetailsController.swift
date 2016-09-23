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
    @IBOutlet weak var viewFirstContainer: UIView!
    @IBOutlet weak var viewSecondContainer: UIView!
    @IBOutlet weak var constraintHeightOfFirstContainer: NSLayoutConstraint!
    @IBOutlet weak var constraintHeightOfSecondContainer: NSLayoutConstraint!
    @IBOutlet weak var imageBackground: UIImageView!


    @IBOutlet weak var labelCategory: UILabel!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelPriceRange: UILabel!
    @IBOutlet weak var labelDateRange: UILabel!
    @IBOutlet weak var labelLocation: UILabel!

    @IBOutlet weak var labelSecondCategory: UILabel!
    @IBOutlet weak var labelSecondTitle: UILabel!
    @IBOutlet weak var labelSecondDescription: UILabel!
    
    
    @IBAction func clickedActionOnFirstContainer(sender: UIButton) {
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = viewSecondContainer.bounds
        gradient.colors = [UIColor(red: 155.0/255.0, green: 155.0/255.0, blue: 155.0/255.0, alpha: 1.0).CGColor, UIColor(red: 51.0/255.0, green: 51.0/255.0, blue: 51.0/255.0, alpha: 0.3).CGColor]
        viewSecondContainer.layer.insertSublayer(gradient, atIndex: 0)


        self.viewModelDidUpdate()
    }
    
    override func viewWillAppear(animated: Bool) {
        let h = UIScreen.mainScreen().bounds.size.height
        constraintHeightOfFirstContainer.constant = h
        constraintHeightOfSecondContainer.constant = h
    }


    func viewModelDidUpdate() {
        if let event = viewModel.event {

            if let image = event.images[0] {
                imageBackground.hnk_setImageFromURL(image)
            }

            labelTitle.text = event.title
            labelSecondTitle.text = event.title
            labelDateRange.text = HappDateFormats.EventOnFeed.toString(event.start_datetime!)
        }
    }

    private func bindToViewModel() {
        self.viewModel.didUpdate = { [weak self] _ in
            self?.viewModelDidUpdate()
        }
    }
}




