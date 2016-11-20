//
//  AfterSignupSelectCityController.swift
//  Happ
//
//  Created by MacBook Pro on 11/8/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import Foundation
import UIKit


class SelectCityOnSetupController: SelectCityPrototype {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.initNavBarItems()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.extMakeNavBarWhite()
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.extMakeNavBarVisible()
    }


    private func initNavBarItems() {
        self.navigationItem.title = "Select Your City"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "nav-close-orange"), style: .Plain, target: self, action: #selector(handleClickNavItemClose))
    }
    func handleClickNavItemClose() {
        let vm = self.viewModel as! SelectCityOnSetupViewModel
        vm.navigateBack?()
    }
}



