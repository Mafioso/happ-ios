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
    @IBOutlet weak var imageProfileImage: UIImageView!
    @IBOutlet weak var textFieldFullName: UITextField!
    @IBOutlet weak var textFieldEmail: UITextField!



    // actions
    @IBAction func clickedEditPhotoButton(sender: UIButton) {
    }
    @IBAction func clickedChangePasswordButton(sender: UIButton) {
        self.viewModel.navigateChangePassword!()
    }
    @IBAction func clickedSaveButton(sender: UIButton) {
        self.collectSave()
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        self.extHideKeyboardWhenTappedAround()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.prefilFieldValues()
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

    private func collectSave() {
        let values: [String: AnyObject] = [
            "fullname": textFieldFullName.text!,
            "email": textFieldEmail.text!
        ]

        self.viewModel.onChangeProfile(values)
            .then { _ -> Void in
                self.extDisplayAlertView("Saved Successfully", title: "Done!")
            }
            .error { err in
                self.extDisplayAlertView(err)
        }
    }


}



