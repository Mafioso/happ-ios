//
//  ProfileController.swift
//  Happ
//
//  Created by MacBook Pro on 10/1/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit



class ProfileController: UIViewController {

    var viewModel: ProfileViewModel! {
        didSet {
            self.bindToViewModel()
        }
    }


    // outlets
    @IBOutlet weak var imageProfileImage: UIImageView!
    @IBOutlet weak var textFieldFullName: UITextField!
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var viewPasswordFormDeactive: UIView!
    @IBOutlet weak var viewPasswordFormActive: UIView!
    @IBOutlet weak var textFieldPasswordOld: UITextField!
    @IBOutlet weak var textFieldPasswordNew: UITextField!
    @IBOutlet weak var textFieldPasswordNewRetype: UITextField!


    // actions
    @IBAction func clickedEditPhotoButton(sender: UIButton) {
    }
    @IBAction func clickedChangePasswordButton(sender: UIButton) {
        self.isChangePassword = true
    }
    @IBAction func clickedSaveButton(sender: UIButton) {
        self.collectValuesAndSave()
    }


    // variables
    var isChangePassword = false {
        didSet {
            if isChangePassword {
                UIView.transitionFromView(viewPasswordFormDeactive, toView: viewPasswordFormActive, duration: 0.3, options: UIViewAnimationOptions.CurveEaseOut, completion: nil)

            } else {
                UIView.transitionFromView(viewPasswordFormActive, toView: viewPasswordFormDeactive, duration: 0.3, options: UIViewAnimationOptions.CurveEaseOut, completion: nil)
            }
        }
    }



    override func viewDidLoad() {
        super.viewDidLoad()

    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.prefilFieldValues()
    }

    private func bindToViewModel() {
        self.viewModel.didUpdate = { [weak self] _ in
            self?.prefilFieldValues()
            self?.isChangePassword = false
        }
    }


    private func prefilFieldValues() {
        let profile = self.viewModel.userProfile
        textFieldFullName.text = profile.fullname
        textFieldEmail.text = profile.email
    }

    private func collectValuesAndSave() {
        let values: [String: AnyObject] = [
            "fullname": textFieldFullName.text!,
            "email": textFieldEmail.text!
        ]

        print(".here", self.isChangePassword, values)

        if self.isChangePassword {
            self.viewModel.onSave(values)

        } else {
            if textFieldPasswordNew.text != textFieldPasswordNewRetype.text {
                self.displayAlertPasswordRetypeMismatch()
                return
            }

            let passwords: [String: AnyObject] = [
                "old_password": textFieldPasswordOld.text!,
                "new_password": textFieldPasswordNew.text!
            ]
            self.viewModel.onSave(values, passwordValues: passwords)
        }
    }

    private func displayAlertPasswordRetypeMismatch() {
        self.extDisplayAlertView("Password does not match the confirm password")
    }

}


