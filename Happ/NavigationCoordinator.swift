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



class HappNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBarHidden = true
    }
}


class HappMainTabBarController: UITabBarController {

    var navigateExploreTab: NavigationFunc
    var navigateMapTab: NavigationFunc
    var navigateFeedTab: NavigationFunc
    var navigateFavouriteTab: NavigationFunc

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBar.tintColor = UIColor.happOrangeColor()

        let tabExplore = UINavigationController()
        let tabMap = UINavigationController()
        let tabFeed = HappNavigationController()
        let tabFavourite = HappNavigationController()
        // let tabChat = HappNavigationController()

        tabExplore.tabBarItem = UITabBarItem(title: "Explore",
                                          image: UIImage(named: "tab-explore"),
                                          selectedImage: nil)
        tabMap.tabBarItem = UITabBarItem(title: "Map",
                                      image: UIImage(named: "tab-map"),
                                      selectedImage: nil)
        tabFeed.tabBarItem = UITabBarItem(title: "Feed",
                                       image: UIImage(named: "tab-feed"),
                                       selectedImage: nil)
        tabFavourite.tabBarItem = UITabBarItem(title: "Favourite",
                                            image: UIImage(named: "tab-favourite"),
                                            selectedImage: nil)
        /* tabChat.tabBarItem = UITabBarItem(title: "Chat",
                                       image: UIImage(named: "tab-chat"),
                                       selectedImage: nil)
        */

        self.viewControllers = [tabExplore, tabMap, tabFeed, tabFavourite]//, tabChat]
        self.hidesBottomBarWhenPushed = true
    }

    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        let selectedAt = tabBar.items!.indexOf(item)!
        switch selectedAt {
        case 0:
            self.navigateExploreTab?()
        case 1:
            self.navigateMapTab?()
        case 2:
            self.navigateFeedTab?()
        case 3:
            self.navigateFavouriteTab?()
        default:
            break
        }
    }
}


class HappManagerTabBarController: UITabBarController {

    var navigateMyEventsTab: NavigationFunc = nil
    var navigateAddEventTab: NavigationFunc = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBar.tintColor = UIColor.happOrangeColor()

        let tabAnalytics = HappNavigationController()
        let tabProFunctions = HappNavigationController()
        let tabMyEvents = UINavigationController()
        let tabAddEvent = HappNavigationController()
        // let tabChat = HappNavigationController()

        tabAnalytics.tabBarItem = UITabBarItem(title: "Analytics",
                                             image: UIImage(named: "tab-analytics"),
                                             selectedImage: nil)
        tabProFunctions.tabBarItem = UITabBarItem(title: "Pro-Functions",
                                         image: UIImage(named: "tab-profunctions"),
                                         selectedImage: nil)
        tabMyEvents.tabBarItem = UITabBarItem(title: "My Events",
                                          image: UIImage(named: "tab-feed"),
                                          selectedImage: nil)
        tabAddEvent.tabBarItem = UITabBarItem(title: "Add Event",
                                               image: UIImage(named: "tab-favourite"),
                                               selectedImage: nil)
        /* tabChat.tabBarItem = UITabBarItem(title: "Chat",
         image: UIImage(named: "tab-chat"),
         selectedImage: nil)
         */

        self.viewControllers = [tabAnalytics, tabProFunctions, tabMyEvents, tabAddEvent]//, tabChat]
        self.hidesBottomBarWhenPushed = true
    }

    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        let selectedAt = tabBar.items!.indexOf(item)!
        switch selectedAt {
        case 2:
            self.navigateMyEventsTab?()
        case 3:
            self.navigateAddEventTab?()
        default:
            break
        }
    }
}



class NavigationCoordinator {

    private let authStoryboard: UIStoryboard
    private let mainStoryboard: UIStoryboard
    private let eventStoryboard: UIStoryboard
    private let profileStoryboard: UIStoryboard

    private let window: UIWindow
    private var navigationController: UINavigationController!
    private var tabBarController: UITabBarController!


