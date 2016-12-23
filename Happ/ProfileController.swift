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
    @IBOutlet weak var activityIndicatorImageUploading: UIActivityIndicatorView!
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
    
    
    let imagePicker = UIImagePickerController()


    override func viewDidLoad() {
        super.viewDidLoad()

        self.automaticallyAdjustsScrollViewInsets = false
        self.activityIndicatorImageUploading.hidesWhenStopped = true
        self.imagePicker.delegate = self

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
        textFieldPasswordNew.text = ""
        textFieldPasswordOld.text = ""
        textFieldPasswordConfirm.text = ""
        

        viewImagePlaceholder.hidden = false
        if let image = self.viewModel.avatar {
            imageProfileImage.image = image
            imageProfileImage.layer.masksToBounds = true
            viewImagePlaceholder.hidden = true

            if self.viewModel.isUploadingAvatar {
                activityIndicatorImageUploading.startAnimating()
                self.buttonSave.enabled = false
            } else {
                activityIndicatorImageUploading.stopAnimating()
                self.buttonSave.enabled = true
            }

        } else if   let image = profile.avatar,
                    let imageURL = image.getURL()
        {
            imageProfileImage.hnk_setImageFromURL(imageURL, success: { img in
                self.imageProfileImage.image = img
                self.imageProfileImage.layer.masksToBounds = true
                self.viewImagePlaceholder.hidden = true
            })
        }
    }

    private func bindToViewModel() {
        self.viewModel.didUpdate = { [weak self] _ in
            self?.viewModelDidUpdate()
        }
    }

    private func validatedSave() {
        var values: [String: AnyObject] = [
            "fullname": textFieldFullName.text!,
            "email": textFieldEmail.text!,
            "phone": textFieldPhone.text!,
            "gender": segmentedFieldGender.selectedSegmentIndex,
            "old_password": textFieldPasswordOld.text!,
            "new_password": textFieldPasswordNew.text!,
            "confirm_password": textFieldPasswordConfirm.text!,
        ]
        if let newImageData = self.viewModel.avatarModel {
            values.updateValue(newImageData.id, forKey: "avatar_id")
        }

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
        let actionTakePhoto = UIAlertAction(title: "Take Photo", style: .Default) { (action) in
            self.pickImageFromCamera()
        }
        let actionOpenGalery = UIAlertAction(title: "Choose from Library", style: .Default) { (action) in
            self.pickImageFromLibrary()
        }
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



extension ProfileController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private func pickImageFromCamera() {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .Camera
        self.presentViewController(self.imagePicker, animated: true, completion: nil)
    }
    private func pickImageFromLibrary() {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        self.presentViewController(self.imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.viewModel.onPickImage(pickedImage)
        }

        self.dismissViewControllerAnimated(true, completion: nil)
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}


