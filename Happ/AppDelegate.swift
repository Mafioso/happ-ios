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
//        let backimage = UIImage(named: "nav-back-gray")!
//        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffsetMake(0, -60), forBarMetrics:UIBarMetrics.Default)
//        UIBarButtonItem.appearance().setBackButtonBackgroundImage(backimage.resizableImageWithCapInsets(UIEdgeInsetsMake(0, (backimage.size.width)-1, 0, 0)), forState: .Normal, barMetrics: .Default)
        
        let apiKey = DefaultParameters.getValue(.GoogleMapApiKey) as! String
        GMSServices.provideAPIKey(apiKey)
        GMSPlacesClient.provideAPIKey(apiKey)

        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.rootViewController = UINavigationController()
        self.navigationCoordinator = NavigationCoordinator(window: self.window!)
        self.navigationCoordinator.start()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

