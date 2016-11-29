//
//  ProfileController.swift
//  Happ
//
//  Created by MacBook Pro on 10/1/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit



class ProfileController: UIViewController, UITextFieldDelegate {

    var viewModel: ProfileViewModel! {
        didSet {
            self.bindToViewModel()
        }
    }


    // outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var buttonSave: UIButton!
    
    @IBOutlet weak var imageProfileImage: UIImageView!
    @IBOutlet weak var viewImagePlaceholder: UIView!
    @IBOutlet weak var textFieldFullName: UITextField!
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var textFieldPhone: UITextField!
    @IBOutlet weak var buttonSelectBirthday: UIButton!
    @IBOutlet weak var segmentedFieldGender: UISegmentedControl!
    @IBOutlet weak var textFieldPasswordOld: UITextField!
    @IBOutlet weak var textFieldPasswordNew: UITextField!
    @IBOutlet weak var textFieldPasswordConfirm: UITextField!



    // actions
    @IBAction func clickedEditPhotoButton(sender: UIButton) {
        self.displayChangePhotoActions()
    }
    @IBAction func clickedSaveButton(sender: UIButton) {
        self.validatedSave()
    }
    @IBAction func clickedSelectBithday(sender: UIButton) {
        
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        self.automaticallyAdjustsScrollViewInsets = false

        self.initNavigationBarItems()
        self.extHideKeyboardWhenTappedAround()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.viewModelDidUpdate()

        self.initObservers()
        self.extMakeStatusBarWhite()
        self.extMakeNavBarTransparrent()
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        self.extDestroyObservers()
        self.extMakeStatusBarDefault()
        self.extMakeNavBarVisible()
    }



    func viewModelDidUpdate() {
        let profile = self.viewModel.userProfile
        textFieldFullName.text = profile.fullname
        textFieldEmail.text = profile.email
        textFieldPhone.text = profile.phone
        if let date = profile.date_of_birth {
            buttonSelectBirthday.titleLabel?.text = HappDateFormats.ISOFormat.toString(date)
        }

        viewImagePlaceholder.hidden = false
        if false { //TODO let imageURL = profile. {
            let imageURL = NSURL()
            imageProfileImage.hnk_setImageFromURL(imageURL, success: { img in
                self.imageProfileImage.image = img
                self.viewImagePlaceholder.hidden = true
            })
        }

        textFieldPasswordNew.text = ""
        textFieldPasswordOld.text = ""
        textFieldPasswordConfirm.text = ""
    }

    private func bindToViewModel() {
        self.viewModel.didUpdate = { [weak self] _ in
            self?.viewModelDidUpdate()
        }
    }

    private func validatedSave() {
        let values: [String: AnyObject] = [
            "fullname": textFieldFullName.text!,
            "email": textFieldEmail.text!,
            "phone": textFieldPhone.text!,
            "gender": segmentedFieldGender.selectedSegmentIndex,
            "old_password": textFieldPasswordOld.text!,
            "new_password": textFieldPasswordNew.text!,
            "confirm_password": textFieldPasswordConfirm.text!,
        ]

        self.viewModel.onSave(values)
            .then { _ in
                self.extDisplayAlertView("Saved Successfully", title: "Done!")
                
            }
            .error { err in
                if let profileError = err as? ProfileErrorTypes {
                    switch profileError {
                    case .BadConfirm:
                        self.extDisplayAlertView("Password does not match the confirm password", title: "Warning")
                    case .BadPassword:
                        self.extDisplayAlertView("Check your passwords and repeat", title: "Warning")
                    case .BadValues:
                        self.extDisplayAlertView("Check your input data")
                    }

                } else {
                    self.extDisplayAlertView(err)
                }
            }
    }


    private func displayChangePhotoActions() {
        let actionList = UIAlertController(title: nil, message: "Change Profile Photo", preferredStyle: .ActionSheet)
        let actionTakePhoto = UIAlertAction(title: "Take Photo", style: .Default, handler: nil)
        let actionOpenGalery = UIAlertAction(title: "Choose from Library", style: .Default, handler: nil)
        let actionCancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        actionList.addAction(actionTakePhoto)
        actionList.addAction(actionOpenGalery)
        actionList.addAction(actionCancel)
        self.presentViewController(actionList, animated: true, completion: nil)
    }

    private func initNavigationBarItems() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "nav-back-orange"), style: .Plain, target: self, action: #selector(handleClickNavBarBack))
    }
    func handleClickNavBarBack() {
        self.viewModel.navigateBack?()
    }



    private func initObservers() {
        // keyboard
        NSNotificationCenter.defaultCenter()
            .addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter()
            .addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil);
        // tap
        self.extHideKeyboardWhenTappedAround()
    }

    func keyboardWillShow(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let keyboardHeight = keyboardFrame.size.height

        // 1. Adjust the bottom content inset of your scroll view by the keyboard height.
        let newInset = UIEdgeInsetsMake(0, 0, keyboardHeight, 0)
        scrollView.contentInset = newInset
        scrollView.scrollIndicatorInsets = newInset

        // 2. If active text field is hidden by keyboard, scroll it so it's visible
        var visibleWindow: CGRect = self.view.frame;
        visibleWindow.size.height -= keyboardHeight;
        if activeField != nil {
            var activeFieldFrame = activeField!.frame
            activeFieldFrame.size.height -= 20 // to display under statusbar
            if !CGRectContainsPoint(visibleWindow, activeFieldFrame.origin) {
                self.scrollView.scrollRectToVisible(activeFieldFrame, animated: true)
            }
        }
    }
    func keyboardWillHide(notification: NSNotification) {
        let resetInset = UIEdgeInsetsZero
        scrollView.contentInset = resetInset
        scrollView.scrollIndicatorInsets = resetInset
    }

    var activeField: UITextField?
    func textFieldDidBeginEditing(textField: UITextField) {
        activeField = textField
    }
    func textFieldDidEndEditing(textField: UITextField) {
        activeField = nil
    }
}



