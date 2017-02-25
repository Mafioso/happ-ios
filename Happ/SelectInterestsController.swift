//
//  SelectInterestsController.swift
//  Happ
//
//  Created by MacBook Pro on 10/31/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit

let loc_save_capitalized = NSLocalizedString("SAVE", comment: "Title of button used systemwide")


// MARK: - SelectEventInterest
protocol SelectEventInterestDelegate {
    func selectEventInterest(onSave interest: InterestModel)
}


class SelectEventInterestController: SelectInterestController<SelectEventInterestViewModel> {

    var delegate: SelectEventInterestDelegate?

    override init() {
        super.init()
    }


    override func handleClickSave() {
        if let interest = self.viewModel.getSelectedInterest() {
            self.delegate?.selectEventInterest(onSave: interest)
            self.viewModel.navigateAfterSave?()
        }
    }
}



// MARK: - SelectUserInterests
class SelectUserInterestsController: SelectInterestController<SelectUserInterestsViewModel> {
    
    override init() {
        super.init()
    }


    override func initHeader() {
        let headerNib = UINib(nibName: SelectMultipleInterestsHeader.nibName, bundle: nil)
        self.collectionView.registerNib(headerNib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: self.headerIdentifier)
    }
    override func getHeaderSize() -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 118)
    }
}





