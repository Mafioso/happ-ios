//
//  UILabel+SubstituteFont.swift
//  Happ
//
//  Created by Aigerim'sMac on 07.09.16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit

//extension to substitute fonts in entire project

extension UILabel {
    
    var substituteFontName : String {
        get { return self.font.fontName }
        set { self.font = UIFont(name: "SF UI Text", size: self.font.pointSize) }
    }
    
}
