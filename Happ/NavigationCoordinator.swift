//
//  NavigationCoordinator.swift
//  Happ
//
//  Created by MacBook Pro on 9/19/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit
import PromiseKit
import SlideMenuControllerSwift


typealias NavigationFunc = (() -> Void)?
typealias NavigationFuncWithID = ((id: String) -> Void)?


class NavigationCoordinator {

    private let window: UIWindow
    private var navigationController: UINavigationController!
    private let authStoryboard: UIStoryboard
    private let mainStoryboard: UIStoryboard
    private let eventStoryboard: UIStoryboard

    /*
        auth:   SignIn  ->  SignUp      ->  profile.SelectCity  ->  main.Feed
                        ->  main.Feed

        main:   Feed    ->  event.EventDetails
                        ->  event.EventForm
                        ->  event.EventsManage
                        ->  profile.Profile

        profile: Profile    ->  profile.SelectCity
    */

    init(window: UIWindow) {
        self.window = window

        self.mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        self.authStoryboard = UIStoryboard(name: "Authentication", bundle: nil)
        self.eventStoryboard = UIStoryboard(name: "Event", bundle: nil)
    }

    func start() {
        UserService.isCredentialAvailable()
            .then { result in result ? self.startFeed() : self.startSignIn() }
    }

    func startSignIn() {
        print(".nav.showSignIn")
        let viewModel = AuthenticationViewModel()
        viewModel.navigateSignUp = self.showSignUp
        viewModel.navigateFeed = self.startFeed

        let viewController = self.authStoryboard.instantiateViewControllerWithIdentifier("SignInPage") as! LoginController
        viewController.viewModel = viewModel

        self.navigationController = UINavigationController()
        self.navigationController.viewControllers = [viewController]
        self.window.rootViewController = self.navigationController
        self.window.makeKeyAndVisible()
    }

    func showSignUp() {
        print(".nav.showSignUp")
        let viewModel = AuthenticationViewModel()
        viewModel.navigateFeed = self.startFeed

        let viewController = self.authStoryboard.instantiateViewControllerWithIdentifier("SignUpPage") as! SignUpController
        viewController.viewModel = viewModel
        self.navigationController.pushViewController(viewController, animated: true)
    }


    func startFeed() {
        print(".nav.showFeed")
        let viewModel = FeedViewModel()
        viewModel.navigateEventDetails = self.showEventDetails
        viewModel.displaySlideMenu = self.displaySlideMenu

        let viewController = self.mainStoryboard.instantiateViewControllerWithIdentifier("FeedPage") as! FeedCollectionViewController
        viewController.viewModel = viewModel


        // init Slide menu
        let menuViewController = self.mainStoryboard.instantiateViewControllerWithIdentifier("Menu")

        let slideMenuController = SlideMenuController(mainViewController: viewController, leftMenuViewController: menuViewController)
        self.window.rootViewController = slideMenuController
        self.window.makeKeyAndVisible()
    }

    func showEventDetails(forID: String) {
        print(".nav.showEventDetails [forID=\(forID)]")
        let viewModel = EventViewModel(forID: forID)

        let viewController = self.eventStoryboard.instantiateViewControllerWithIdentifier("EventDetails") as! EventDetailsController
        viewController.viewModel = viewModel
        self.navigationController.pushViewController(viewController, animated: true)
    }
    

    func displaySlideMenu() {
        if let slideMenu = self.window.rootViewController as? SlideMenuController {
            slideMenu.openLeft()
        }
    }
}