// MARK: - Prototype
class SelectInterestController<T: SelectInterestViewModelProtocol>: UIViewController, UIGestureRecognizerDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,
    SelectInterestSyncWithHeader,
    SelectSubinterestsDelegate, SelectSubinterestsDataSource {


    var viewModel: T! {
        didSet {
            self.updateView(oldValue)
        }
    }

    var collectionView: UICollectionView!
    var buttonNavItemSecond: UIButton!
    var buttonSave: UIButton!

 
    let headerIdentifier = "header"
    let cellIdentifier = "cell"


    init() {
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.initCollectionView()
        self.initSaveButton()
        self.initNavItems()
        self.initLongPressGesture()

        self.viewModel.onInitLoadingData { state in
            self.viewModel.state = state
        }

    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.extMakeNavBarHidden()
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        self.extMakeNavBarVisible()
    }


    func updateView(oldViewModel: T?) {
        guard self.isViewLoaded() else { return }
        print(".[V].update", self.viewModel.state.items.count)
        self.updateHeader()
        self.collectionView.reloadData()
        self.updateNavItems()
        

        if oldViewModel?.state.opened != self.viewModel.state.opened {
            self.displayPopoverSelectSubinterestsIfNeeded()
        }
    }

    func updateHeader() {
        NSNotificationCenter.defaultCenter()
            .postNotificationName(notificationKeySelectInterestHeaderShouldUpdate, object: nil)
    }
    func updateNavItems() {
        self.buttonNavItemSecond.hidden = self.viewModel.isHeaderVisible
    }
    
    
    private func initCollectionView() {
        self.collectionView = {
            let layout: UICollectionViewFlowLayout = {
                let t = UICollectionViewFlowLayout()
                t.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 52, right: 0)
                t.minimumLineSpacing = 1.5
                t.minimumInteritemSpacing = 1.5
                t.itemSize = self.getCellSize()
                return t
            }()
            
            let c = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
            c.backgroundColor = UIColor.whiteColor()
            c.alwaysBounceVertical = true
            
            self.view.addSubview(c)

            c.translatesAutoresizingMaskIntoConstraints = false
            // top
            NSLayoutConstraint(item: c, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1.0, constant: 0).active = true
            // left
            NSLayoutConstraint(item: c, attribute: .Leading, relatedBy: .Equal, toItem: self.view, attribute: .Leading, multiplier: 1.0, constant: 0).active = true
            // right
            NSLayoutConstraint(item: c, attribute: .Trailing, relatedBy: .Equal, toItem: self.view, attribute: .Trailing, multiplier: 1.0, constant: 0).active = true
            // bottom
            let bottom = NSLayoutConstraint(item: c, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1.0, constant: 0)
            bottom.priority = 250
            bottom.active = true
            
            return c
        }()

 
        self.collectionView.dataSource = self
        self.collectionView.delegate = self

        // add header
        self.initHeader()

        // add cell
        let cellNib = UINib(nibName: SelectInterestCollectionCell.nibName, bundle: nil)
        self.collectionView.registerNib(cellNib, forCellWithReuseIdentifier: self.cellIdentifier)
    }
    
    private func initHeader() {
        let headerNib = UINib(nibName: SelectInterestHeader.nibName, bundle: nil)
        self.collectionView.registerNib(headerNib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: self.headerIdentifier)
    }
    private func initSaveButton() {
        self.buttonSave = {
            let btn = UIButton()
            let windowSize = UIScreen.mainScreen().bounds
            btn.setTitle(loc_save_capitalized, forState: .Normal)
            btn.setTitleColor(UIColor.happOrangeColor(), forState: .Normal)
            btn.backgroundColor = UIColor.whiteColor()
            btn.frame = CGRectMake(0, windowSize.height-52, windowSize.width, 52)
            return btn
        }()
        self.buttonSave.addTarget(self, action: #selector(self.handleClickSave), forControlEvents: .TouchUpInside)
        self.view.addSubview(self.buttonSave)
    }
    private func initNavItems() {
        let navItem = self.viewModel.navItem
        self.buttonNavItemSecond = {
            let btn = UIButton()
            btn.hidden = true
            btn.frame = CGRectMake(8, 28, 40, 40)
            btn.setImage(navItem.getIconSecond(), forState: .Normal)
            return btn
        }()
        self.view.addSubview(self.buttonNavItemSecond)
    }
    

    private func displayPopoverSelectSubinterestsIfNeeded() {
        // to display popup over selected cell, we do:
        // 1. Minimize CollectionView by adding Height Constraint
        // 2. present ViewController as Popover

        if self.getHeightConstraint() == nil {
            self.createHeightConstraint()
        }

        if  let longPressedInterest = self.viewModel.state.opened,
            let indexOfInterest = self.viewModel.state.items.indexOf(longPressedInterest) {

            // enable constraint
            self.getHeightConstraint()?.active = true
            self.view.updateConstraintsIfNeeded()
            self.view.layoutIfNeeded()

            // scroll
            let indexPath = NSIndexPath(forRow: indexOfInterest, inSection: 0)
            self.collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)

            // popover
            self.viewModel.navPopoverSelectSubinterests?()

        } else {
            self.getHeightConstraint()?.active = false
            self.view.updateConstraintsIfNeeded()
            self.view.layoutIfNeeded()
        }
 
    }
    private func getHeightConstraint() -> NSLayoutConstraint? {
        return self.collectionView.constraints.filter { $0.identifier == "height" }.first
    }
    private func createHeightConstraint() {
        let height = self.getCollectionViewHeightAlternative()
        let heightConstraint = NSLayoutConstraint(item: self.collectionView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: height)
        heightConstraint.identifier = "height"
        heightConstraint.active = true
        self.collectionView.updateConstraints()
    }


    private func getInterestBy(indexPath: NSIndexPath) -> InterestModel {
        return self.viewModel.state.items[indexPath.row]
    }
    private func getCollectionViewHeightAlternative() -> CGFloat {
        let cellHeigh = self.getCellSize().height
        let statusBarHeight = CGFloat(20)
        let height = cellHeigh + statusBarHeight
        return height
    }
    private func getCellSize() -> CGSize {
        if DeviceType.IS_IPHONE_4_OR_LESS || DeviceType.IS_IPHONE_5 {
            return CGSizeMake(105, 140)
        } else if DeviceType.IS_IPHONE_6 {
            return CGSizeMake(124, 164)
        } else { // DeviceType.IS_IPHONE_6P
            return CGSizeMake(137, 182)
        }
    }
    private func getHeaderSize() -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 60)
    }


    func onLongPressCell(gesture : UILongPressGestureRecognizer!) {
        if gesture.state != .Ended {
            return
        }
        let p = gesture.locationInView(self.collectionView)
        if let indexPath = self.collectionView.indexPathForItemAtPoint(p) {
            self.viewModel.onOpenSubinterests(for: self.getInterestBy(indexPath))
            
        } else {
            print("couldn't find index path")
        }
    }
    func handleClickSave() {
        self.viewModel.onSave()
    }

    
    
    private func initLongPressGesture() {
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(self.onLongPressCell))
        lpgr.minimumPressDuration = 0.3
        lpgr.delaysTouchesBegan = true
        lpgr.delegate = self
        self.collectionView.addGestureRecognizer(lpgr)
    }



    // MARK: - implement SelectInterestHeaderDataSource
    func headerTitle() -> String? {
        if let multiViewModel = self.viewModel as? SelectUserInterestsViewModel {
            return multiViewModel.title
        }
        return nil
    }
    func headerNavItem() -> NavItemType {
        return self.viewModel.navItem
    }
    func headerIsVisible() -> Bool {
        return self.viewModel.isHeaderVisible
    }
    func headerIsSelectedAll() -> Bool {
        if let multipleSelectedState = self.viewModel.state as? SelectMultipleInterestsStateProtocol {
            return multipleSelectedState.isSelectedAll
        } else {
            return false
        }
    }
    // MARK: - implement SelectInterestHeaderDelegate
    func onHeaderClickSelectAll() {
        if var multiViewModel = self.viewModel as? SelectUserInterestsViewModel {
            multiViewModel.onSelectAll()
            self.viewModel = multiViewModel as! T
        }
    }
    func onHeaderClickNavItem() {
        self.viewModel.navigateNavItem?()
    }

    
    // MARK: - implement SelectSubinterestsDataSource
    func selectSubinterestsItems() -> [InterestModel] {
        guard let interest = self.viewModel.state.opened else { return [] }
        return InterestService.getSubinterestsOf(interest)
    }
    func selectSubinterestsIsSelected(subinterest: InterestModel) -> Bool {
        return self.viewModel.isSubinterestSelected(subinterest)
    }
    func selectSubinterestsCellHeight() -> CGFloat {
        return self.getCollectionViewHeightAlternative()
    }
    // MARK: - implement SelectSubinterestsDelegate
    func selectSubinterestsDidClose() {
        self.viewModel.onCloseSubinterests()
    }
    func selectSubinterests(didSelect subinterest: InterestModel) {
        self.viewModel.onSelectSubinterest(subinterest)
    }


    
    
    // init size
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return self.getCellSize()
    }

    // init header
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {

        var headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: self.headerIdentifier, forIndexPath: indexPath) as! SelectInterestHeaderProtocol

        headerView.dataSource = self
        headerView.delegate = self

        return headerView as! UICollectionReusableView
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {

        return self.getHeaderSize()
    }

    // init event on scroll
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        self.viewModel.onScroll(Int(scrollView.contentOffset.y))
    }

    // init event on click
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.viewModel.onSelectInterest(self.getInterestBy(indexPath))
    }

    // react to longPressed
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        let cell = cell as! SelectInterestCollectionCell

        //when some interest long pressed
        //unfocus all cells except longPressedInterest
        if let focusedInterest = self.viewModel.state.opened {
            if  let focusedInterestIndex = self.viewModel.state.items.indexOf(focusedInterest)
                where indexPath.row == focusedInterestIndex {
                cell.viewUnfocus.hidden = true
            } else {
                cell.viewUnfocus.hidden = false
            }
        } else {
            cell.viewUnfocus.hidden = true
        }
    }

    // fill with data
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.state.items.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(self.cellIdentifier, forIndexPath: indexPath) as! SelectInterestCollectionCell

        let interest = self.getInterestBy(indexPath)
        let name = interest.title.uppercaseString
        cell.labelName.text = name
        if let image = interest.image {
            if let url = image.getURL() {
                cell.imagePhoto.hnk_setImageFromURL(url)
                cell.imagePhoto.layer.masksToBounds = true
            }
            if let colorCode = image.color {
                cell.viewFooter.backgroundColor = UIColor(hexString: colorCode)
            }
        }

        switch self.viewModel.getSelectionType(interest) {
        case .NonSelected:
            cell.viewSelectionInfo.hidden = true

            cell.viewSelectedSome.hidden = true
            cell.viewSelectedAll.hidden = true

        case .SelectedAll:
            cell.viewSelectionInfo.hidden = false

            cell.viewSelectedSome.hidden = true
            cell.viewSelectedAll.hidden = false

        case .SelectedSome(let numberOfSelected, let count):
            cell.viewSelectionInfo.hidden = false

            cell.viewSelectedSome.hidden = false
            cell.viewSelectedAll.hidden = true

            cell.labelSelectedSomeText.text = "\(numberOfSelected)/\(count)"
        }

        return cell
    }

}