    init(window: UIWindow) {
        self.window = window
        self.window.windowLevel = UIWindowLevelNormal

        self.mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        self.authStoryboard = UIStoryboard(name: "Authentication", bundle: nil)
        self.eventStoryboard = UIStoryboard(name: "Event", bundle: nil)
        self.profileStoryboard = UIStoryboard(name: "Profile", bundle: nil)
    }

    func start() {
        firstly {
            AuthenticationService.checkCredentialAvailable()
        }.then {
            ProfileService.fetchUserProfile()
        }.then {
            self.updateUserLanguageIfNeeded()
        }.then {
            ProfileService.checkCityExists()
        }.then {
            ProfileService.checkInterestsExist()
        }.error { err in
            switch err {
            case AuthenticationErrors.NoCredentials:
                self.startSignIn()
            case AuthenticationErrors.CredentialsExpired:
                break
            case ProfileErrors.CityNotSelected:
                self.startSetupCityAndInterests()
            case ProfileErrors.InterestsNotSelected:
                self.startSetupCityAndInterests() // TODO move to Interests
            default:
                break
            }
        }
    }
    func updateUserLanguageIfNeeded() -> Promise<Void> {
        return Promise { resolve, reject in
            ProfileService.checkCityExists()
                .then {
                    resolve()
                }.error { err in
                    switch err {
                    case ProfileErrors.LanguageWasChanged(let nowLanguage):
                        ProfileService.setLanguage(nowLanguage)
                        resolve()
                    default:
                        break
                    }
            }
        }
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
        print(".nav.startSignIn")
        let viewModel = AuthenticationViewModel()
        viewModel.navigateSignUp = self.showSignUp(viewModel)
        viewModel.navigateBack = self.goBack
        viewModel.navigateSetup = self.startSetupCityAndInterests
        viewModel.navigateFeed = self.startFeed
        // viewModel.navigateTerm
        // viewModel.navigatePolicy

        let viewController = self.authStoryboard.instantiateViewControllerWithIdentifier("SignInPage") as! SignInController
        viewController.viewModel = viewModel

        self.navigationController = UINavigationController(rootViewController: viewController)
        self.window.rootViewController = self.navigationController
        self.window.makeKeyAndVisible()
    }
    func showSignUp(parentViewModel: AuthenticationViewModel) -> NavigationFunc {
        return {
            print(".nav.showSignUp")
            let viewController = self.authStoryboard.instantiateViewControllerWithIdentifier("SignUpPage") as! SignUpController
            viewController.viewModel = parentViewModel
            self.navigationController.pushViewController(viewController, animated: true)
        }
    }


    func initMainTab() {
        print(".nav.mainTab")
        
        let mainTabBar = HappMainTabBarController()
        mainTabBar.navigateExploreTab = self.showExplore
        mainTabBar.navigateMapTab = self.showMap
        mainTabBar.navigateFeedTab = self.showFeed
        mainTabBar.navigateFavouriteTab = self.showFavourite

        self.tabBarController = mainTabBar
        self.navigationController = nil
    }
    func initManagerTab() {
        print(".nav.managerTab")

        let managerTabBar = HappManagerTabBarController()
        managerTabBar.navigateMyEventsTab = self.showMyEvents
        managerTabBar.navigateAddEventTab = self.startEventManage

        self.tabBarController = managerTabBar
        self.navigationController = nil
    }
    func updateSlidebar(rightController: UIViewController? = nil) {
        var menuController: MenuViewController
        var slidebar: SlideMenuController

        if self.tabBarController is HappMainTabBarController {
            menuController = self.initMenuController(.Feed)
        } else { //  if self.tabBarController is HappManagerTabBarController
            menuController = self.initMenuController(.EventPlanner)
        }

        if rightController != nil {
            slidebar = SlideMenuController(
                mainViewController: self.tabBarController,
                leftMenuViewController: menuController,
                rightMenuViewController: rightController!)
        } else {
            slidebar = SlideMenuController(
                mainViewController: self.tabBarController,
                leftMenuViewController: menuController)
        }

        self.window.rootViewController = slidebar
        self.window.makeKeyAndVisible()
    }

