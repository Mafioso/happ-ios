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



class HappTabBarController: UITabBarController {

    var navigateFeedTab: NavigationFunc = nil
    var navigateFavouriteTab: NavigationFunc = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // tab controllers
        let tabExplore = HappNavigationController()
        let tabMap = HappNavigationController()
        let tabFeed = HappNavigationController()
        let tabFavourite = HappNavigationController()
        let tabChat = HappNavigationController()

        // tab items
        let tabItemExplore = UITabBarItem(title: "Explore", image: nil, selectedImage: nil)
        let tabItemMap = UITabBarItem(title: "Map", image: nil, selectedImage: nil)
        let tabItemFeed = UITabBarItem(title: "Feed", image: UIImage(named: "tabs-tab"), selectedImage: UIImage(named: "tabs-tab"))
        let tabItemFavourite = UITabBarItem(title: "Favourite", image: UIImage(named: "bookmark-icon"), selectedImage: UIImage(named: "bookmark-icon"))
        let tabItemChat = UITabBarItem(title: "Chat", image: nil, selectedImage: nil)

        tabExplore.tabBarItem = tabItemExplore
        tabMap.tabBarItem = tabItemMap
        tabFeed.tabBarItem = tabItemFeed
        tabFavourite.tabBarItem = tabItemFavourite
        tabChat.tabBarItem = tabItemChat

        // add them
        self.viewControllers = [tabExplore, tabMap, tabFeed, tabFavourite, tabChat]
        self.hidesBottomBarWhenPushed = true

    }

    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        let selectedAt = tabBar.items!.indexOf(item)!
        switch selectedAt {
        case 2:
            self.navigateFeedTab?()
        case 3:
            self.navigateFavouriteTab?()
        default:
            break
        }
    }
}

class HappNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBarHidden = true
    }
}


class NavigationCoordinator {

    private let authStoryboard: UIStoryboard
    private let mainStoryboard: UIStoryboard
    private let eventStoryboard: UIStoryboard
    private let profileStoryboard: UIStoryboard

    private let window: UIWindow
    private var navigationController: UINavigationController!
    private var tabBarController: HappTabBarController!


    init(window: UIWindow) {
        self.window = window

        self.mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        self.authStoryboard = UIStoryboard(name: "Authentication", bundle: nil)
        self.eventStoryboard = UIStoryboard(name: "Event", bundle: nil)
        self.profileStoryboard = UIStoryboard(name: "Profile", bundle: nil)
    }

    func start() {
        AuthenticationService.isCredentialAvailable()
            .then { result in result ? self.checkUserProfile(self.startFeed) : self.startSignIn() }
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
        print(".nav.tab.start")

        // init Tab bar
        self.tabBarController = HappTabBarController()
        self.tabBarController.navigateFeedTab = self.showFeed
        self.tabBarController.navigateFavouriteTab = self.showFavourite

        // init Sidebar
        let menuController = self.initMenuController()
        let sidebar = SlideMenuController(
            mainViewController: self.tabBarController,
            leftMenuViewController: menuController)
        self.window.rootViewController = sidebar
        self.window.makeKeyAndVisible()

        // show Feed
        self.navigationController = nil
        self.showFeed()
    }

    func showFeed() {
        self.showEventsList(.Feed)
    }
    func showFavourite() {
        self.showEventsList(.Favourite)
    }
    func showMyEvents() {
        self.showEventsList(.MyEvents)
    }

    func showEventsList(scope: EventsListScope) {
        print(".nav.tab.showEventsList", scope)

        let viewModel = EventsListViewModel(scope: scope)
        viewModel.navigateEventDetails = self.showEventDetails
        viewModel.displaySlideMenu = self.displaySlideMenu
        viewModel.displaySlideFeedFilters = self.displaySlideFeedFilters
        viewModel.hideSlideFeedFilters = self.hideSlideFeedFilters

        let viewController = self.mainStoryboard.instantiateViewControllerWithIdentifier("EventsList") as! EventsListViewController
        viewController.viewModel = viewModel

        // init filters to sidebar
        let filtersViewController = self.mainStoryboard.instantiateViewControllerWithIdentifier("FeedFilters") as! FeedFiltersController
        filtersViewController.viewModel = viewModel
        // recreate sidebar
        let menuController = self.initMenuController()
        let sidebar = SlideMenuController(
            mainViewController: self.tabBarController,
            leftMenuViewController: menuController,
            rightMenuViewController: filtersViewController)
        self.window.rootViewController = sidebar
        self.window.makeKeyAndVisible()


        if scope == .Feed || scope == .Favourite {
            let tabIndex = (scope == .Feed) ? 2 : 3
            self.tabBarController.selectedIndex = tabIndex
            self.navigationController = self.tabBarController.viewControllers![tabIndex] as! UINavigationController
            self.navigationController.viewControllers = [viewController]

        } else {
            self.navigationController.pushViewController(viewController, animated: true)
        }
    }


    func showEventDetails(forID: String) {
        print(".nav.showEventDetails [forID=\(forID)]")
        let viewModel = EventViewModel(forID: forID)
        viewModel.navigateBack = self.goBack

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
        viewModel.navigateBack = self.goBack
        viewModel.navigateSelectCurrency = self.showSelectCurrency(viewModel)
        // viewModel.navigateSelectCity = TODO

        let viewController = self.profileStoryboard.instantiateViewControllerWithIdentifier("Settings") as! SettingsController
        viewController.viewModel = viewModel
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController.pushViewController(viewController, animated: true)
    }

    func showSelectCurrency(parentViewModel: SettingsViewModel) -> NavigationFunc {
        return {
            print(".profile.showSelectCurrency")

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
        viewController.hidesBottomBarWhenPushed = true
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


    private func checkUserProfile(next: () -> (Void)) {
        if ProfileService.isUserProfileExists() {
            next()
        } else {
            ProfileService.fetchUserProfile()
                .then { next() }
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
            slideMenu.closeRight()
        }
    }


    private func initMenuController() -> MenuViewController {
        let viewModel = MenuViewModel()
        viewModel.navigateProfile = self.hideSlideMenu(self.showProfile)
        viewModel.navigateFeed = self.hideSlideMenu(self.showFeed)
        viewModel.navigateSettings = self.hideSlideMenu(self.showSettings)
        viewModel.navigateLogout = self.hideSlideMenu(self.logOut)
        
        let menuViewController = self.mainStoryboard.instantiateViewControllerWithIdentifier("Menu") as! MenuViewController
        menuViewController.viewModel = viewModel
        
        return menuViewController
    }
}
