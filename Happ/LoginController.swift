//
//  ViewController.swift
//  Happ
//
//  Created by MacBook Pro on 9/5/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit
import PromiseKit



class LoginController: UIViewController {

    var viewModel: AuthenticationViewModel!


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
    @IBAction func clickedSignUpButton(sender: UIButton) {
        self.viewModel.clickedSignUp()
    }
    @IBAction func clickedSignInButton(sender: UIButton) {
        if  let username = usernameTextField.text,
            let password = passwordTextField.text {

            self.displayFormSpinner()
            self.viewModel.clickedSignIn(username, password: password)
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
        
        if let navBar = self.navigationController?.navigationBar {
            navBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
            navBar.shadowImage = UIImage()
            navBar.translucent = true
            self.navigationController?.view.backgroundColor = UIColor.clearColor()
            navBar.tintColor = UIColor.whiteColor()
        }

        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "bg-image")!)

        signInButton.layer.cornerRadius = 5
        signInButton.layer.masksToBounds = true

        


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
