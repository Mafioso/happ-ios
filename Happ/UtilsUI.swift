//
//  UIUtils.swift
//  Happ
//
//  Created by MacBook Pro on 9/7/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import Foundation
import UIKit
import PromiseKit


extension UIColor {
    class func happOrangeColor() -> UIColor {
        return UIColor(red:1.00, green:0.41, blue:0.11, alpha:1.0)
    }
    class func happOrangeHighlightColor() -> UIColor {
        return UIColor(red:1.00, green:0.41, blue:0.11, alpha:0.04)
    }
    class func happBlackHalfTextColor() -> UIColor {
        return UIColor(red:0.00, green:0.00, blue:0.00, alpha:0.56)
    }
    class func happBlackQuarterTextColor() -> UIColor {
        return UIColor(red:0.00, green:0.00, blue:0.00, alpha:0.38)
    }
}


extension UIColor { // copyright https://gist.github.com/yannickl/16f0ed38f0698d9a8ae7
    convenience init(hexString:String) {
        let hexString:NSString = hexString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        let scanner = NSScanner(string: hexString as String)

        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        
        var color:UInt32 = 0
        scanner.scanHexInt(&color)
        
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        
        self.init(red:red, green:green, blue:blue, alpha:1)
    }

    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0

        return NSString(format:"#%06x", rgb) as String
    }
}


enum HappNavBarItemPosition {
    case Left
    case Right
}

class HappNavBarItem: UIView {

    var position: HappNavBarItemPosition
    var button: UIButton


    init(position: HappNavBarItemPosition, icon: String) {
        let screenSize: CGRect = UIScreen.mainScreen().bounds

        let btnIcon = UIImage(named: icon)!

        var frame: CGRect
        switch position {
        case .Left:
            frame = CGRect(x: 16, y: 36, width: 44, height: 44)
        case .Right:
            frame = CGRect(x: Int(screenSize.width)-60, y: 36, width: 44, height: 44)
        }

        let button = UIButton(type: .Custom)
        button.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        button.setImage(btnIcon, forState: .Normal)

        self.button = button
        self.position = position
        super.init(frame: frame)
        self.addSubview(button)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension UITableViewCell {
    func extSetHighlighted() {
        self.textLabel?.backgroundColor = UIColor.clearColor()
        self.textLabel?.textColor = UIColor.happOrangeColor()
        self.backgroundColor = UIColor.happOrangeHighlightColor()

        let imageHapp = UIImage(named: "icon-happ-orange")
        let imageViewHapp = UIImageView(image: imageHapp)
        imageViewHapp.frame = CGRect(x: 16, y: 13, width: 24, height: 24)
        imageViewHapp.tag = 924
        self.addSubview(imageViewHapp)
    }
    func extUnsetHighlighted() {
        self.textLabel?.textColor = UIColor.happBlackHalfTextColor()
        self.backgroundColor = UIColor.clearColor()
        self.viewWithTag(924)?.removeFromSuperview()
    }
}

extension UITextField {
    func addLeftViewImage(name: String, size: CGFloat = 15) {
        let leftImageView1 = UIImageView()
        leftImageView1.image = UIImage(named: name)
        
        let leftView1 = UIView()
        leftView1.addSubview(leftImageView1)
        leftView1.frame = CGRectMake(0, 0, 20, 20)
        leftImageView1.frame = CGRectMake(3, 0, size, size)

        self.leftView = leftView1
        self.leftViewMode = UITextFieldViewMode.Always
    }
}

extension UIViewController {
    func extDisplayAlertView(body: String, title: String = "Error 🤕") -> Promise<Void> {
        return Promise { resolve, reject in
            let alert = UIAlertController(title: title, message: body, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: {_ in resolve()}))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }

    func extDisplayAlertView(error: ErrorType) {
        if let reqError = error as? RequestError {
            self.extDisplayAlertView(reqError.description)
        } else {
            self.extDisplayAlertView(error)
        }
    }

    func extMakeNavBarTransparrent(color: UIColor = UIColor.happBlackQuarterTextColor()) {
        if let navbar = self.navigationController?.navigationBar {
            navbar.barTintColor = UIColor.clearColor()
            navbar.tintColor = color

            let titleProp: NSDictionary = [NSForegroundColorAttributeName: color]
            navbar.titleTextAttributes = titleProp as? [String : AnyObject]

            navbar.translucent = true
            navbar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
            navbar.shadowImage = UIImage()
        }
    }
    func extMakeNavBarHidden() {
        self.navigationController?.navigationBar.hidden = true
    }
    func extMakeNavBarVisible() {
        self.navigationController?.navigationBar.hidden = false
    }

    func extMakeStatusBarWhite() {
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        // set background color
        let statusBarBackground = UIView(frame: CGRect(x: 0, y: 0, width: Int(UIScreen.mainScreen().bounds.width), height: 20))
        statusBarBackground.backgroundColor = UIColor(red:0.00, green:0.00, blue:0.00, alpha:0.2)
        statusBarBackground.tag = 920
        self.view.addSubview(statusBarBackground)
    }
    func extMakeStatusBarDefault() {
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
        // remove background
        self.view.viewWithTag(920)?.removeFromSuperview()
    }

    
    func extHideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.extDismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func extDismissKeyboard() {
        view.endEditing(true)
    }
    

}