    func startFeed() {
        self.initMainTab()
        self.updateSlidebar()
        self.showFeed()
    }
    func startMyEvents() {
        self.initManagerTab()
        self.updateSlidebar()
        self.showMyEvents()
    }


    func showFeed() {
        self.showEventsList(.Feed)
    }
    func showFavourite() {
        self.showEventsList(.Favourite)
    }
    func showMyEvents() {
        let viewModel = EventsManageViewModel()
        viewModel.displaySlideMenu = self.displaySlideMenu
        viewModel.navigateEventDetails = self.showEventDetails

        let viewController = self.eventStoryboard.instantiateViewControllerWithIdentifier("EventsManage") as! EventsManageViewController
        viewController.viewModel = viewModel

        self.tabBarController.selectedIndex = 2
        self.navigationController = self.tabBarController.viewControllers![2] as! UINavigationController
        self.navigationController.viewControllers = [viewController]
    }

    func showEventsList(scope: EventsListScope) {
        let viewModel = EventsListViewModel(scope: scope)
        viewModel.navigateEventDetails = self.showEventDetails
        viewModel.displaySlideMenu = self.displaySlideMenu
        viewModel.displaySlideFeedFilters = self.displaySlideFeedFilters
        viewModel.hideSlideFeedFilters = self.hideSlideFeedFilters

        let viewController = self.eventStoryboard.instantiateViewControllerWithIdentifier("EventsList") as! EventsListViewController
        viewController.viewModel = viewModel

        let tabIndex = (scope == .Feed) ? 2 : 3
        self.tabBarController.selectedIndex = tabIndex
        self.navigationController = self.tabBarController.viewControllers![tabIndex] as! UINavigationController
        self.navigationController.viewControllers = [viewController]

        // slidebar filter
        let filtersViewController = self.eventStoryboard.instantiateViewControllerWithIdentifier("FeedFilters") as! FeedFiltersController
        filtersViewController.viewModel = viewModel
        // update slidebar
        self.updateSlidebar(filtersViewController)
    }
    func showExplore() {
        let viewModel = EventsExploreViewModel()
        viewModel.navigateEventDetails = self.showEventDetails
        viewModel.displaySlideMenu = self.displaySlideMenu

        let viewController = self.eventStoryboard.instantiateViewControllerWithIdentifier("Explore") as! EventsExploreViewController
        viewController.viewModel = viewModel

        let tabIndex = 0
        self.tabBarController.selectedIndex = tabIndex
        self.navigationController = self.tabBarController.viewControllers![tabIndex] as! UINavigationController
        self.navigationController.viewControllers = [viewController]

        self.updateSlidebar() // to remove feedFilter
    }
    func showMap() {
        let viewController = self.eventStoryboard.instantiateViewControllerWithIdentifier("EventsMap") as! EventsMapViewController

        let tabIndex = 1
        self.tabBarController.selectedIndex = tabIndex
        self.navigationController = self.tabBarController.viewControllers![tabIndex] as! UINavigationController
        self.navigationController.viewControllers = [viewController]

        // TODO add own Filter
        self.updateSlidebar() // to remove feedFilter
    }


    func showEventDetails(forID: String) {
        print(".nav.showEventDetails [forID=\(forID)]")
        let viewModel = EventViewModel(forID: forID)
        viewModel.navigateBack = self.goBack

        let viewController = self.eventStoryboard.instantiateViewControllerWithIdentifier("EventDetails") as! EventDetailsController
        viewController.viewModel = viewModel
        self.navigationController.pushViewController(viewController, animated: true)

        self.updateSlidebar() // to remove feedFilter
    }


