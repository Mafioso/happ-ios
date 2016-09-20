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
    private let storyboard: UIStoryboard

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.storyboard = UIStoryboard(name: "Main", bundle: nil)
    }

    func start() {
        UserService.isCredentialAvailable()
            .then { result in result ? self.showFeed() : self.showSignIn() }
    }

    func showSignIn() {
        print(".nav.showSignIn")

        let viewModel = SignInViewModel()
        viewModel.navigateSignUp = self.showSignUp
        viewModel.navigateFeed = self.showFeed

        let viewController = self.storyboard.instantiateViewControllerWithIdentifier("SignInPage") as! LoginController
        viewController.viewModel = viewModel

        self.navigationController.viewControllers = [viewController]
    }

    func showSignUp() {
        // TODO

        print(".nav.showSignUp", self.navigationController.viewControllers)

        let viewController = self.storyboard.instantiateViewControllerWithIdentifier("SignUpPage") as! SignUpController
        self.navigationController.pushViewController(viewController, animated: true)
    }

    func showFeed() {
        print(".nav.showFeed")

        let viewModel = FeedViewModel()
        let viewController = self.storyboard.instantiateViewControllerWithIdentifier("FeedPage") as! FeedCollectionViewController
        viewController.viewModel = viewModel
        self.navigationController.viewControllers = [viewController]
    }
}

