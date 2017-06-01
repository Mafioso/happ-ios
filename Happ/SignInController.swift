//
//  ViewController.swift
//  Happ
//
//  Created by MacBook Pro on 9/5/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit
import PromiseKit
import FacebookCore
import FacebookLogin



class SignInController: UIViewController, FacebookAuthProtocol {

    var viewModel: AuthenticationViewModel!

    
    // outlets
    @IBOutlet weak var constraintFormToBottomLayout: NSLayoutConstraint!
    @IBOutlet weak var constraintLogoToForm: NSLayoutConstraint!
    @IBOutlet weak var appNameImageView: UIImageView!
    @IBOutlet weak var appNameHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var viewBottomContainer: UIView!
    @IBOutlet weak var viewSignInFormSpinner: UIView!
    @IBOutlet weak var viewSignInFormButton: UIView!
    @IBOutlet weak var appLogoImageView: UIImageView!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var buttonFacebookAuth: UIButton!
    @IBOutlet weak var viewEnterWithFBRight: UIView!

    @IBOutlet weak var viewLoginByFacebookContainer: UIView!

    @IBOutlet weak var viewFieldContainerUsername: UIView!
    @IBOutlet weak var viewFieldContainerPassword: UIView!
    @IBOutlet weak var textFieldUsername: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!


    // actions
    @IBAction func clickedFacebookAuthButton(sender: UIButton) {
        firstly {
            self.buttonFacebookAuth.enabled = false
            self.fbLogout()
            return Promise<Void>()
        }
        .then {
            return self.fbLogin()
        }
        .then { result -> Void in
            self.buttonFacebookAuth.enabled = true
            self.fbLoginManagerDidComplete(result)
        }
    }
    @IBAction func clickedSignUpButton(sender: UIButton) {
        self.viewModel.navigateSignUp?()
    }
    @IBAction func clickedLoginButton(sender: UIButton) {
        if  let username = textFieldUsername.text,
            let password = textFieldPassword.text {
            
            self.displayFormSpinner()
            self.viewModel.onSignIn(username, password: password)
                .error { e in
                    self.displayFormButton()
                    self.extDisplayAlertView(e)
            }
        }
    }

    @IBAction func clickedPrivacyPolicy(sender: UIButton) {
        self.viewModel.navigatePrivacyPolicyPage?()
    }
    @IBAction func clickedTermsPolicy(sender: UIButton) {
        self.viewModel.navigateTermsPolicyPage?()
    }

    
    
    // constants
    let defaultFormToBottomConstraint = CGFloat(142)
    let defaultLogoToFormConstraint = CGFloat(114)



    override func viewDidLoad() {
        super.viewDidLoad()

        if DeviceType.IS_IPHONE_4_OR_LESS {
            self.appNameImageView.hidden = true
            self.appLogoImageView.hidden = true
        } else if DeviceType.IS_IPHONE_5 {
            self.appNameHeightConstraint.constant = 0
        }
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "bg-auth-1")!)
    }
    override func viewDidLayoutSubviews() {

        loginButton.extMakeCircle()
        viewEnterWithFBRight.extRoundCorners([.TopRight, .BottomRight], radius: 5)

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

        self.extMakeNavBarHidden()
        self.extMakeStatusBarWhite()
        self.initObservers()
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        self.extMakeNavBarVisible()
        self.extMakeStatusBarDefault()
        self.deinitObservers()
    }


    func fbLoginManagerDidComplete(result: LoginResult) {
        switch result {
        case .Success(_, _, let accessToken):
            self.viewModel
                .onLoggedInFacebook(accessToken.userId!)
                .error { err in
                    switch err {
                    case AuthenticationErrors.FacebookUserNotRegistered:
                        self.fbFetchProfileData()
                            .then { data in
                                self.viewModel.onRegisterByFacebookData(data)
                        }
                        
                    default:
                        print(".fb.error", err)
                        self.extDisplayAlertView(err)
                    }
                }

        case .Failed(let error):
            self.extDisplayAlertView(error)

        default:
            break
        }
    }
    
    
    private func initObservers() {
        // keyboard
        NSNotificationCenter.defaultCenter()
            .addObserver(self, selector: #selector(SignInController.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter()
            .addObserver(self, selector: #selector(SignInController.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil);
        // tap
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignInController.dismissKeyboard))
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
        self.viewLoginByFacebookContainer.hidden = true
        
        constraintLogoToForm.constant = CGFloat(15)
        constraintFormToBottomLayout.constant = keyboardFrame.size.height + 15
    }
    func keyboardWillHide(notification: NSNotification) {
        
        self.viewBottomContainer.hidden = false
        self.viewLoginByFacebookContainer.hidden = false

        constraintLogoToForm.constant = self.defaultLogoToFormConstraint
        constraintFormToBottomLayout.constant = self.defaultFormToBottomConstraint
    }
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    private func displayFormSpinner() {
        viewSignInFormButton.hidden = true
        viewSignInFormSpinner.hidden = false
    }
    private func displayFormButton() {
        viewSignInFormButton.hidden = false
        viewSignInFormSpinner.hidden = true
    }
}


