//
//  UIUtils.swift
//  Happ
//
//  Created by MacBook Pro on 9/7/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import Foundation
import UIKit


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
    func displayAlertView(body: String) {
        let alert = UIAlertController(title: "Ошибка", message: body, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }

    func displayAlertView(error: ErrorType) {
        let reqError = error as! RequestError,
            body = reqError.description

        let alert = UIAlertController(title: "Ошибка", message: body, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}