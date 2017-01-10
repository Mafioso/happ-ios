//
//  ConfirmEmailViewController.swift
//  Happ
//
//  Created by Aleksei Pugachev on 12/30/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class ConfirmEmailViewController: UIViewController {
    
    var viewModel: AuthenticationViewModel! {
        didSet {
            bindToViewModel(viewModel)
        }
    }
    
    @IBOutlet weak var constraintFormToBottomLayout: NSLayoutConstraint!
    
    @IBOutlet weak var viewBottomContainer: UIView!
    @IBOutlet weak var viewSignInFormSpinner: UIView!
    @IBOutlet weak var viewSignInFormButton: UIView!
    @IBOutlet weak var viewFormSuccess: UIView!
    @IBOutlet weak var appLogoImageView: UIImageView!
    
    @IBOutlet weak var buttonConfirm: UIButton!
    @IBOutlet weak var appNameImageView: UIImageView!
    @IBOutlet weak var appLogoHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var appNameHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var appLogoTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var viewFieldContainerEmail: UIView!
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var fieldHelperLabel: UILabel!
    
    @IBAction func clickedConfirmButton(sender: UIButton) {
        switch viewModel.confirmationStatus {
            case .Initiated:
                if textFieldEmail.text?.characters.count > 4 {
                    viewModel.onRequestConfirm(textFieldEmail.text!)
                }else{
                    self.extDisplayAlertView("Fill your email, please")
                }
            break
            case .Requested:
                if viewModel.confirmationToken != nil {
                    viewModel.onConfirm(viewModel.confirmationToken!)
                }else{
                    self.extDisplayAlertView("Open link from email we have sent, with your device")
                }
            break
            case .Confirmed, .Loading: break
        }
    }
    
    @IBAction func clickedBackNavItem(sender: UIButton) {
        viewModel.navigateBack?()
    }
    
    @IBAction func clickedPrivacyPolicy(sender: UIButton) {
        viewModel.navigatePrivacyPolicyPage?()
    }
    
    @IBAction func clickedTermsPolicy(sender: UIButton) {
        viewModel.navigateTermsPolicyPage?()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if DeviceType.IS_IPHONE_4_OR_LESS {
            self.appLogoHeightConstraint.constant = 0
            self.appNameHeightConstraint.constant = 0
            self.appLogoTopConstraint.constant = -10
        } else if DeviceType.IS_IPHONE_5 {
            self.appNameHeightConstraint.constant = 0
            self.appLogoTopConstraint.constant = -35
        }
        
        view.backgroundColor = UIColor(patternImage: UIImage(named: "bg-auth-5")!)
        
        textFieldEmail.text = viewModel.getUserEmail()
    }
    
    override func viewDidLayoutSubviews() {
        buttonConfirm.extMakeCircle()
        
        viewFieldContainerEmail.layer.borderColor = UIColor.whiteColor().CGColor
        viewFieldContainerEmail.layer.borderWidth = 1
        viewFieldContainerEmail.extRoundCorners([.AllCorners], radius: 5)
        
        extHideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        extMakeNavBarHidden()
        extMakeStatusBarWhite()
        IQKeyboardManager.sharedManager().enable = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        extMakeNavBarVisible()
        extMakeStatusBarDefault()
        IQKeyboardManager.sharedManager().enable = false
    }
    
    private func bindToViewModel(viewModel: AuthenticationViewModel) {
        viewModel.didUpdateConfirmationStatus = {
            self.updateView()
        }
    }
    
    private func updateView() {
        switch viewModel.confirmationStatus {
            case .Initiated:
                displayFormButton()
            break
            case .Loading:
                displayFormSpinner()
            break
            case .Requested:
                displayFormButton()
                displayFormRequested()
            break
            case .Confirmed:
                displayFormSuccess()
            break
        }
    }
    
    private func displayFormSpinner() {
        viewSignInFormButton.hidden = true
        viewSignInFormSpinner.hidden = false
        viewFormSuccess.hidden = true
    }
    
    private func displayFormButton() {
        viewSignInFormButton.hidden = false
        viewSignInFormSpinner.hidden = true
    }
    
    private func displayFormSuccess() {
        viewSignInFormButton.hidden = true
        viewSignInFormSpinner.hidden = true
        viewFormSuccess.hidden = false
    }
    
    private func displayFormRequested() {
        viewFieldContainerEmail.alpha = 0.25
        viewFieldContainerEmail.userInteractionEnabled = false
        fieldHelperLabel.text = "Check your inbox, we've sent you an email with confimation link"
    }
    
}
