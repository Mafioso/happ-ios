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
    class func happOrangeBlinkColor() -> UIColor {
        return UIColor(red:1.00, green:0.41, blue:0.11, alpha:0.2)
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

        var btnIcon: UIImage
        switch icon {
        case "back":
           let tmpIcon = UIImage(named: "arrow-location")!
            btnIcon = UIImage(CGImage: tmpIcon.CGImage!, scale: tmpIcon.scale, orientation: UIImageOrientation.UpMirrored)
        default:
            btnIcon = UIImage(named: icon)!
        }

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




