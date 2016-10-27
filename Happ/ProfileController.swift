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

        self.initNavigationBarItems()
        self.extHideKeyboardWhenTappedAround()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.extMakeStatusBarWhite()

        self.prefilFieldValues()
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
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
        let navBarBack = HappNavBarItem(position: .Left, icon: "back")
        navBarBack.button.addTarget(self, action: #selector(handleClickNavBarBack), forControlEvents: .TouchUpInside)
        self.view.addSubview(navBarBack)
    }
    func handleClickNavBarBack() {
        self.viewModel.navigateBack?()
    }
}



