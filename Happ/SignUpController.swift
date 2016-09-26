//
//  SignUpController.swift
//  Happ
//
//  Created by Aigerim'sMac on 07.09.16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit
import PromiseKit


class SignUpController: UIViewController {
    
    var viewModel: AuthenticationViewModel!

    
    // outlets
    @IBOutlet weak var constraintSignUpFormBottom: NSLayoutConstraint!
    @IBOutlet weak var constraintSignUpToBottomContainer: NSLayoutConstraint!


    @IBOutlet weak var bottomContainerView: UIView!
    @IBOutlet weak var viewSignUpFormSpinner: UIView!
    @IBOutlet weak var viewSignUpFormButton: UIView!
    @IBOutlet weak var enterWithFbButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!


    // actions
    @IBAction func clickedSignUpButton(sender: UIButton) {
        if  let username = usernameTextField.text,
            let password = passwordTextField.text {
            let email: String? = emailTextField.text

            self.displayFormSpinner()
            self.viewModel.clickedSignUp(username, password: password, email: email)
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

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "bg-image")!)
        
        signUpButton.layer.cornerRadius = 5
        signUpButton.layer.masksToBounds = true

    


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
        UIView.transitionFromView(self.viewSignUpFormButton,
                                  toView: self.viewSignUpFormSpinner,
                                  duration: 0.5,
                                  options: UIViewAnimationOptions.ShowHideTransitionViews,
                                  completion: nil)
    }

    func displayFormButton() {
        UIView.transitionFromView(self.viewSignUpFormSpinner,
                                  toView: self.viewSignUpFormButton,
                                  duration: 0.5,
                                  options: UIViewAnimationOptions.ShowHideTransitionViews,
                                  completion: nil)
    }


    func keyboardWillShow(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        self.bottomContainerView.hidden = true
        //self.constraintSignUpToBottomContainer.active = false
        
        self.constraintSignUpFormBottom.constant  = keyboardFrame.size.height + 20
        self.constraintSignUpFormBottom.active = true
    }
    
    func keyboardWillHide(notification: NSNotification) {

        self.bottomContainerView.hidden = false
        //self.constraintSignUpToBottomContainer.active = true

        self.constraintSignUpFormBottom.active = false
    }


    func dismissKeyboard() {
        view.endEditing(true)
    }


}
