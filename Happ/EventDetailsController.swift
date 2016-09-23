//
//  EventDetailsController.swift
//  Happ
//
//  Created by Aigerim'sMac on 21.09.16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit

class EventDetailsController: UIViewController {

    // outlets
    @IBOutlet weak var viewFirstContainer: UIView!
    @IBOutlet weak var viewSecondContainer: UIView!
    @IBOutlet weak var constraintHeightOfFirstContainer: NSLayoutConstraint!
    @IBOutlet weak var constraintHeightOfSecondContainer: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = viewSecondContainer.bounds
        gradient.colors = [UIColor(red: 155.0/255.0, green: 155.0/255.0, blue: 155.0/255.0, alpha: 1.0).CGColor, UIColor(red: 51.0/255.0, green: 51.0/255.0, blue: 51.0/255.0, alpha: 0.3).CGColor]
        viewSecondContainer.layer.insertSublayer(gradient, atIndex: 0)
    }
    
    override func viewWillAppear(animated: Bool) {
        let h = UIScreen.mainScreen().bounds.size.height
        constraintHeightOfFirstContainer.constant = h
        constraintHeightOfSecondContainer.constant = h
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
