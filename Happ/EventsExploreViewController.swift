//
//  ExploreController.swift
//  Happ
//
//  Created by MacBook Pro on 11/10/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit

private let reuseIdentifier = "cell"
private let reuseLoadingIdentifier = "cellLoading"



class EventsExploreViewController: UICollectionViewController {

    
    var viewModel: EventsExploreViewModel! {
        didSet {
            self.bindToViewModel()
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        print(".explore.didLoad")

        self.initNavBarItems()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print(".explore.willAppear")

        self.extMakeNavBarWhite()
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        print(".explore.didDissapear")

        self.extMakeNavBarVisible()
    }


    
    func viewModelDidUpdate() {
        self.collectionView!.reloadData()
    }

    private func bindToViewModel() {
        self.viewModel.didUpdate = { [weak self] _ in
            self?.viewModelDidUpdate()
        }
    }


    // init size
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        return CGSizeMake(min(124, screenSize.width*0.33), 164)
    }

    // fill with data
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let state = self.viewModel.state

        if state.fetchingState == .StartRequest {
            return 10
            
        } else {
            return state.events.count
        }
    }
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let state = self.viewModel.state

        if state.fetchingState == .StartRequest {
            let cellLoading = collectionView.dequeueReusableCellWithReuseIdentifier(reuseLoadingIdentifier, forIndexPath: indexPath) as! EventExploreLoadingCollectionViewCell
            return cellLoading

        } else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! EventExploreCollectionViewCell
            let event = state.events[indexPath.row]

            cell.labelTitle.text = event.title
            if let imageURL = event.images.first?.getURL() {
                cell.image.hnk_setImageFromURL(imageURL)
            }
            if let color = event.color {
                cell.viewTitleContainer.backgroundColor = UIColor(hexString: color)
            }

            return cell
        }
    }
    
    // init pagination
    override func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {

        if indexPath.row == self.viewModel.state.events.count - 3 {
            self.viewModel.loadNextPage()
        }
    }

    // init action handle
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let state = self.viewModel.state

        if state.fetchingState == .StartRequest {
            // do nothing
        } else {
            let event = state.events[indexPath.row]
            self.viewModel.onClickEvent(event)
        }
    }



    private func initNavBarItems() {
        self.navigationItem.title = "Explore"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "nav-menu"), style: .Plain, target: self, action: #selector(handleClickMenuNavItem))
    }
    func handleClickMenuNavItem() {
        self.viewModel.displaySlideMenu?()
    }
}




