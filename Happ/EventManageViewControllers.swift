//
//  EventManageFirstPageViewController.swift
//  Happ
//
//  Created by MacBook Pro on 10/18/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit


// Prototype
class PrototypeEventManageViewController: UIViewController {
    
    var viewModel: EventManageViewModel!


    func handlePresentationButton() {
        // TODO
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initNavBarItems()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.extMakeNavBarWhite()
    }


    private func initNavBarItems() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon-presentation"), style: .Plain, target: self, action: #selector(handlePresentationButton))
    }
}




class EventManageFirstPageViewController: PrototypeEventManageViewController {


    // actions
    @IBAction func clickedSelectInterestButton(sender: UIButton) {
        self.viewModel.navigateSelectInterest?()
    }
    @IBAction func clickedNextButton(sender: UIButton) {
        self.viewModel.navigateNext?()
    }


    override func viewDidLoad() {
        super.viewDidLoad()


    }
    override func initNavBarItems() {
        super.initNavBarItems()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "nav-cross-gray"), style: .Plain, target: self, action: #selector(handleCloseNavItem))
    }


    func handleCloseNavItem() {
        self.viewModel.navigateBack?()
    }

}


class EventManageSecondPageViewController: PrototypeEventManageViewController {
    
    
    @IBAction func clickedSubmitButton(sender: UIButton) {
        self.viewModel.navigateBack?()
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func initNavBarItems() {
        super.initNavBarItems()

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "nav-cross-gray"), style: .Plain, target: self, action: #selector(handleBackNavItem))
    }


    func handleBackNavItem() {
        self.viewModel.navigateBack?()
    }

}


