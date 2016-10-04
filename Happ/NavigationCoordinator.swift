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


/*
 auth:   SignIn     ->  SignUp      ->  profile.SelectCityInterest  ->  profile.SelectCity
                                                                    ->  main.Feed
                    ->  main.Feed

 main:  vared       ->  event.EventDetails
                    ->  event.EventForm
                    ->  event.EventsManage
                    ->  profile.Profile

 profile: Profile   ->  profile.SelectCity
*/


typealias NavigationFunc = (() -> Void)?
typealias NavigationFuncWithID = ((id: String) -> Void)?


class NavigationCoordinator {

    private let window: UIWindow
    private var navigationController: UINavigationController!
    private let authStoryboard: UIStoryboard
    private let mainStoryboard: UIStoryboard
    private let eventStoryboard: UIStoryboard
    private let profileStoryboard: UIStoryboard


    init(window: UIWindow) {
        self.window = window

        self.mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        self.authStoryboard = UIStoryboard(name: "Authentication", bundle: nil)
        self.eventStoryboard = UIStoryboard(name: "Event", bundle: nil)
        self.profileStoryboard = UIStoryboard(name: "Profile", bundle: nil)
    }

    func start() {
        //self.startSelectCityInterests()
        AuthenticationService.isCredentialAvailable()
            .then { result in result ? self.startFeed() : self.startSignIn() }
    }

    func goBack() {
        print(".nav.goBack")
        self.navigationController.popViewControllerAnimated(true)
    }

    func logOut() {
        print(".nav.LogOut")
        AuthenticationService.logOut()
        self.start()
    }

    func startSignIn() {
        print(".nav.showSignIn")
        let viewModel = AuthenticationViewModel()
        viewModel.navigateSignUp = self.showSignUp
        viewModel.navigateFeed = self.startFeed

        let viewController = self.authStoryboard.instantiateViewControllerWithIdentifier("SignInPage") as! LoginController
        viewController.viewModel = viewModel

        self.navigationController = UINavigationController(rootViewController: viewController)
        self.window.rootViewController = self.navigationController
        self.window.makeKeyAndVisible()
    }

    func showSignUp() {
        print(".nav.showSignUp")
        let viewModel = AuthenticationViewModel()
        viewModel.navigateSelectCityInterests = self.startSelectCityInterests
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
        viewModel.displaySlideFeedFilters = self.displaySlideFeedFilters

        let viewController = self.mainStoryboard.instantiateViewControllerWithIdentifier("FeedPage") as! FeedViewController
        viewController.viewModel = viewModel
        
        let filtersViewController = self.mainStoryboard.instantiateViewControllerWithIdentifier("FeedFilters") as! FeedFiltersController
        filtersViewController.viewModel = viewModel


        self.navigationController = UINavigationController(rootViewController: viewController)
        self.window.rootViewController = self.initSlideMenu(navigationController, rightMenu: filtersViewController)
        self.window.makeKeyAndVisible()
    }

    func showEventDetails(forID: String) {
        print(".nav.showEventDetails [forID=\(forID)]")
        let viewModel = EventViewModel(forID: forID)

        let viewController = self.eventStoryboard.instantiateViewControllerWithIdentifier("EventDetails") as! EventDetailsController
        viewController.viewModel = viewModel
        self.navigationController.pushViewController(viewController, animated: true)
    }

    func startSelectCityInterests() {
        print(".profile.showSelectCityInterests")
        let viewModel = SelectCityInterestsViewModel()
        viewModel.navigateSelectCity = self.showSelectCity(viewModel)
        viewModel.navigateFeed = self.startFeed

        let viewController = self.profileStoryboard.instantiateViewControllerWithIdentifier("SelectCityInterests") as! SelectCityInterestsViewController
        viewController.viewModel = viewModel

        self.navigationController = UINavigationController(rootViewController: viewController)
        self.window.rootViewController = self.navigationController
        self.window.makeKeyAndVisible()
    }

