//
//  ViewController.swift
//  Happ
//
//  Created by MacBook Pro on 9/5/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit
import PromiseKit



class SignUpController: AuthController {
    
    // outlets
    @IBOutlet weak var viewFieldContainerUsername: UIView!
    @IBOutlet weak var viewFieldContainerPassword: UIView!
    @IBOutlet weak var viewFieldContainerRepeatPassword: UIView!
    @IBOutlet weak var textFieldUsername: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var textFieldRepeatPassword: UITextField!


    // actions
    @IBAction func clickedBackNavItem(sender: UIButton) {
        self.viewModel.navigateBack?()
    }


    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // username
        viewFieldContainerUsername.layer.borderColor = UIColor.whiteColor().CGColor
        viewFieldContainerUsername.layer.borderWidth = 1
        viewFieldContainerUsername.extRoundCorners([.TopLeft, .TopRight], radius: 5)
        // password
        viewFieldContainerPassword.layer.borderColor = UIColor.whiteColor().CGColor
        viewFieldContainerPassword.layer.borderWidth = 1
        // repeat password
        viewFieldContainerRepeatPassword.layer.borderColor = UIColor.whiteColor().CGColor
        viewFieldContainerRepeatPassword.layer.borderWidth = 1
        viewFieldContainerRepeatPassword.extRoundCorners([.BottomLeft, .BottomRight], radius: 5)
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        print(".SignUp.vwA")

        self.extMakeNavBarHidden()
        self.extMakeStatusBarWhite()
    }
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)

        print(".SignUp.vwD")

        self.deinitObservers()
        self.extMakeNavBarVisible()
        self.extMakeStatusBarDefault()
    }



    // overrides AuthController
    override private func handleAuthActionClick() {
        if  let username = textFieldUsername.text,
            let password = textFieldPassword.text,
            let repeatPassword = textFieldRepeatPassword.text {
            
            if password == repeatPassword {
                self.extDisplayAlertView("Passwords don't match")
                return
            }

            self.displayFormSpinner()
            self.viewModel.onSignUp(username, password: password)
                .always {
                    self.displayFormButton()
                }
                .error { e in
                    self.extDisplayAlertView(e)
            }
        } else {
            self.extDisplayAlertView("Please, fill all fields")
        }
    }
}


class LoginController: AuthController {

    // outlets
    @IBOutlet weak var viewFieldContainerUsername: UIView!
    @IBOutlet weak var viewFieldContainerPassword: UIView!
    @IBOutlet weak var textFieldUsername: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!


    // actions
    @IBAction func clickedSignUpButton(sender: UIButton) {
        self.viewModel.navigateSignUp?()
    }


    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        // username
        viewFieldContainerUsername.layer.borderColor = UIColor.whiteColor().CGColor
        viewFieldContainerUsername.layer.borderWidth = 1
        viewFieldContainerUsername.extRoundCorners([.TopLeft, .TopRight], radius: 5)
        // password
        viewFieldContainerPassword.layer.borderColor = UIColor.whiteColor().CGColor
        viewFieldContainerPassword.layer.borderWidth = 1
        viewFieldContainerPassword.extRoundCorners([.BottomLeft, .BottomRight], radius: 5)
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        print(".Login.vwA")

        self.extMakeNavBarHidden()
        self.extMakeStatusBarWhite()
    }
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        print(".Login.vwD")
        
        self.deinitObservers()
        self.extMakeNavBarVisible()
        self.extMakeStatusBarDefault()
    }


    // overrides AuthController
    override private func handleAuthActionClick() {
        if  let username = textFieldUsername.text,
            let password = textFieldPassword.text {

            self.displayFormSpinner()
            self.viewModel.onSignIn(username, password: password)
                .always {
                    self.displayFormButton()
                }
                .error { e in
                    self.extDisplayAlertView(e)
            }
        }
    }
}


class AuthController: UIViewController {

    var viewModel: AuthenticationViewModel!


    // outlets
    @IBOutlet weak var constraintSignInFormBottom: NSLayoutConstraint!
    @IBOutlet weak var constraintSignInToBottomContainer: NSLayoutConstraint!

    @IBOutlet weak var viewBottomContainer: UIView!
    @IBOutlet weak var viewSignInFormSpinner: UIView!
    @IBOutlet weak var viewSignInFormButton: UIView!
    @IBOutlet weak var appLogoImageView: UIImageView!

    @IBOutlet weak var buttonAuthAction: UIButton!
    @IBOutlet weak var enterWithFbButton: UIButton!
    @IBOutlet weak var viewEnterWithFBRight: UIView!


    // actions
    @IBAction func clickedAuthActionButton(sender: UIButton) {
        self.handleAuthActionClick()
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "bg-auth-1")!)

        self.initObservers()
    }
    override func viewWillLayoutSubviews() {
        buttonAuthAction.layer.cornerRadius = 0.5 * buttonAuthAction.bounds.size.height
        buttonAuthAction.clipsToBounds = true
        viewEnterWithFBRight.extRoundCorners([.TopRight, .BottomRight], radius: 5)
    }


    func displayFormSpinner() {
        UIView.transitionFromView(self.viewSignInFormButton,
                                  toView: self.viewSignInFormSpinner,
                                  duration: 0.5,
                                  options: UIViewAnimationOptions.ShowHideTransitionViews,
                                  completion: nil)
            viewSignInFormSpinner.superview
    }

    func displayFormButton() {
        UIView.transitionFromView(self.viewSignInFormSpinner,
                                  toView: self.viewSignInFormButton,
                                  duration: 0.5,
                                  options: UIViewAnimationOptions.ShowHideTransitionViews,
                                  completion: nil)
    }


    private func handleAuthActionClick() {} // override it


    private func initObservers() {
        // keyboard
        NSNotificationCenter.defaultCenter()
            .addObserver(self, selector: #selector(LoginController.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter()
            .addObserver(self, selector: #selector(LoginController.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil);
        // tap
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    private func deinitObservers() {
        // remove observer
        NSNotificationCenter.defaultCenter()
            .removeObserver(self)
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
