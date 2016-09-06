//
//  ViewController.swift
//  Happ
//
//  Created by MacBook Pro on 9/5/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit


class LoginController: UIViewController {

    // outlets
    @IBOutlet weak var constraintSignInFormBottom: NSLayoutConstraint!
    @IBOutlet weak var constraintSignInToBottomContainer: NSLayoutConstraint!

    @IBOutlet weak var viewBottomContainer: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        

        // init observers
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginController.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginController.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil);
        
        // init
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)

        // remove observer
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }


    func keyboardWillShow(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()

        self.viewBottomContainer.hidden = true
        self.constraintSignInToBottomContainer.active = false

        self.constraintSignInFormBottom.constant  = keyboardFrame.size.height + 20
        self.constraintSignInFormBottom.active = true
    }

    func keyboardWillHide(notification: NSNotification) {

        self.viewBottomContainer.hidden = false
        self.constraintSignInToBottomContainer.active = true

        self.constraintSignInFormBottom.active = false
    }


    func dismissKeyboard() {
        view.endEditing(true)
    }
}

