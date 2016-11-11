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


    // overrides AuthController
    override private func handleAuthActionClick() {
        if  let username = textFieldUsername.text,
            let password = textFieldPassword.text,
            let repeatPassword = textFieldRepeatPassword.text {

            if password != repeatPassword {
                self.extDisplayAlertView("Passwords don't match", title: "Type again")
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
            self.extDisplayAlertView("Fill all fields", title: "One more ..")
        }
    }
}


class SignInController: AuthController {

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

    var viewModel: AuthenticationViewModel!  {
        didSet {
            self.bindToViewModel()
        }
    }


    // outlets
    @IBOutlet weak var constraintFormToBottomLayout: NSLayoutConstraint!
    @IBOutlet weak var constraintLogoToForm: NSLayoutConstraint!

    @IBOutlet weak var viewLoginByFacebookContainer: UIView!
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

    // variables
    let defaultFormToBottomConstant = CGFloat(142)
    let defaultLogoToFormConstant = CGFloat(124)


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
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.extMakeNavBarHidden()
        self.extMakeStatusBarWhite()
    }


    func handleWillDestroy() {
        self.deinitObservers()
        self.extMakeNavBarVisible()
        self.extMakeStatusBarDefault()
    }

    private func bindToViewModel() {
        self.viewModel.willDestroy = { [weak self] _ in
            self?.handleWillDestroy()
        }
    }


    private func handleAuthActionClick() {} // override it


    private func initObservers() {
        // keyboard
        NSNotificationCenter.defaultCenter()
            .addObserver(self, selector: #selector(AuthController.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter()
            .addObserver(self, selector: #selector(AuthController.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil);
        // tap
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AuthController.dismissKeyboard))
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

        self.viewLoginByFacebookContainer.hidden = true
        self.viewBottomContainer.hidden = true

        constraintLogoToForm.constant = CGFloat(15)
        constraintFormToBottomLayout.constant = keyboardFrame.size.height + 15
    }
    func keyboardWillHide(notification: NSNotification) {
        self.viewLoginByFacebookContainer.hidden = false
        self.viewBottomContainer.hidden = false

        constraintLogoToForm.constant = self.defaultLogoToFormConstant
        constraintFormToBottomLayout.constant = self.defaultFormToBottomConstant
    }
    func dismissKeyboard() {
        view.endEditing(true)
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
}




