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
import RealmSwift


typealias NavigationFunc = (() -> Void)?
typealias NavigationFuncWithID = ((id: String) -> Void)?
typealias NavigationFuncWithObject = ((object: Object) -> Void)?
typealias NavigationFuncWithURL = ((url: String) -> Void)?


class HappNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBarHidden = true
    }
}


let loc_map = NSLocalizedString("Map", comment: "Title of tab bar for EventsMap")
let loc_analytics = NSLocalizedString("Analytics", comment: "Title of tab bar")
let loc_pro_functions = NSLocalizedString("Pro-Functions", comment: "Title of tab bar")
// "Add Event"


class HappMainTabBarController: UITabBarController {

    var navigateExploreTab: NavigationFunc
    var navigateMapTab: NavigationFunc
    var navigateFeedTab: NavigationFunc
    var navigateFavouriteTab: NavigationFunc

    enum Tabs: Int {
        case Feed = 0
        case Favourite = 1
        case Explore = 2
        case Map = 3
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBar.tintColor = UIColor.happOrangeColor()

        let tabFeed = UINavigationController()
        let tabFavourite = UINavigationController()
        let tabExplore = UINavigationController()
        let tabMap = UINavigationController()
        // let tabChat = HappNavigationController()

        tabFeed.tabBarItem = UITabBarItem(title: loc_feed,
                                          image: UIImage(named: "tab-feed"),
                                          selectedImage: nil)
        tabFavourite.tabBarItem = UITabBarItem(title: loc_favourite,
                                               image: UIImage(named: "tab-favourite"),
                                               selectedImage: nil)
        tabExplore.tabBarItem = UITabBarItem(title: loc_explore,
                                          image: UIImage(named: "tab-explore"),
                                          selectedImage: nil)
        tabMap.tabBarItem = UITabBarItem(title: loc_map,
                                      image: UIImage(named: "tab-map"),
                                      selectedImage: nil)

        /* tabChat.tabBarItem = UITabBarItem(title: "Chat",
                                       image: UIImage(named: "tab-chat"),
                                       selectedImage: nil)
        */

