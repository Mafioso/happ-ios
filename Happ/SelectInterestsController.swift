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
    @IBOutlet weak var buttonNavMenuSecond: UIButton!
    @IBOutlet weak var buttonSave: UIButton!
    

    // actions
    @IBAction func clickedSave(sender: UIButton) {
        self.viewModel.navigateBack?()
    }
    @IBAction func clickedNavMenuSecond(sender: UIButton) {
        self.viewModel.displaySlideMenu?()
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView.dataSource = self
        self.collectionView.delegate = self

        // TODO self.viewModelDidUpdate()
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
        print(".SelectInterestsController.viewModelDidUpdate", self.viewModel.interests.count, self.viewModel.isHeaderVisible)
        self.collectionView.reloadData()
        self.buttonNavMenuSecond.hidden = self.viewModel.isHeaderVisible
    }

    private func bindToViewModel() {
        let superDidUpdate: (() -> ())? = self.viewModel.didUpdate
        self.viewModel.didUpdate = { [weak self] _ in
            superDidUpdate?()

            self?.viewModelDidUpdate()
        }
    }

}


extension SelectInterestsController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    // init size
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(124, 164)
    }

    // init header
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let headerID = "header"
        let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: headerID, forIndexPath: indexPath) as! SelectInterestsHeader
        headerView.viewModel = self.viewModel
        return headerView
    }

    // init event on scroll
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        self.viewModel.onScroll(Int(scrollView.contentOffset.y))
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

        let interest = self.viewModel.interests[indexPath.row]
        cell.labelName.text = interest.title
        // cell.viewFooter.backgroundColor = UIColor(hexString: "#"+interest.color)
        // cell.imagePhoto.hnk_setImageFromURL()

        switch self.viewModel.getInterestSelectionTypeFor(interest) {
        case .NonSelected:
            cell.viewSelectionInfo.hidden = true

        case .SelectedAll:
            cell.viewSelectionInfo.hidden = false
            UIView.transitionFromView(
                cell.viewSelectedSome,
                toView: cell.viewSelectedAll,
                duration: 0.3, options: UIViewAnimationOptions.ShowHideTransitionViews, completion: nil)

        case .SelectedSome(let numberOfSelected, let count):
            cell.viewSelectionInfo.hidden = false
            cell.labelSelectedSomeText.text = "\(numberOfSelected)/\(count)"
            UIView.transitionFromView(
                cell.viewSelectedAll,
                toView: cell.viewSelectedSome,
                duration: 0.3, options: UIViewAnimationOptions.ShowHideTransitionViews, completion: nil)
        }

        return cell
    }
    
}



