//
//  AppDelegate.swift
//  Happ
//
//  Created by MacBook Pro on 9/5/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import SlideMenuControllerSwift
import WTLCalendarView
import FacebookCore
import IQKeyboardManagerSwift
import Quickblox

var quickBloxUser = QBUUser()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var navigationCoordinator: NavigationCoordinator!


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.

        if self.window?.rootViewController != nil { // for Debuging single storyboard's vc
            return true
        }

        SlideMenuOptions.rightPanFromBezel = false
        SlideMenuOptions.rightViewWidth = UIScreen.mainScreen().bounds.width * 0.8
        if DeviceType.IS_IPHONE_5 || DeviceType.IS_IPHONE_4_OR_LESS {
            SlideMenuOptions.leftViewWidth = UIScreen.mainScreen().bounds.width * 0.8
            SlideMenuOptions.rightViewWidth = UIScreen.mainScreen().bounds.width * 0.86
        }
        
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
        
        QBSettings.setApplicationID(52287)
        QBSettings.setAuthKey("qWyDZh9j5mrHA4k")
        QBSettings.setAuthSecret("XsdvNBYKQn5QWAe")
        QBSettings.setAccountKey("pyJjVCDgfxsPmWPBayxd")
        QBSettings.setAutoReconnectEnabled(true)
        
        CalendarViewTheme.instance.bgColorForMonthContainer = UIColor.clearColor()
        CalendarViewTheme.instance.bgColorForDaysOfWeekContainer = UIColor.clearColor()
        CalendarViewTheme.instance.bgColorForCurrentMonth = UIColor.clearColor()
        CalendarViewTheme.instance.bgColorForOtherMonth = UIColor.clearColor()
        CalendarViewTheme.instance.textColorForTitle = UIColor(hexString: "DEDEDE")
        CalendarViewTheme.instance.textColorForNormalDay = UIColor(hexString: "DEDEDE")
        CalendarViewTheme.instance.textColorForDisabledDay = UIColor(hexString: "9A9A9A")
        CalendarViewTheme.instance.textColorForSelectedDay = UIColor.whiteColor()
        CalendarViewTheme.instance.textColorForDayOfWeek = UIColor(hexString: "DEDEDE")
        CalendarViewTheme.instance.colorForSelectedDate = UIColor(hexString: "FD692E")
        CalendarViewTheme.instance.colorForDatesRange = UIColor(hexString: "AA512A")
        CalendarViewTheme.instance.colorForDivider = UIColor.clearColor()
        
        application.setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.None)
        application.setStatusBarStyle(UIStatusBarStyle.Default, animated: false)

        let apiKey = DefaultParameters.getValue(.GoogleMapApiKey) as! String
        GMSServices.provideAPIKey(apiKey)
        GMSPlacesClient.provideAPIKey(apiKey)

        // delegate FacebookCore
        FacebookCore.ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)

        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.rootViewController = UINavigationController()
        self.navigationCoordinator = NavigationCoordinator(window: self.window!)
        self.navigationCoordinator.start()
        
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: -1, right: 0)
        let myImage = UIImage(named: "nav-back-dark")?.imageWithAlignmentRectInsets(insets)
        
        UINavigationBar.appearance().setBackgroundImage(UIImage(), forBarPosition: .Any, barMetrics: .Default)
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().backIndicatorImage = myImage
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = myImage
        
        return true
    }

    func application(app: UIApplication, openURL url: NSURL, options: [String: AnyObject]) -> Bool {
        
        if #available(iOS 9.0, *) {
            FacebookCore.ApplicationDelegate.shared.application(app, openURL: url, sourceApplication: options[UIApplicationOpenURLOptionsSourceApplicationKey] as? String, annotation: options[UIApplicationOpenURLOptionsAnnotationKey] ?? [])
        }

        if let urlItems = url.queryItems {
            if let token = urlItems["key"] {
                if navigationCoordinator.emailConfirmModel != nil {
                    navigationCoordinator.emailConfirmModel!.onConfirm(token)
                }else{
                    AuthenticationService.confirm(token)
                        .then { _ -> Void in
                            self.window?.rootViewController?.extDisplayAlertView("You have confirmed your email, now you can create your events")
                            ProfileService.fetchUserProfile()
                    }
                }
            }
        }
        
        return true
    }

    func applicationDidEnterBackground(application: UIApplication) {
        QBChat.instance().disconnectWithCompletionBlock { (error: NSError?) -> Void in }
    }
    
    func applicationWillTerminate(application: UIApplication) {
        QBChat.instance().disconnectWithCompletionBlock { (error: NSError?) -> Void in }
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        QBChat.instance().connectWithUser(quickBloxUser) { (error: NSError?) -> Void in }
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FacebookCore.ApplicationDelegate.shared.application(application,
                                                      openURL: url as NSURL!,
                                                      sourceApplication: sourceApplication,
                                                      annotation: annotation)
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        print("YO MAN")
        let subscription = QBMSubscription()
        subscription.notificationChannel = .APNS
        subscription.deviceUDID = UIDevice.currentDevice().identifierForVendor?.UUIDString
        subscription.deviceToken = deviceToken
        QBRequest.createSubscription(subscription, successBlock: { one,two in print(one,two) }, errorBlock: { e in print(e) })
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print(error)
    }

}

