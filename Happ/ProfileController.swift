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
    @IBOutlet weak var constraintBottom: NSLayoutConstraint!
    @IBOutlet weak var imageProfileImage: UIImageView!
    @IBOutlet weak var textFieldFullName: UITextField!
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var textFieldPhone: UITextField!
    @IBOutlet weak var textFieldBirthday: UITextField!
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


    override func viewDidLoad() {
        super.viewDidLoad()

        self.automaticallyAdjustsScrollViewInsets = false

        self.initNavigationBarItems()
        self.extHideKeyboardWhenTappedAround()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.prefilFieldValues()

        self.initObservers()
        self.extMakeStatusBarWhite()
        self.extMakeNavBarTransparrent(UIColor.whiteColor())
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        self.deinitObservers()
        self.extMakeStatusBarDefault()
    }

    private func bindToViewModel() {
        self.viewModel.didUpdate = { [weak self] _ in
            self?.prefilFieldValues()
        }
    }


    private func prefilFieldValues() {
        let profile = self.viewModel.userProfile
        textFieldFullName.text = profile.fullname
        textFieldEmail.text = profile.email
    }

    private func validatedSave() {
        let values: [String: AnyObject] = [
            "fullname": textFieldFullName.text!,
            "email": textFieldEmail.text!,
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
                        self.extDisplayAlertView(err)
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
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "nav-back-shadow"), style: .Plain, target: self, action: #selector(handleClickNavBarBack))
    }
    func handleClickNavBarBack() {
        self.viewModel.navigateBack?()
    }
    
    
    private func initObservers() {
        // keyboard
        NSNotificationCenter.defaultCenter()
            .addObserver(self, selector: #selector(SignInController.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter()
            .addObserver(self, selector: #selector(SignInController.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil);
        // tap
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ProfileController.dismissKeyboard))
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

        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.constraintBottom.constant = keyboardFrame.size.height
        })
    }
    func keyboardWillHide(notification: NSNotification) {
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.constraintBottom.constant = 0
        })
    }
    func dismissKeyboard() {
        view.endEditing(true)
    }
}