    func showSelectCity(parentViewModel: SelectCityInterestsViewModel) -> NavigationFunc {
        return {
            print(".profile.showSelectCity")
            parentViewModel.navigateBack = self.goBack

            let viewController = self.profileStoryboard.instantiateViewControllerWithIdentifier("SelectCity") as! SelectCityViewController
            viewController.viewModel = parentViewModel
            self.navigationController.pushViewController(viewController, animated: true)
        }
    }

    func showSettings() {
        print(".profile.showSettings")
        let viewModel = SettingsViewModel()
        viewModel.navigateSelectCurrency = self.showSelectCurrency(viewModel)
        // viewModel.navigateSelectCity = TODO

        let viewController = self.profileStoryboard.instantiateViewControllerWithIdentifier("Settings") as! SettingsController
        viewController.viewModel = viewModel
        self.navigationController.pushViewController(viewController, animated: true)
    }

    func showSelectCurrency(parentViewModel: SettingsViewModel) -> NavigationFunc {
        return {
            print(".profile.showSelectCurrency")
            parentViewModel.navigateBack = self.goBack

            let viewController = self.profileStoryboard.instantiateViewControllerWithIdentifier("SelectCurrency") as! SelectCurrencyViewController
            viewController.viewModel = parentViewModel
            self.navigationController.pushViewController(viewController, animated: true)
        }
    }

    func showProfile() {
        print(".profile.showProfile")
        let viewModel = ProfileViewModel()
        viewModel.navigateBack = self.goBack
        viewModel.navigateChangePassword = self.showChangePassword(viewModel)

        let viewController = self.profileStoryboard.instantiateViewControllerWithIdentifier("Profile") as! ProfileController
        viewController.viewModel = viewModel
        self.navigationController.pushViewController(viewController, animated: true)
    }

    func showChangePassword(parentViewModel: ProfileViewModel) -> NavigationFunc {
        return {
            print(".profile.showChangePassword")
            parentViewModel.navigateBack = self.goBack

            let viewController = self.profileStoryboard.instantiateViewControllerWithIdentifier("ChangePassword") as! ChangePasswordController
            viewController.viewModel = parentViewModel
            self.navigationController.pushViewController(viewController, animated: true)
            
        }
    }


    private func displaySlideMenu() {
        if let slideMenu = self.window.rootViewController as? SlideMenuController {
            slideMenu.openLeft()
        }
    }
    private func displaySlideFeedFilters() {
        if let slideMenu = self.window.rootViewController as? SlideMenuController {
            slideMenu.openRight()
        }
    }

    private func hideSlideMenu() {
        if let slideMenu = self.window.rootViewController as? SlideMenuController {
            slideMenu.closeLeft()
        }
    }
    private func hideSlideMenu(navigate: NavigationFunc) -> NavigationFunc {
        return {
            navigate?()
            self.hideSlideMenu()
        }
    }
    private func hideSlideFeedFilters() {
        if let slideMenu = self.window.rootViewController as? SlideMenuController {
            slideMenu.closeLeft()
        }
    }
    

    private func initSlideMenu(rootView: UIViewController, rightMenu: UIViewController) -> SlideMenuController {
        let viewModel = MenuViewModel()
        viewModel.navigateProfile = self.hideSlideMenu(self.showProfile)
        viewModel.navigateFeed = self.hideSlideMenu(self.startFeed)
        viewModel.navigateSettings = self.hideSlideMenu(self.showSettings)
        viewModel.navigateLogout = self.hideSlideMenu(self.logOut)

        let menuViewController = self.mainStoryboard.instantiateViewControllerWithIdentifier("Menu") as! MenuViewController
        menuViewController.viewModel = viewModel

        let slideMenuController = SlideMenuController(mainViewController: rootView, leftMenuViewController: menuViewController, rightMenuViewController: rightMenu)
        return slideMenuController
    }
}