    func showSelectInterest(scope: SelectInterestsScope, parentViewModel: SelectInterestsVMProtocol)  -> NavigationFunc {
        return {
            // init VM
            let viewModel = SelectInterestsViewModel(scope: scope, parentViewModel: parentViewModel)
            switch scope {
            case .MenuChangeInterests:
                viewModel.displaySlideMenu = self.displaySlideMenu
            case .NextToMenuChangeCity, .EventManage:
                viewModel.navigateBack = self.goBack
            case .Setup:
                break // do nothing
            }

            // init V
            let viewController = self.mainStoryboard.instantiateViewControllerWithIdentifier("SelectInterests") as! SelectInterestsController
            viewController.viewModel = viewModel

            // add V into VM func
            viewModel.navPopoverSelectSubinterests = self.showPopupSelectSubinterests(viewModel, target: viewController)


            // add V to Navigation
            switch scope {
            case .MenuChangeInterests:
                self.tabBarController = nil
                self.navigationController = UINavigationController(rootViewController: viewController)
                // init sidebar
                let menuController = self.initMenuController(.SelectInterests)
                let sidebar = SlideMenuController(
                    mainViewController: self.navigationController,
                    leftMenuViewController: menuController)
                self.window.rootViewController = sidebar
                self.window.makeKeyAndVisible()

            case .Setup, .EventManage:
                self.navigationController.pushViewController(viewController, animated: true)
            default: // TODO
                break
            }
        }
    }
    func showPopupSelectSubinterests(parentViewModel: SelectInterestsViewModel, target: UIViewController) -> NavigationFunc {
        return {
            let viewController = self.mainStoryboard.instantiateViewControllerWithIdentifier("SelectSubinterests") as! SelectSubinterestsController
            viewController.viewModel = parentViewModel

            viewController.modalPresentationStyle = .OverCurrentContext
            let windowsBounds = UIScreen.mainScreen().bounds
            viewController.preferredContentSize = CGSizeMake(windowsBounds.width, windowsBounds.height - 164)
            let popoverViewController = viewController.popoverPresentationController
            popoverViewController?.permittedArrowDirections = .Any
            //popoverViewController?.delegate = target
            popoverViewController?.sourceView = target.view
            popoverViewController?.sourceRect = CGRectMake(100, 100, 0, 0)
            target.presentViewController(viewController, animated: true, completion: nil)
        }
    }

    func startSetupCityAndInterests() {
        print(".start.SetupCityAndInterests")

        let viewModel = SetupCityAndInterestsViewModel()

        let selectCityViewModel = SelectCityOnSetupViewModel()
        selectCityViewModel.navigateBack = self.goBack

        viewModel.navigateBack = self.goBack
        viewModel.navigateSelectCity = self.showSetupSelectCity(selectCityViewModel)
        viewModel.navigateSelectInterests = self.showSelectInterest(.Setup, parentViewModel: viewModel)
        viewModel.navigateFeed = self.startFeed

        let viewController = self.mainStoryboard.instantiateViewControllerWithIdentifier("SetupCity") as! SetupCityController
        viewController.viewModel = viewModel
        viewController.viewModelSelectCity = selectCityViewModel

        self.navigationController = UINavigationController(rootViewController: viewController)
        self.window.rootViewController = self.navigationController
        self.window.makeKeyAndVisible()
    }
    func showSetupSelectCity(viewModel: SelectCityOnSetupViewModel) -> NavigationFunc {
        return {
            print(".setup.showSetupSelectCity")

            let viewController = self.mainStoryboard.instantiateViewControllerWithIdentifier("SelectCityOnSetup") as! SelectCityOnSetupController
            viewController.viewModel = viewModel
            self.navigationController.pushViewController(viewController, animated: true)
        }
    }

