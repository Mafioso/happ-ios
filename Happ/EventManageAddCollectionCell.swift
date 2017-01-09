//
//  EventManageAddCollectionCell.swift
//  Happ
//
//  Created by Aleksei Pugachev on 12/24/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit

class EventManageAddCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var dashedView: UIView!
    
    @IBAction func clicked(sender: AnyObject) {
        onClick()
    }
    
    var onClick: (Void -> Void) = {}
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        dashedView.addDashedBorder(UIColor(hexString: "B4B4B4"))
    }
    
}
