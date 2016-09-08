//
//  ViewController.swift
//  Happ
//
//  Created by MacBook Pro on 9/5/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit
import PromiseKit
import SwiftyJSON


class LoginController: UIViewController {

    // outlets
    @IBOutlet weak var constraintSignInFormBottom: NSLayoutConstraint!
    @IBOutlet weak var constraintSignInToBottomContainer: NSLayoutConstraint!

    @IBOutlet weak var viewBottomContainer: UIView!
    @IBOutlet weak var viewSignInFormSpinner: UIView!
    @IBOutlet weak var viewSignInFormButton: UIView!
    @IBOutlet weak var appLogoImageView: UIImageView!

    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var enterWithFbButton: UIButton!
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!


    // actions
    @IBAction func clickedSignInButton(sender: UIButton) {
        if  let username = usernameTextField.text,
            let password = passwordTextField.text {

            self.displayFormSpinner()

            PostSignIn(username, password: password)
                .then { _ -> Promise<JSON> in
                    return Get("users/current/", parameters: nil)
                }
                .then { data -> Void in
                    let userData = data.dictionaryValue
                    print(".done.Get.users/current", userData["username"]?.stringValue)
                }
                .always {
                    self.displayFormButton()
                }
                .error { e in
                    self.displayAlertView(e)
                }
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        self.navigationController!.navigationBar.translucent = true
        self.navigationController!.view.backgroundColor = UIColor.clearColor()

        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "bg-image")!)
        signInButton.layer.cornerRadius = 5
        signInButton.layer.masksToBounds = true

        usernameTextField.addLeftViewImage("username-icon", size: 16)
        passwordTextField.addLeftViewImage("password-icon", size: 15)


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

    override func viewDidLayoutSubviews() {
        let path = UIBezierPath(roundedRect:enterWithFbButton.bounds,
                                byRoundingCorners:[.TopRight, .BottomRight],
                                cornerRadii: CGSize(width: 5, height: 5))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.CGPath
        enterWithFbButton.layer.mask = maskLayer
    }


    func displayFormSpinner() {
        UIView.transitionFromView(self.viewSignInFormButton,
                                  toView: self.viewSignInFormSpinner,
                                  duration: 0.5,
                                  options: UIViewAnimationOptions.ShowHideTransitionViews,
                                  completion: nil)
    }

    func displayFormButton() {
        UIView.transitionFromView(self.viewSignInFormSpinner,
                                  toView: self.viewSignInFormButton,
                                  duration: 0.5,
                                  options: UIViewAnimationOptions.ShowHideTransitionViews,
                                  completion: nil)
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
