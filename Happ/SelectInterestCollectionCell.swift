//
//  SelectInterestCollectionCell.swift
//  Happ
//
//  Created by MacBook Pro on 12/10/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit

class SelectInterestCollectionCell: UICollectionViewCell {

    // outlets
    @IBOutlet weak var viewFooter: UIView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var imagePhoto: UIImageView!
    @IBOutlet weak var viewSelectionInfo: UIView!
    @IBOutlet weak var viewSelectedAll: UIView!
    @IBOutlet weak var viewSelectedSome: UIView!
    @IBOutlet weak var viewUnfocus: UIView!
    @IBOutlet weak var labelSelectedSomeText: UILabel!

    static let nibName = "SelectInterestCollectionCell"

    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

}
