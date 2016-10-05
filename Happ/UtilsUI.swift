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


    func extMakeNavBarWhite() {
        if let navBar = self.navigationController?.navigationBar {
            self.extMakeNavBarTransparent()
        }
    }
    func extMakeNavBarTransparent(tintColor: UIColor = UIColor.grayColor()) {
        if let navBar = self.navigationController?.navigationBar {
            navBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
            navBar.shadowImage = UIImage()
            navBar.translucent = true
            navBar.tintColor = tintColor
        }
        self.navigationController!.view.backgroundColor = UIColor.clearColor()
    }

    func extMakeStatusBarWhite() {
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
    }
    func extMakeStatusBarDefault() {
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
    }
    
    
    func extHideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.extDismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func extDismissKeyboard() {
        view.endEditing(true)
    }
    

}




