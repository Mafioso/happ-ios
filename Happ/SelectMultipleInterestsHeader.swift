//
//  SelectMultipleInterestsHeader.swift
//  Happ
//
//  Created by MacBook Pro on 12/10/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit



protocol SelectMultipleInterestsHeaderProtocol: SelectInterestHeaderProtocol {
    var labelForName: UILabel! { get set }
    var buttonSelectAll: UIButton! { get set }
}
extension SelectMultipleInterestsHeaderProtocol {
    func updateView() {
        guard let dataSource = self.dataSource else { return }

        labelForName.text = dataSource.headerTitle()
        buttonSelectAll.selected = dataSource.headerIsSelectedAll()
        buttonNavItem.hidden = !dataSource.headerIsVisible()

        self.updateNavItem()
    }
}



class SelectMultipleInterestsHeader: UICollectionReusableView, SelectMultipleInterestsHeaderProtocol {

    static let nibName = "SelectMultipleInterestsHeader"
    
    var delegate: SelectInterestHeaderDelegate?
    var dataSource: SelectInterestHeaderDataSource?

    
    // outlets
    @IBOutlet weak var labelForName: UILabel!
    @IBOutlet weak var buttonNavItem: UIButton!
    @IBOutlet weak var buttonSelectAll: UIButton!


    // actions
    @IBAction func clickedSelectAll(sender: UIButton) {
        self.delegate?.onHeaderClickSelectAll()
    }
    @IBAction func clickedNavItem(sender: UIButton) {
        self.delegate?.onHeaderClickNavItem()
    }


    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.updateView()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.handleHeaderShouldUpdate), name: notificationKeySelectInterestHeaderShouldUpdate, object: nil)
    }
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }


    func handleHeaderShouldUpdate() {
        self.updateView()
    }
    
}