    func startSettings() {
        print(".start.Settings")
        let viewModel = SettingsViewModel()
        viewModel.displaySlideMenu = self.displaySlideMenu
        viewModel.navigateProfile = self.showProfile
        viewModel.navigateSelectCurrency = self.showSelectCurrency(viewModel)
        viewModel.navigateSelectNotifications = self.showSelectNotifications(viewModel)
 
        let viewController = self.profileStoryboard.instantiateViewControllerWithIdentifier("Settings") as! SettingsController
        viewController.viewModel = viewModel

        self.tabBarController = nil
        self.navigationController = UINavigationController(rootViewController: viewController)

        let menuController = self.initMenuController(.Settings)
        let sidebar = SlideMenuController(
            mainViewController: self.navigationController,
            leftMenuViewController: menuController)
        self.window.rootViewController = sidebar
        self.window.makeKeyAndVisible()
    }
    func showSelectCurrency(parentViewModel: SettingsViewModel) -> NavigationFunc {
        return {
            print(".settings.showSelectCurrency")
            parentViewModel.navigateBack = self.goBack

            let viewController = self.profileStoryboard.instantiateViewControllerWithIdentifier("SelectCurrency") as! SelectCurrencyViewController
            viewController.viewModel = parentViewModel
            self.navigationController.pushViewController(viewController, animated: true)
        }
    }
    func showSelectNotifications(parentViewModel: SettingsViewModel) -> NavigationFunc {
        return {
            print(".settings.showSelectNotifications")
            parentViewModel.navigateBack = self.goBack

            let viewController = self.profileStoryboard.instantiateViewControllerWithIdentifier("SelectNotifications") as! SelectNotificationsViewController
            viewController.viewModel = parentViewModel
            self.navigationController.pushViewController(viewController, animated: true)
        }
    }
    func showProfile() {
        print(".settings.showProfile")
        let viewModel = ProfileViewModel()
        viewModel.navigateBack = self.goBack

        let viewController = self.profileStoryboard.instantiateViewControllerWithIdentifier("Profile") as! ProfileController
        viewController.viewModel = viewModel
        self.navigationController.pushViewController(viewController, animated: true)
    }


    func startEventManage() {
        let viewModel = EventManageViewModel()
        viewModel.navigateBack = self.startMyEvents
        viewModel.navigateNext = self.showEventManageSecondPage(viewModel)
        viewModel.navigateSelectInterest = self.showSelectInterest(.EventManage, parentViewModel: viewModel)

        let viewController = self.eventStoryboard.instantiateViewControllerWithIdentifier("addEvent1") as! EventManageFirstPageViewController
        viewController.viewModel = viewModel
        viewController.hidesBottomBarWhenPushed = true

        self.navigationController = UINavigationController(rootViewController: viewController)
        self.window.rootViewController = self.navigationController
        self.window.makeKeyAndVisible()
    }

    func showEventManageSecondPage(parentViewModel: EventManageViewModel) -> NavigationFunc {
        return {
            let viewController = self.eventStoryboard.instantiateViewControllerWithIdentifier("addEvent2") as! EventManageSecondPageViewController
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
            slideMenu.closeRight()
        }
    }


    private func initMenuController(highlight: MenuActions) -> MenuViewController {
        let viewModel = MenuViewModel(highlight: highlight)
        
        let viewModelSelectCity = SelectCityOnMenuViewModel()
        viewModelSelectCity.navigateFeed = self.startFeed

        viewModel.navigateProfile = self.hideSlideMenu(self.showProfile)
        viewModel.navigateFeed = self.hideSlideMenu(self.startFeed)
        viewModel.navigateSelectInterests = self.hideSlideMenu(
            self.showSelectInterest(.MenuChangeInterests, parentViewModel: viewModelSelectCity)
        )
        viewModel.navigateEventPlanner = self.hideSlideMenu(self.startMyEvents)
        viewModel.navigateSettings = self.hideSlideMenu(self.startSettings)
        viewModel.navigateLogout = self.hideSlideMenu(self.logOut)
        viewModel.navigateBack = self.hideSlideMenu

        let menuViewController = self.mainStoryboard.instantiateViewControllerWithIdentifier("Menu") as! MenuViewController
        menuViewController.viewModelMenu = viewModel
        menuViewController.viewModelSelectCity = viewModelSelectCity

        return menuViewController
    }
}
