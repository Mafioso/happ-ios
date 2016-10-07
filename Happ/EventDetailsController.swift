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
    @IBOutlet weak var scrollView: UIScrollView!
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
    
    @IBOutlet weak var buttonWantToGo: UIButton!
    
    @IBAction func clickedActionOnFirstContainer(sender: UIButton) {
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        self.automaticallyAdjustsScrollViewInsets = false
        
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = viewSecondContainer.bounds
        gradient.colors = [UIColor(red: 155.0/255.0, green: 155.0/255.0, blue: 155.0/255.0, alpha: 1.0).CGColor, UIColor(red: 51.0/255.0, green: 51.0/255.0, blue: 51.0/255.0, alpha: 0.3).CGColor]
        viewSecondContainer.layer.insertSublayer(gradient, atIndex: 0)

        //button customization
        buttonWantToGo.layer.borderColor = UIColor.whiteColor().CGColor
        buttonWantToGo.layer.borderWidth = 1
        buttonWantToGo.layer.cornerRadius = 5
        buttonWantToGo.layer.masksToBounds = true

        self.viewModelDidUpdate()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.extMakeNavBarTransparent(UIColor.whiteColor())
        self.extMakeStatusBarWhite()

        let h = UIScreen.mainScreen().bounds.size.height
        constraintHeightOfFirstContainer.constant = h
        constraintHeightOfSecondContainer.constant = h
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

            let interestName = event.interests.first?.title
            labelCategory.text = interestName
            labelSecondCategory.text = interestName

            labelTitle.text = event.title
            labelSecondTitle.text = event.title
            labelSecondDescription.text = event.description_text
            labelDateRange.text = HappDateFormats.EventOnFeed.toString(event.start_datetime!)
        }
    }

    private func bindToViewModel() {
        self.viewModel.didUpdate = { [weak self] _ in
            self?.viewModelDidUpdate()
        }
    }
}




