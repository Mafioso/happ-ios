//
//  UIView+Gradient.swift
//  Happ
//
//  Created by Aigerim'sMac on 22.09.16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit

extension UIView {
    func applyGradient(colours: [UIColor]) -> Void {
        self.applyGradient(colours, locations: nil)
    }
    
    func applyGradient(colours: [UIColor], locations: [NSNumber]?) -> Void {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.CGColor }
        gradient.locations = locations
        self.layer.insertSublayer(gradient, atIndex: 0)
    }
}
