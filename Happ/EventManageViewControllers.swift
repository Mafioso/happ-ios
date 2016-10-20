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


    func handleCloseButton() {
        self.viewModel.navigateBack?()
    }
    func handlePresentationButton() {
        // TODO
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initNavBarItems()
        self.navigationController?.navigationBar.tintColor = UIColor.happBlackHalfTextColor()
    }

    
    private func initNavBarItems() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon-cross"), style: .Plain, target: self, action: #selector(handleCloseButton))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon-presentation"), style: .Plain, target: self, action: #selector(handlePresentationButton))
    }
}




class EventManageFirstPageViewController: PrototypeEventManageViewController {


    @IBAction func clickedNextButton(sender: UIButton) {
        self.viewModel.navigateNext?()
    }


    override func viewDidLoad() {
        super.viewDidLoad()


    }

}


class EventManageSecondPageViewController: PrototypeEventManageViewController {
    
    
    @IBAction func clickedSubmitButton(sender: UIButton) {
        self.viewModel.navigateBack?()
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
}


