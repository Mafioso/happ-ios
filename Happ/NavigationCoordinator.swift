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
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        UserService.isCredentialAvailable()
            .then { result in result ? self.showFeed() : self.showSignIn() }
    }

    func showSignIn() {
        let viewModel = SignInViewModel()
        viewModel.navigateSignUp = self.showSignUp()
        viewModel.navigateFeed = self.showFeed()

        let viewController = LoginController(viewModel: viewModel)
        self.navigationController.pushViewController(viewController, animated: true)
    }

    func showSignUp() {
        // TODO
    }

    func showFeed() {
        let viewModel = FeedViewModel
        let viewController = FeedViewController(viewModel: viewModel)
        self.navigationController.showViewController(viewController, sender: self)
    }
}

