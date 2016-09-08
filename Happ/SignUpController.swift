//
//  SignUpController.swift
//  Happ
//
//  Created by Aigerim'sMac on 07.09.16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit

class SignUpController: UIViewController {

    @IBOutlet weak var constraintSignInFormBottom: NSLayoutConstraint!
    @IBOutlet weak var constraintSignInToBottomContainer: NSLayoutConstraint!
    
    @IBOutlet weak var bottomContainerView: UIView!
    @IBOutlet weak var enterWithFbButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "bg-image")!)
        
        signUpButton.layer.cornerRadius = 5
        signUpButton.layer.masksToBounds = true

        usernameTextField.addLeftViewImage("username-icon", size: 16)
        passwordTextField.addLeftViewImage("password-icon", size: 15)
        repeatPasswordTextField.addLeftViewImage("password-icon", size: 15)


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
    
    
    func keyboardWillShow(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        self.bottomContainerView.hidden = true
        self.constraintSignInToBottomContainer.active = false
        
        self.constraintSignInFormBottom.constant  = keyboardFrame.size.height + 20
        self.constraintSignInFormBottom.active = true
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        self.bottomContainerView.hidden = false
        self.constraintSignInToBottomContainer.active = true
        
        self.constraintSignInFormBottom.active = false
    }


    func dismissKeyboard() {
        view.endEditing(true)
    }



}
