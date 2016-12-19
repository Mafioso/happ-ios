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
        let tabFeed = UINavigationController()
        let tabFavourite = UINavigationController()
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
    private let organizerStoryboard: UIStoryboard

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
        self.organizerStoryboard = UIStoryboard(name: "Organizer", bundle: nil)
    }

    func start() {
        firstly {
            AuthenticationService.checkCredentialAvailable()
        }.then { _ -> Promise<Void> in
            return Promise { resolve, reject in
                ProfileService.fetchUserProfile()
                    .then { resolve() }
                    .error { err in
                        switch err {
                        case RequestError.NoInternet:
                            resolve() // continue without internet
                        default:
                            reject(err)
                        }
                    }
            }
        }.then { _ -> Promise<Void> in
            return ProfileService.checkCityExists()
        }.then { _ -> Promise<Void> in
            return Promise { resolve, reject in
                ProfileService.checkCityLoaded()
                    .then { resolve() }
                    .error { err in
                        switch err {
                        case ProfileErrors.CityNotLoaded:
                            ProfileService.fetchUserCity()
                                .then { resolve() }
                                .error { err in reject(err) }
                        default:
                            reject(err)
                        }
                    }
            }
        }.then { _ -> Promise<Void> in
            return self.updateUserLanguageIfNeeded()
        }.then { _ in
            self.startFeed()
        }.error { err in
            switch err {
            case AuthenticationErrors.NoCredentials:
                self.startSignIn()
            case AuthenticationErrors.CredentialsExpired, RequestError.NotAuthorized:
                self.resetRedirectLogin()
            case ProfileErrors.CityNotSelected:
                self.startSetupCityAndInterests()
            default:
                if let reqErr = err as? RequestError {
                    print(".nav.start.reqError", reqErr)
                } else {
                    print(".nav.start.error", err)
                }
                self.resetRedirectLogin()
            }
        }
    }
    func resetRedirectLogin() {
        AuthenticationService.logOut()
        self.startSignIn()
    }

    func updateUserLanguageIfNeeded() -> Promise<Void> {
        return Promise { resolve, reject in
            ProfileService.checkLanguageChange()
                .then {
                    resolve()
                }.error { err in
                    switch err {
                    case ProfileErrors.LanguageWasChanged(let nowLanguage):
                        ProfileService.setLanguage(nowLanguage)
                            .then { _ in resolve() }
                            .error { err in reject(err) }
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
        viewModel.navigateAfterLogin = self.start
        viewModel.navigateTermsPolicyPage = self.showWebView(.Terms)
        viewModel.navigatePrivacyPolicyPage = self.showWebView(.Privacy)

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

    func showWebView(webPage: HappWebPages) -> NavigationFunc{
        return {
            let viewController = self.mainStoryboard.instantiateViewControllerWithIdentifier("WebView") as! WebViewController
            viewController.link = webPage.getURL()
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
            slidebar.delegate = rightController as? SlideMenuControllerDelegate

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
        var viewModel = FeedViewModel()
        viewModel.navigateEventDetails = self.showEventDetails
        viewModel.displaySlideMenu = self.displaySlideMenu
        viewModel.displaySlideFilters = self.displaySlideFeedFilters
        viewModel.navigateSelectInterests = self.showSelectUserInterests(true, navigateAfterSave: self.startFeed)

        let viewController = FeedViewController()
        viewModel.displayEmptyList = self.showEmptyEventsList(viewController)
        viewController.viewModel = viewModel

        let tabIndex = 2
        self.tabBarController.selectedIndex = tabIndex
        self.navigationController = self.tabBarController.viewControllers![tabIndex] as! UINavigationController
        self.navigationController.viewControllers = [viewController]

        // slidebar filter
        let filtersViewController = self.eventStoryboard.instantiateViewControllerWithIdentifier("FeedFilters") as! FeedFiltersController
        filtersViewController.delegate = viewController
        // update slidebar
        self.updateSlidebar(filtersViewController)
    }
    func showFavourite() {
        var viewModel = FavouritesViewModel()
        viewModel.navigateEventDetails = self.showEventDetails
        viewModel.displaySlideMenu = self.displaySlideMenu
        viewModel.displaySlideFilters = self.displaySlideFeedFilters
        viewModel.navigateFeed = self.showFeed

        let viewController = FavouriteViewController()
        viewModel.displayEmptyList = self.showEmptyEventsList(viewController)
        viewController.viewModel = viewModel

        let tabIndex = 3
        self.tabBarController.selectedIndex = tabIndex
        self.navigationController = self.tabBarController.viewControllers![tabIndex] as! UINavigationController
        self.navigationController.viewControllers = [viewController]

        // slidebar filter
        let filtersViewController = self.eventStoryboard.instantiateViewControllerWithIdentifier("FeedFilters") as! FeedFiltersController
        filtersViewController.delegate = viewController
        // update slidebar
        self.updateSlidebar(filtersViewController)
    }
    func showMyEvents() {
        var viewModel = EventsManageViewModel()
        viewModel.displaySlideMenu = self.displaySlideMenu
        viewModel.navigateEventDetails = self.showEventDetails
        viewModel.navigateAddEvent = self.startEventManage

         let viewController = self.organizerStoryboard.instantiateViewControllerWithIdentifier("EventsManage") as! EventsManageViewController
        viewModel.displayEmptyList = self.showEmptyEventsList(viewController)
        viewController.viewModel = viewModel

        let tabIndex = 2
        self.tabBarController.selectedIndex = tabIndex
        self.navigationController = self.tabBarController.viewControllers![tabIndex] as! UINavigationController
        self.navigationController.viewControllers = [viewController]

        /* TODO
        // slidebar filter
        let filtersViewController = self.eventStoryboard.instantiateViewControllerWithIdentifier("FeedFilters") as! FeedFiltersController
        filtersViewController.delegate = viewController
        // update slidebar
        self.updateSlidebar(filtersViewController)
        */
    }

    func showEmptyEventsList(var parentViewController: EventsListSyncWithEmptyList) -> NavigationFunc {
        return {
            let existsAt: Int? = self.navigationController.viewControllers.indexOf { view in
                return view.isKindOfClass(EventsListEmptyViewController)
            }
            guard existsAt == nil else { return }

            let viewController = self.eventStoryboard.instantiateViewControllerWithIdentifier("EventsListEmpty") as! EventsListEmptyViewController
            viewController.delegate = parentViewController
            viewController.dataSource = parentViewController

            parentViewController.delegateEmptyList = viewController

            self.navigationController.pushViewController(viewController, animated: false)
        }
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
        var viewModel = EventsMapViewModel()
        viewModel.navigateEventDetailsMap = self.showEventDetailsMap
        viewModel.displaySlideMenu = self.displaySlideMenu
        viewModel.displaySlideFilters = self.displaySlideFeedFilters
        // viewModel.hideSlideFeedFilters = self.hideSlideFeedFilters

        let viewController = self.eventStoryboard.instantiateViewControllerWithIdentifier("EventsMap") as! EventsMapViewController
        viewController.viewModel = viewModel

        let tabIndex = 1
        self.tabBarController.selectedIndex = tabIndex
        self.navigationController = self.tabBarController.viewControllers![tabIndex] as! UINavigationController
        self.navigationController.viewControllers = [viewController]

        // slidebar filter
        let filtersViewController = self.eventStoryboard.instantiateViewControllerWithIdentifier("FeedFilters") as! FeedFiltersController
        filtersViewController.delegate = viewController
        // update slidebar
        self.updateSlidebar(filtersViewController)
    }


    func showEventDetails(forID: String) {
        print(".nav.showEventDetails [forID=\(forID)]")
        let viewModel = EventViewModel(forID: forID)
        viewModel.navigateBack = self.goBack
        viewModel.navigateEventDetailsMap = self.showEventDetailsMap

        let viewController = self.eventStoryboard.instantiateViewControllerWithIdentifier("EventDetails") as! EventDetailsController
        viewController.viewModel = viewModel
        self.navigationController.pushViewController(viewController, animated: true)
    }
    func showEventDetailsMap(forID: String) {
        print(".nav.showEventDetailsMap [forID=\(forID)]")
        let viewModel = EventOnMapViewModel(forID: forID)
        viewModel.navigateBack = self.goBack
        viewModel.navigateEventDetails = self.showEventDetails

        let viewController = self.eventStoryboard.instantiateViewControllerWithIdentifier("EventDetailsMap") as! EventDetailsMapController
        viewController.viewModel = viewModel
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController.pushViewController(viewController, animated: true)
    }


    func showSelectUserInterests(loadInMenu: Bool, navigateAfterSave: NavigationFunc)  -> NavigationFunc {
        return {
            // init V
            let viewController = SelectInterestController<SelectUserInterestsViewModel>()

            // init VM
            var viewModel: SelectUserInterestsViewModel
            if loadInMenu {
                viewModel = SelectUserInterestsViewModel(navItem: .Menu)
                viewModel.navigateNavItem = self.displaySlideMenu
            } else {
                viewModel = SelectUserInterestsViewModel(navItem: .Back)
                viewModel.navigateNavItem = self.goBack
            }
            viewModel.navPopoverSelectSubinterests = self.showPopupSelectSubinterests(viewController)
            viewModel.navigateAfterSave = navigateAfterSave

            // connect VM with V
            viewController.viewModel = viewModel

            // add to Navigation
            if loadInMenu {
                self.tabBarController = nil
                self.navigationController = UINavigationController(rootViewController: viewController)
                // init sidebar
                let menuController = self.initMenuController(.SelectInterests)
                let sidebar = SlideMenuController(
                    mainViewController: self.navigationController,
                    leftMenuViewController: menuController)
                self.window.rootViewController = sidebar
                self.window.makeKeyAndVisible()

            } else {
                self.navigationController.pushViewController(viewController, animated: true)

            }
        }
    }
    func showPopupSelectSubinterests<T: SelectInterestViewModelProtocol>(target: SelectInterestController<T>) -> NavigationFunc {
        return {
            let viewController = self.mainStoryboard.instantiateViewControllerWithIdentifier("SelectSubinterests") as! SelectSubinterestsController
            viewController.delegate = target
            viewController.dataSource = target

            viewController.modalPresentationStyle = .OverCurrentContext
            let windowsBounds = UIScreen.mainScreen().bounds
            viewController.preferredContentSize = CGSizeMake(windowsBounds.width, windowsBounds.height - 164)
            let popoverViewController = viewController.popoverPresentationController
            popoverViewController?.permittedArrowDirections = .Any
            popoverViewController?.sourceView = target.view
            popoverViewController?.sourceRect = CGRectMake(100, 100, 0, 0)
            target.presentViewController(viewController, animated: true, completion: nil)
        }
    }

    func startSetupCityAndInterests() {
        print(".start.SetupCityAndInterests")

         let viewController = self.mainStoryboard.instantiateViewControllerWithIdentifier("SetupCity") as! SetupCityController

        var viewModel = SetupUserCityViewModel()
        viewModel.navigateBack = self.goBack
        viewModel.navigateSelectInterests = self.showSelectUserInterests(false, navigateAfterSave: self.startFeed)
        viewModel.navigateSelectCity = self.showSelectCityOnSetup(viewController, viewController)

        viewController.viewModel = viewModel

        self.navigationController = UINavigationController(rootViewController: viewController)
        self.window.rootViewController = self.navigationController
        self.window.makeKeyAndVisible()
    }

    func showSelectCityOnSetup(delegateVC: SelectCityDelegate, _ dataSourceVC: SelectCityDataSource) -> NavigationFunc {
        return {
            print(".setup.showSelectCityOnSetup")

            var viewModel = SelectCityOnSetupViewModel()
            viewModel.navigateBack = self.goBack

            let viewController = SelectCityOnSetupController()
            viewController.viewModel = viewModel
            viewController.delegate = delegateVC
            viewController.dataSource = dataSourceVC

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
        viewModel.navigateTerms = self.showWebView(.Terms)
        viewModel.navigatePrivacy = self.showWebView(.Privacy)
 
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
        //viewModel.navigateSelectInterest = self.showSelectInterest

        let viewController = self.organizerStoryboard.instantiateViewControllerWithIdentifier("addEvent1") as! EventManageFirstPageViewController
        viewController.viewModel = viewModel
        viewController.hidesBottomBarWhenPushed = true

        self.navigationController = UINavigationController(rootViewController: viewController)
        self.window.rootViewController = self.navigationController
        self.window.makeKeyAndVisible()
    }

    func showEventManageSecondPage(parentViewModel: EventManageViewModel) -> NavigationFunc {
        return {
            let viewController = self.organizerStoryboard.instantiateViewControllerWithIdentifier("addEvent2") as! EventManageSecondPageViewController
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
        if  let slideMenu = self.window.rootViewController as? SlideMenuController {
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

        viewModel.navigateProfile = self.hideSlideMenu(self.showProfile)
        viewModel.navigateFeed = self.hideSlideMenu(self.startFeed)
        viewModel.navigateSelectInterests = self.hideSlideMenu(
            self.showSelectUserInterests(true, navigateAfterSave: self.startFeed)
        )
        viewModel.navigateEventPlanner = self.hideSlideMenu(self.startMyEvents)
        viewModel.navigateSettings = self.hideSlideMenu(self.startSettings)
        viewModel.navigateLogout = self.hideSlideMenu(self.logOut)
        viewModel.navigateBack = self.hideSlideMenu


        let menuViewController = self.mainStoryboard.instantiateViewControllerWithIdentifier("Menu") as! MenuViewController
        menuViewController.viewModelMenu = viewModel

        let selectCityViewController = SelectCityOnMenuController()
        selectCityViewController.viewModel = SelectCityOnMenuViewModel()
        selectCityViewController.delegate = menuViewController
        selectCityViewController.dataSource = menuViewController
        menuViewController.tableViewControllerSelectCity = selectCityViewController

        return menuViewController
    }
}
