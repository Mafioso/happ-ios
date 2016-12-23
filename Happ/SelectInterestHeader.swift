//
//  SelectInterestHeader.swift
//  Happ
//
//  Created by MacBook Pro on 12/24/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit



let notificationKeySelectInterestHeaderShouldUpdate = "hackteam.happ.selectInterestHeaderShouldUpdate"


protocol SelectInterestSyncWithHeader: SelectInterestHeaderDelegate, SelectInterestHeaderDataSource {}

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

    var buttonNavItem: UIButton! { get set }
    
    func updateView()
    func updateNavItem()
}
extension SelectInterestHeaderProtocol {
    func updateView() {
        guard let dataSource = self.dataSource else { return }
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





class SelectInterestHeader: UICollectionReusableView, SelectInterestHeaderProtocol {
    
    static let nibName = "SelectInterestHeader"
    
    var delegate: SelectInterestHeaderDelegate?
    var dataSource: SelectInterestHeaderDataSource?
    

    // outlets
    @IBOutlet weak var buttonNavItem: UIButton!

    // actions
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


