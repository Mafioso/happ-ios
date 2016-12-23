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

protocol SelectInterestSyncWithHeader:
    SelectInterestHeaderDelegate, SelectInterestHeaderDataSource {}




protocol SelectInterestHeaderProtocol {
    static var nibName: String { get }
    var delegate: SelectInterestHeaderDelegate? { get set }
    var dataSource: SelectInterestHeaderDataSource? { get set }
    
    var labelForName: UILabel! { get set }
    var buttonNavItem: UIButton! { get set }

    func updateView()
    func updateNavItem()
}
extension SelectInterestHeaderProtocol {
    func updateView() {
        guard let dataSource = self.dataSource else { return }
        labelForName.text = dataSource.headerTitle()
        buttonNavItem.hidden = !dataSource.headerIsVisible()
        self.updateNavItem()
    }

    func updateNavItem() {
        guard let dataSource = self.dataSource else { return }
        let icon = dataSource.headerNavItem().getIcon()
        let isSelectedAll = dataSource.headerIsSelectedAll()
        self.buttonNavItem.setImage(icon, forState: .Normal)
        self.buttonNavItem.selected = isSelectedAll
    }
}



protocol SelectMultipleInterestsHeaderProtocol: SelectInterestHeaderProtocol {
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



