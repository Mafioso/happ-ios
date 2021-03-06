//
//  EventsManageCreateFirstPageViewController.swift
//  Happ
//
//  Created by Aleksei Pugachev on 12/24/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit

let loc_image_upload_failed = NSLocalizedString("Image can't be uploaded, try again", comment: "Body of alert displayed after upload raised error")
let loc_my_events_validate_field_empty = NSLocalizedString("Please fill right following fields: ", comment: "Prefix of error body displayed when form of Create Event doesn't filled some fields")
let loc_my_events_field_interest = NSLocalizedString("Interest", comment: "Label for field Interest used in Create Event form")
let loc_my_events_field_city = NSLocalizedString("City", comment: "Label for field City used in Create Event form")
let loc_my_events_field_description = NSLocalizedString("Description", comment: "Label for field Description used in Create Event form")
let loc_my_events_add_image = NSLocalizedString("Add Photo", comment: "Label for ActionList to upload images")


class EventsManageCreateFirstPageViewController: EventsManageCreateViewController {
    
    enum ReuseIdentifier: String {
        case CellAdd = "add"
        case CellPhoto = "photo"
    }
    
    let imagePicker = UIImagePickerController()
    
    @IBAction func clickedSelectInterestButton(sender: UIButton) {
        self.viewModel.onClickSelectInterest()
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var eventNameField: UITextField!
    @IBOutlet weak var eventInterestField: UITextField!
    @IBOutlet weak var eventDescriptionField: UITextView!
    
    @IBOutlet var eventNameFailureViews: [UIView]!
    @IBOutlet var eventInterestFailureViews: [UIView]!
    @IBOutlet var eventDescriptionFailureViews: [UIView]!
    @IBOutlet weak var eventInterestDisclosure: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.extMakeStatusBarDefault()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        imagePicker.delegate = self
        
        cleanFailures()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        fillAll()
    }
    
    override func bindToViewModel(viewModel: EventManageViewModel) {
        viewModel.didUpdatePhotos = { error in
            if !error {
                self.collectionView.reloadData()
            }else{
                self.extDisplayAlertView(loc_image_upload_failed)
            }
        }
    }

    override func validate() -> Bool {
        cleanFailures()
        var validated = true
        let errorMessageBeginning = loc_my_events_validate_field_empty
        var errorMessage = errorMessageBeginning

        validateField(eventNameField, failureViews: eventNameFailureViews, disclosureView: nil, validated: &validated, errorMessage: &errorMessage, errorMessageBeginning: errorMessageBeginning, errorMessageField: loc_my_events_field_city)
        validateField(eventInterestField, failureViews: eventInterestFailureViews, disclosureView: eventInterestDisclosure, validated: &validated, errorMessage: &errorMessage, errorMessageBeginning: errorMessageBeginning, errorMessageField: loc_my_events_field_interest)
        validateField(closure: { return self.eventDescriptionField.text?.characters.count > 10 }, failureViews: eventDescriptionFailureViews, disclosureView: nil, validated: &validated, errorMessage: &errorMessage, errorMessageBeginning: errorMessageBeginning, errorMessageField: loc_my_events_field_description)
        
        if !validated {
            self.extDisplayAlertView(errorMessage)
        }else{
            viewModel.onSelectName(eventNameField.text, andDescription: eventDescriptionField.text)
        }
        
        return validated
    }
    
    private func cleanFailures() {
        [eventNameFailureViews, eventInterestFailureViews, eventDescriptionFailureViews].forEach {
            $0.forEach {
                $0.hidden = true
            }
        }
        [eventInterestDisclosure].forEach {
            $0.tintColor = UIColor(hexString: "D3D3D3")
        }
    }
    
    private func fillAll() {
        if viewModel.name != nil { eventNameField.text = viewModel.name }
        if viewModel.interests.first != nil { eventInterestField.text = viewModel.interests.first?.title }
        if viewModel.description != nil { eventDescriptionField.text = viewModel.description }
    }
    
}

extension EventsManageCreateFirstPageViewController: SelectEventInterestDelegate {
    
    func selectEventInterest(onSave interest: InterestModel) {
        viewModel.onSelectInterests([interest])
        eventInterestField.text = interest.title
    }
    
}

extension EventsManageCreateFirstPageViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.uploadingPhotos.count + 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if indexPath.row == self.viewModel.uploadingPhotos.count {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ReuseIdentifier.CellAdd.rawValue, forIndexPath: indexPath) as! EventManageAddCollectionCell
            cell.clipsToBounds = false
            cell.onClick = {
                self.displayChangePhotoActions()
            }
            return cell
        }else{
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ReuseIdentifier.CellPhoto.rawValue, forIndexPath: indexPath) as! EventManagePhotoCollectionCell
            
            cell.imageView.image = nil
            cell.indicator.startAnimating()
            cell.imageView.layer.cornerRadius = 10
            cell.clipsToBounds = false
            
            let key = Array(self.viewModel.uploadingPhotos.keys)[indexPath.row]
            if let photo = self.viewModel.uploadingPhotos[key] {
                if let photoModel = self.viewModel.uploadedPhotoModels[key] {
                    if photo == nil {
                        cell.imageView.hnk_setImageFromURL(photoModel.getURL()!)
                    }else{
                        cell.imageView.image = photo
                    }
                }
            }
            
            return cell
        }
    }
    
}

extension EventsManageCreateFirstPageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private func displayChangePhotoActions() {
        let actionList = UIAlertController(title: nil, message: loc_my_events_add_image, preferredStyle: .ActionSheet)
        let actionTakePhoto = UIAlertAction(title: loc_image_upload_action_take, style: .Default) { (action) in
            self.pickImageFromCamera()
        }
        let actionOpenGalery = UIAlertAction(title: loc_image_upload_action_choose, style: .Default) { (action) in
            self.pickImageFromLibrary()
        }
        let actionCancel = UIAlertAction(title: loc_action_list_action_cancel, style: .Cancel, handler: nil)
        actionList.addAction(actionTakePhoto)
        actionList.addAction(actionOpenGalery)
        actionList.addAction(actionCancel)
        self.presentViewController(actionList, animated: true, completion: nil)
    }
    
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
