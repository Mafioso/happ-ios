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
    @IBOutlet weak var appLogoImageView: UIImageView!
    
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var enterWithFbButton: UIButton!
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        self.navigationController!.navigationBar.translucent = true
        self.navigationController!.view.backgroundColor = UIColor.clearColor()

        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "bg-image")!)
        signInButton.layer.cornerRadius = 5
        signInButton.layer.masksToBounds = true
        
        
        // textfield icon position 
        let leftImageView1 = UIImageView()
        leftImageView1.image = UIImage(named: "username-icon")
        let leftView1 = UIView()
        leftView1.addSubview(leftImageView1)
        leftView1.frame = CGRectMake(0, 0, 20, 20)
        leftImageView1.frame = CGRectMake(3, 0, 16, 16)
        usernameTextField.leftView = leftView1
        usernameTextField.leftViewMode = UITextFieldViewMode.Always
        
        let leftImageView2 = UIImageView()
        leftImageView2.image = UIImage(named: "password-icon")
        let leftView2 = UIView()
        leftView2.addSubview(leftImageView2)
        leftView2.frame = CGRectMake(0, 0, 20, 20)
        leftImageView2.frame = CGRectMake(3, 0, 15, 15)
        passwordTextField.leftView = leftView2
        passwordTextField.leftViewMode = UITextFieldViewMode.Always
        
    

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
