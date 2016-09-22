//
//  NavigationCoordinator.swift
//  Happ
//
//  Created by MacBook Pro on 9/19/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit
import PromiseKit


typealias NavigationFunc = (() -> Void)?


class NavigationCoordinator {
    
    private let navigationController: UINavigationController
    private let authStoryboard: UIStoryboard
    private let mainStoryboard: UIStoryboard
    private let eventStoryboard: UIStoryboard


    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        self.authStoryboard = UIStoryboard(name: "Authentication", bundle: nil)
        self.eventStoryboard = UIStoryboard(name: "Event", bundle: nil)
    }

    func start() {
        UserService.isCredentialAvailable()
            .then { result in result ? self.showFeed() : self.showSignIn() }
    }

    func showSignIn() {
        print(".nav.showSignIn")
        let viewModel = AuthenticationViewModel()
        viewModel.navigateSignUp = self.showSignUp
        viewModel.navigateFeed = self.showFeed

        let viewController = self.authStoryboard.instantiateViewControllerWithIdentifier("SignInPage") as! LoginController
        viewController.viewModel = viewModel

        self.navigationController.viewControllers = [viewController]
    }

    func showSignUp() {
        print(".nav.showSignUp")
        let viewModel = AuthenticationViewModel()
        viewModel.navigateFeed = self.showFeed

        let viewController = self.authStoryboard.instantiateViewControllerWithIdentifier("SignUpPage") as! SignUpController
        viewController.viewModel = viewModel
        self.navigationController.pushViewController(viewController, animated: true)
    }

    func showFeed() {
        print(".nav.showFeed")
        let viewModel = FeedViewModel()
        
        let viewController = self.mainStoryboard.instantiateViewControllerWithIdentifier("FeedPage") as! FeedCollectionViewController
        viewController.viewModel = viewModel
        self.navigationController.viewControllers = [viewController]
    }
}

