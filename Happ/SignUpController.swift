//
//  SignUpController.swift
//  Happ
//
//  Created by MacBook Pro on 11/17/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit
import PromiseKit


class SignUpController: UIViewController {
    
    var viewModel: AuthenticationViewModel!
    
    
    // outlets
    @IBOutlet weak var constraintFormToBottomLayout: NSLayoutConstraint!
    @IBOutlet weak var constraintLogoToForm: NSLayoutConstraint!
    
    @IBOutlet weak var viewBottomContainer: UIView!
    @IBOutlet weak var viewSignInFormSpinner: UIView!
    @IBOutlet weak var viewSignInFormButton: UIView!
    @IBOutlet weak var appLogoImageView: UIImageView!
    
    @IBOutlet weak var buttonSignUp: UIButton!
    @IBOutlet weak var appNameImageView: UIImageView!
    @IBOutlet weak var appNameHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var viewFieldContainerUsername: UIView!
    @IBOutlet weak var viewFieldContainerPassword: UIView!
    @IBOutlet weak var viewFieldContainerRepeatPassword: UIView!
    @IBOutlet weak var textFieldUsername: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var textFieldRepeatPassword: UITextField!
    
    // actions
    @IBAction func clickedSignUpButton(sender: UIButton) {
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
    @IBAction func clickedBackNavItem(sender: UIButton) {
        self.viewModel.navigateBack?()
    }
    
    // constants
    let defaultFormToBottomConstraint = CGFloat(142)
    let defaultLogoToFormConstraint = CGFloat(84)
    
    
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

        buttonSignUp.extMakeCircle()

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
    
    
    
    private func initObservers() {
        // keyboard
        NSNotificationCenter.defaultCenter()
            .addObserver(self, selector: #selector(SignUpController.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter()
            .addObserver(self, selector: #selector(SignUpController.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil);
        // tap
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignUpController.dismissKeyboard))
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
        
        constraintLogoToForm.constant = CGFloat(15)
        constraintFormToBottomLayout.constant = keyboardFrame.size.height + 15
    }
    func keyboardWillHide(notification: NSNotification) {
        
        self.viewBottomContainer.hidden = false
        
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
