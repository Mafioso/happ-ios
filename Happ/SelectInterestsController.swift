//
//  SelectInterestsController.swift
//  Happ
//
//  Created by MacBook Pro on 10/31/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit


class SelectInterestsController: UIViewController {

    var viewModel: SelectInterestsViewModel!  {
        didSet {
            self.bindToViewModel()
        }
    }


    // outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var buttonNavItemSecond: UIButton!
    @IBOutlet weak var buttonSave: UIButton!

    // actions
    @IBAction func clickedSave(sender: UIButton) {
        self.viewModel.onSave()
    }
    @IBAction func clickedNavItemSecond(sender: UIButton) {
        self.viewModel.onClickNavItem()
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.initNavItems()
        self.initLongPressGesture()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.extMakeNavBarHidden()
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        self.extMakeNavBarVisible()
    }


    func viewModelDidUpdate() {
        print(".VMdidUpdate", self.viewModel.interests.count)

        self.collectionView.reloadData()
        self.updateNavItems()
        self.willDisplayPopoverSelectSubinterests()
    }

    private func bindToViewModel() {
        let superDidUpdate: (() -> ())? = self.viewModel.didUpdate
        self.viewModel.didUpdate = { [weak self] _ in
            superDidUpdate?()

            self?.viewModelDidUpdate()
        }
    }
    

    private func initNavItems() {
        switch self.viewModel.scope {
        case .MenuChangeInterests:
            self.buttonNavItemSecond.setImage(UIImage(named: "nav-menu-shadow"), forState: .Normal)
        case .EventManage:
            self.buttonNavItemSecond.setImage(UIImage(named: "nav-back-shadow"), forState: .Normal)
        default:
            break
        }
    }
    private func updateNavItems() {
        switch self.viewModel.scope {
        case .MenuChangeInterests, .EventManage:
            self.buttonNavItemSecond.hidden = self.viewModel.isHeaderVisible
        default:
            self.buttonNavItemSecond.hidden = true
        }
    }
    private func willDisplayPopoverSelectSubinterests() {
        // to display popup over selected cell, we do:
        // 1. Minimize CollectionView by adding Height Constraint
        // 2. present ViewController as Popover

        if self.getHeightConstraint() == nil {
            // minimize collectionView to able scroll to the bottom
            self.createHeightConstraint()
        }

        if  let longPressedInterest = self.viewModel.longPressedInterest,
            let indexOfInterest = self.viewModel.interests.indexOf(longPressedInterest) {

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
        let cellHeigh = self.getCellSize().height
        let statusBarHeight = CGFloat(20)
        let heightConstraint = NSLayoutConstraint(item: self.collectionView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: cellHeigh + statusBarHeight + 1)
        heightConstraint.identifier = "height"
        heightConstraint.active = true
        self.collectionView.addConstraint(heightConstraint)
        self.collectionView.updateConstraints()
    }
    private func getInterestBy(indexPath: NSIndexPath) -> InterestModel {
        return self.viewModel.interests[indexPath.row]
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
}


extension SelectInterestsController: UIGestureRecognizerDelegate {

    func onLongPressCell(gesture : UILongPressGestureRecognizer!) {
        if gesture.state != .Ended {
            return
        }
        let p = gesture.locationInView(self.collectionView)
        if let indexPath = self.collectionView.indexPathForItemAtPoint(p) {
            self.viewModel.onLongPressInterest(self.getInterestBy(indexPath))

        } else {
            print("couldn't find index path")
        }
    }

    private func initLongPressGesture() {
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(self.onLongPressCell))
        lpgr.minimumPressDuration = 0.3
        lpgr.delaysTouchesBegan = true
        lpgr.delegate = self
        self.collectionView.addGestureRecognizer(lpgr)
    }
}


extension SelectInterestsController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    // init size
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return self.getCellSize()
    }

    // init header
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let headerID = "header"
        let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: headerID, forIndexPath: indexPath) as! SelectInterestsHeader
        headerView.viewModel = self.viewModel
        return headerView
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if self.viewModel.isAllowsMultipleSelection() {
            return CGSize(width: collectionView.frame.width, height: 118)
        } else {
            return CGSize(width: collectionView.frame.width, height: 44)
        }
    }

    // init event on scroll
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        self.viewModel.onScroll(Int(scrollView.contentOffset.y))
    }
    
    // init event on click
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.viewModel.onSelectInterest(self.getInterestBy(indexPath))
    }

    // init pagination and react to longPressed
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        let cell = cell as! InterestCollectionViewCell

        //when some interest long pressed
        //unfocus all cells except longPressedInterest
        if let focusedInterest = self.viewModel.longPressedInterest {
            if  let focusedInterestIndex = self.viewModel.interests.indexOf(focusedInterest)
                where indexPath.row == focusedInterestIndex {
                cell.viewUnfocus.hidden = true
            } else {
                cell.viewUnfocus.hidden = false
            }
        } else {
            cell.viewUnfocus.hidden = true
        }

        if indexPath.row > self.viewModel.interests.count - 3 {
            self.viewModel.onLoadNextPage()
        }
    }

    // fill with data
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("..numberOfItems", self.viewModel.interests.count)
        return self.viewModel.interests.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cellID = "cell"
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellID, forIndexPath: indexPath) as! InterestCollectionViewCell

        let interest = self.getInterestBy(indexPath)
        cell.labelName.text = interest.title.uppercaseString
        // TODO:
        // cell.viewFooter.backgroundColor = UIColor(hexString: "#"+interest.color)
        // cell.imagePhoto.hnk_setImageFromURL()

        switch self.viewModel.getInterestSelectionTypeFor(interest) {
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