        self.viewControllers = [tabFeed, tabFavourite, tabExplore, tabMap]//, tabChat]
    }

    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        let selectedAt = tabBar.items!.indexOf(item)!
        let tab = Tabs(rawValue: selectedAt)!
        switch tab {
        case .Feed:
            self.navigateFeedTab?()
        case .Favourite:
            self.navigateFavouriteTab?()
        case .Explore:
            self.navigateExploreTab?()
        case .Map:
            self.navigateMapTab?()
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

        tabAnalytics.tabBarItem = UITabBarItem(title: loc_analytics,
                                             image: UIImage(named: "tab-analytics"),
                                             selectedImage: nil)
        tabProFunctions.tabBarItem = UITabBarItem(title: loc_pro_functions,
                                         image: UIImage(named: "tab-profunctions"),
                                         selectedImage: nil)
        tabMyEvents.tabBarItem = UITabBarItem(title: loc_my_events,
                                          image: UIImage(named: "tab-feed"),
                                          selectedImage: nil)
        tabAddEvent.tabBarItem = UITabBarItem(title: loc_my_events_create,
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

    private var eventCreationScreen: Int!
    internal var emailConfirmModel: AuthenticationViewModel?

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
        
        emailConfirmModel = nil
        
        self.navigationController.popViewControllerAnimated(true)
    }

    func logOut() {
        print(".nav.LogOut")
        AuthenticationService.logOut()
        self.start()
    }
    
    func showConfirm() {
        let viewModel = AuthenticationViewModel()
        viewModel.navigateBack = self.goBack
        viewModel.navigateTermsPolicyPage = self.showWebView(.Terms)
        viewModel.navigatePrivacyPolicyPage = self.showWebView(.Privacy)
        viewModel.navigateAfterConfirm = { self.startMyEvents() }
        
        let viewController = self.authStoryboard.instantiateViewControllerWithIdentifier("ConfirmPage") as! ConfirmEmailViewController
        viewController.hidesBottomBarWhenPushed = true
        viewController.viewModel = viewModel
        
        emailConfirmModel = viewModel
        
        self.navigationController.pushViewController(viewController, animated: true)
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

    func showWebView(webPage: HappWebPages) -> NavigationFunc {
        return {
            let viewController = WebViewController()
            viewController.hidesBottomBarWhenPushed = true
            viewController.link = webPage.getURL()
            self.navigationController.pushViewController(viewController, animated: true)
        }
    }
    func openWebPage(url: String) {
        let viewController = WebViewController()
        viewController.hidesBottomBarWhenPushed = true
        viewController.link = url
        self.navigationController.pushViewController(viewController, animated: true)
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

        let tabIndex = HappMainTabBarController.Tabs.Feed.rawValue
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

        let tabIndex = HappMainTabBarController.Tabs.Favourite.rawValue
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
        viewModel.displaySlideFilters = self.displaySlideFeedFilters
        viewModel.navigateEventDetails = self.showEventDetails
        viewModel.navigateUpdate = self.startMyEvents
        viewModel.navigateAddEvent = self.startEventManage
        viewModel.navigateEventEdit = self.startEventManageWithEvent
        viewModel.navigateEventDeniedDetails = self.showDeniedDetailsValue

        let viewController = EventsManageViewController()
        viewModel.displayEmptyList = self.showEmptyEventsList(viewController)
        viewController.viewModel = viewModel

        let tabIndex = 2
        self.tabBarController.selectedIndex = tabIndex
        self.navigationController = self.tabBarController.viewControllers![tabIndex] as! UINavigationController
        self.navigationController.viewControllers = [viewController]

        // slidebar filter
        let filtersViewController = self.organizerStoryboard.instantiateViewControllerWithIdentifier("EventsManageFilters") as! EventsManageFiltersController
        filtersViewController.delegate = viewController
        // update slidebar
        self.updateSlidebar(filtersViewController)
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
        var viewModel = EventsExploreViewModel()
        viewModel.navigateEventDetails = self.showEventDetails
        viewModel.displaySlideMenu = self.displaySlideMenu

        let viewController = self.eventStoryboard.instantiateViewControllerWithIdentifier("Explore") as! EventsExploreViewController
        viewController.viewModel = viewModel

        let tabIndex = HappMainTabBarController.Tabs.Explore.rawValue
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

        let tabIndex = HappMainTabBarController.Tabs.Map.rawValue
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
        viewModel.openWebPage = self.openWebPage

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


    func showSelectEventInterest(parentViewController: SelectEventInterestDelegate) -> NavigationFunc {
        return {
            let viewController = SelectEventInterestController()
            viewController.delegate = parentViewController
            
            var viewModel = SelectEventInterestViewModel()
            viewModel.navigateNavItem = self.goBack
            viewModel.navPopoverSelectSubinterests = self.showPopupSelectSubinterests(viewController)
            viewModel.navigateAfterSave = self.goBack

            viewController.viewModel = viewModel
            self.navigationController.pushViewController(viewController, animated: true)
        }
    }
    func showSelectUserInterests(loadInMenu: Bool, navigateAfterSave: NavigationFunc)  -> NavigationFunc {
        return {
            // init V
            let viewController = SelectUserInterestsController()

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
        viewModel.navigateHelp = self.showWebView(.FAQ)
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
    
    
    func showSelectPlace(parentViewController: SelectPlaceDelegate) -> NavigationFunc {
        return {
            let model = SelectPlaceViewModel()
            model.navigateBack = self.goBack
            
            let viewController = self.mainStoryboard.instantiateViewControllerWithIdentifier("selectPlace") as! SelectPlaceViewController
            viewController.viewModel = model
            viewController.delegate = parentViewController
            self.navigationController.pushViewController(viewController, animated: true)
        }
    }
    
    func showSelectCurrencyValue(parentViewController: SelectCurrencyValueDelegate) -> NavigationFunc {
        return {
            let model = SelectCurrencyValueViewModel()
            model.navigateBack = self.goBack
            
            let viewController = self.mainStoryboard.instantiateViewControllerWithIdentifier("selectCurrencyValue") as! SelectCurrencyValueViewController
            viewController.viewModel = model
            viewController.delegate = parentViewController
            self.navigationController.pushViewController(viewController, animated: true)
        }
    }
    
    func showDeniedDetailsValue(event: Object?) {
        let model = EventsManageDeniedDetailsViewModel(event: event as! EventModel)
        model.navigateBack = self.goBack
        model.navigateEditEvent = self.startEventManageWithEvent
        
        let viewController = self.organizerStoryboard.instantiateViewControllerWithIdentifier("denied") as! EventsManageDeniedDetailsViewController
        viewController.viewModel = model
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    func startEventManageWithEvent(event: Object?) {
        let viewModel = EventManageViewModel(event: event as! EventModel)
        
        eventCreationScreen = 1
        
        let viewController = self.organizerStoryboard.instantiateViewControllerWithIdentifier("addEvent1") as! EventsManageCreateViewController
        viewController.viewModel = viewModel
        viewController.hidesBottomBarWhenPushed = true
        
        viewModel.navigatePickInterest = self.showSelectEventInterest(viewController as! EventsManageCreateFirstPageViewController)
        
        viewModel.navigateSubmit = { self.startMyEvents() }
        viewModel.navigateBack = self.eventCreationScreenTo("prev", model: viewModel)
        viewModel.navigateNext = self.eventCreationScreenTo("next", model: viewModel)
        
        self.navigationController = UINavigationController(rootViewController: viewController)
        self.window.rootViewController = self.navigationController
        self.window.makeKeyAndVisible()
    }

    func startEventManage() {
        let viewModel = EventManageViewModel()
        
        eventCreationScreen = 1

        let viewController = self.organizerStoryboard.instantiateViewControllerWithIdentifier("addEvent1") as! EventsManageCreateViewController
        viewController.viewModel = viewModel
        viewController.hidesBottomBarWhenPushed = true
        
        viewModel.navigatePickInterest = self.showSelectEventInterest(viewController as! EventsManageCreateFirstPageViewController)
        
        viewModel.navigateSubmit = { self.startMyEvents() }
        viewModel.navigateBack = self.eventCreationScreenTo("prev", model: viewModel)
        viewModel.navigateNext = self.eventCreationScreenTo("next", model: viewModel)

        self.navigationController = UINavigationController(rootViewController: viewController)
        self.window.rootViewController = self.navigationController
        self.window.makeKeyAndVisible()
    }
    
    func eventCreationScreenTo(direction: String, model: EventManageViewModel) -> NavigationFunc {
        var nextScreen = -1
        
        if direction == "next" {
            if eventCreationScreen < 3 {
                nextScreen = eventCreationScreen + 1
            }
        } else {
            if eventCreationScreen > 1 {
                nextScreen = eventCreationScreen - 1
            }
        }
        
        if nextScreen < 0 {
            if direction == "prev" {
                return {
                    self.startMyEvents()
                }
            }else{
                return {}
            }
        }else{
            return {
                self.eventCreationScreen = nextScreen
                if direction == "next" {
                    let viewController = self.organizerStoryboard.instantiateViewControllerWithIdentifier("addEvent\(nextScreen)") as! EventsManageCreateViewController
                    
                    self.navigationController.pushViewController(viewController, animated: true)
                    viewController.viewModel = model
                    
                    switch nextScreen {
                        case 1:
                            model.navigatePickInterest = self.showSelectEventInterest(viewController as! EventsManageCreateFirstPageViewController)
                        break
                        case 2:
                            model.navigatePickCity = self.showSelectCityOnSetup(viewController as! EventsManageCreateSecondPageViewController, viewController as! EventsManageCreateSecondPageViewController)
                            model.navigatePickPlace = self.showSelectPlace(viewController as! EventsManageCreateSecondPageViewController)
                            model.navigatePickCurrency = self.showSelectCurrencyValue(viewController as! EventsManageCreateSecondPageViewController)
                        break
                        case 3: break
                        default: break
                    }
                } else {
                    self.navigationController.popViewControllerAnimated(true)
                }
                
                model.navigateBack = self.eventCreationScreenTo("prev", model: model)
                model.navigateNext = self.eventCreationScreenTo("next", model: model)
            }
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
        viewModel.navigateConfirm = self.hideSlideMenu(self.showConfirm)

        let menuViewController = self.mainStoryboard.instantiateViewControllerWithIdentifier("Menu") as! MenuViewController
        menuViewController.viewModelMenu = viewModel

        let selectCityViewController = SelectCityOnMenuController()
        selectCityViewController.viewModel = SelectCityOnMenuViewModel()
        selectCityViewController.delegate = menuViewController
        menuViewController.tableViewControllerSelectCity = selectCityViewController

        return menuViewController
    }
}
