//
//  ChangePasswordController.swift
//  Happ
//
//  Created by MacBook Pro on 10/4/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit

class ChangePasswordController: UIViewController {


    var viewModel: ProfileViewModel!

    // outlets
    @IBOutlet weak var textFieldPasswordOld: UITextField!
    @IBOutlet weak var textFieldPasswordNew: UITextField!
    @IBOutlet weak var textFieldPasswordConfirm: UITextField!

    // actions
    @IBAction func clickedSaveButton(sender: UIButton) {
        self.collectValidateSave()
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.extHideKeyboardWhenTappedAround()
    }


    private func collectValidateSave() {
        if textFieldPasswordOld.text?.characters.count == 0 {
            return
        }
        if textFieldPasswordNew.text != textFieldPasswordConfirm.text {
            self.displayAlertPasswordRetypeMismatch()
            return
        }


        let passwords: [String: AnyObject] = [
            "old_password": textFieldPasswordOld.text!,
            "new_password": textFieldPasswordNew.text!
        ]
        self.viewModel.onChangePassword(passwords)
            .then { _ -> Void in
                self.extDisplayAlertView("Saved Successfully", title: "Done!")
                    .then {
                        self.viewModel.navigateBack!()
                }
            }
            .error { err in
                if let reqError = err as? RequestError where reqError == RequestError.BadRequest {
                    self.extDisplayAlertView("Check your passwords and repeat", title: "Warning!")

                } else {
                    self.extDisplayAlertView(err)
                }
        }
    }


    private func displayAlertPasswordRetypeMismatch() {
        self.extDisplayAlertView("Password does not match the confirm password")
    }

}


