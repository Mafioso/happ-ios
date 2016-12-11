//
//  SelectMultipleInterestsHeader.swift
//  Happ
//
//  Created by MacBook Pro on 12/10/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit


let notificationKeySelectInterestHeaderShouldUpdate = "hackteam.happ.selectInterestHeaderShouldUpdate"


protocol SelectInterestHeaderDelegate {
    func onHeaderClickNavItem()
    func onHeaderClickSelectAll()
}
protocol SelectInterestHeaderDataSource {
    func headerTitle() -> String?
    func headerNavItem() -> NavItemType
    func headerIsVisible() -> Bool
    func headerIsSelectedAll() -> Bool
}



protocol SelectInterestHeaderProtocol {
    static var nibName: String { get }
    var delegate: SelectInterestHeaderDelegate? { get set }
    var dataSource: SelectInterestHeaderDataSource? { get set }
    
    var labelForName: UILabel! { get set }
    var buttonNavItem: UIButton! { get set }

    func updateView()
    func initNavItem()
}
extension SelectInterestHeaderProtocol {
    func updateView() {
        labelForName.text = self.dataSource?.headerTitle()
        
        guard let dataSource = self.dataSource else { return }
        buttonNavItem.hidden = !dataSource.headerIsVisible()

        self.initNavItem()
    }

    func initNavItem() {
        let icon = self.dataSource?.headerNavItem().getIcon()
        self.buttonNavItem.setImage(icon, forState: .Normal)
    }
}


protocol SelectMultipleInterestsHeaderProtocol: SelectInterestHeaderProtocol {
    var buttonSelectAll: UIButton! { get set }
}
extension SelectMultipleInterestsHeaderProtocol {
    func updateView() {
        labelForName.text = self.dataSource?.headerTitle()

        guard let dataSource = self.dataSource else { return }
        buttonSelectAll.selected = dataSource.headerIsSelectedAll()
        buttonNavItem.hidden = !dataSource.headerIsVisible()

        self.initNavItem()
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



