//
//  ProfileController.swift
//  Happ
//
//  Created by MacBook Pro on 10/1/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit

enum ProfileControllerFields: String {
    case FullName = "fullname"
    case Email = "email"
    case PasswordCurrent = "old_password"
    case PasswordNew = "new_password"
    case PasswordNewRetype = "_retype_password"


    func getIndexPath() -> NSIndexPath {
        switch self {
        case .FullName:
            return NSIndexPath(forRow: 0, inSection: 0)
        case .Email:
            return NSIndexPath(forRow: 1, inSection: 0)
        case .PasswordCurrent:
            return NSIndexPath(forRow: 0, inSection: 2)
        case .PasswordNew:
            return NSIndexPath(forRow: 1, inSection: 2)
        case .PasswordNewRetype:
            return NSIndexPath(forRow: 0, inSection: 2)
        }
    }

    static func forAll() -> [ProfileControllerFields] {
        return [.FullName, .Email, .PasswordCurrent, .PasswordNew, .PasswordNewRetype]
    }
    
    static func forAllProfile() -> [ProfileControllerFields] {
        return [.FullName, .Email]
    }
    
    static func forAllPassword() -> [ProfileControllerFields] {
        return [.PasswordCurrent, .PasswordNew, .PasswordNewRetype]
    }

}


class ProfileController: UIViewController {

    var viewModel: ProfileViewModel! {
        didSet {
            self.bindToViewModel()
        }
    }


    // outlets
    @IBOutlet weak var imageProfileImage: UIImageView!
    
    // actions
    @IBAction func clickedSaveButton(sender: UIButton) {
        let values = self.getNonEmptyFieldValues(ProfileControllerFields.forAllProfile())
        print(".here", values)
        self.viewModel.onSave(values)
        //TODO
        //self.viewModel.onSave(<#T##values: [String : AnyObject]##[String : AnyObject]#>, passwordValues: <#T##[String : AnyObject]#>)
    }


    // constants
    let segueEmbeddedTable = "embeddedTable"
    let tagNumberOfTextField = 1

    // variables
    var tableView: UITableView!


    override func viewDidLoad() {
        super.viewDidLoad()

    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.prefilFieldValues()
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == segueEmbeddedTable {
            let dest = segue.destinationViewController as! UITableViewController
            self.tableView = dest.tableView
        }
    }


    private func bindToViewModel() {
        self.viewModel.didUpdate = { [weak self] _ in
            self?.prefilFieldValues()
        }
    }


    private func prefilFieldValues() {
        let profile = self.viewModel.userProfile
        self._setValueOf(.FullName, value: profile.fullname)
        self._setValueOf(.Email, value: profile.email)
    }

    private func getNonEmptyFieldValues(fields: [ProfileControllerFields]) -> [String: String] {
        var values: [String: String] = [:]
        fields.forEach { fieldType in
            if let fieldValue = self._getValueOf(fieldType) {
                values.updateValue(fieldValue, forKey: fieldType.rawValue)
            }
        }
        return values
    }
    private func _getValueOf(fieldType: ProfileControllerFields) -> String? {
        return self.__getTextFieldOf(fieldType).text
    }
    private func _setValueOf(fieldType: ProfileControllerFields, value: String) -> Void {
        self.__getTextFieldOf(fieldType).text = value
    }
    private func __getTextFieldOf(fieldType: ProfileControllerFields) -> UITextField {
        let indexPath = fieldType.getIndexPath()
        print("..here", indexPath.section, indexPath.row)
        let cell = self.tableView.cellForRowAtIndexPath(indexPath)
        let textField = cell?.viewWithTag(tagNumberOfTextField) as! UITextField
        return textField
    }
    
}


