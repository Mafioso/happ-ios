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

let loc_explore = NSLocalizedString("Explore", comment: "Title of NavBar for EventsExploreViewController")

class EventsExploreViewController: UICollectionViewController {

    
    var viewModel: EventsExploreViewModel! {
        didSet {
            self.updateView()
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        print(".Explore.loading.init")
        self.viewModel.onInitLoadingData() { asyncState in
            print(".Explore.loading.done", EventService.mutexCurrentPageType)
            self.viewModel.state = asyncState
        }
        
        self.initNavBarItems()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.extMakeNavBarWhite()
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        self.extMakeNavBarVisible()
    }



    func updateView() {
        //print(".updateView", self.viewModel.state.isFetching, self.viewModel.state.items.count)
        self.collectionView!.reloadData()
    }


    // init size
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        //print(".cellSize", indexPath.row)
        return CGSizeMake(min(124, screenSize.width*0.33), 164)
    }

    // fill with data
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        print(".Explore.rows.number isLoading", self.viewModel.isInitLoadingData())

        if self.viewModel.isInitLoadingData() {
            return 10
        } else {
            //print(".numberOfItems", self.viewModel.state.items.count)
            return self.viewModel.state.items.count
        }

    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        //print(".cell", indexPath.row)

        if self.viewModel.isInitLoadingData() {
            let cellLoading = collectionView.dequeueReusableCellWithReuseIdentifier(reuseLoadingIdentifier, forIndexPath: indexPath) as! EventExploreLoadingCollectionViewCell
            return cellLoading

        } else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! EventExploreCollectionViewCell
            let event = self.viewModel.state.items[indexPath.row]

            //print(".cellForItemAt.", event.id, event.invalidated, indexPath.row)

            cell.labelTitle.text = event.title
            if let image = event.images.first {
                if let url = image.getURL() {
                    cell.image.hnk_setImageFromURL(url)
                }
                if  let colorCode = image.color {
                    cell.viewTitleContainer.backgroundColor = UIColor(hexString: colorCode)
                }
            }

            return cell
        }
    }

    /*
    // init pagination
    override func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {

        if  indexPath.row == self.viewModel.state.items.count - 1 &&
            self.viewModel.state.isFetching == false
        {
            self.viewModel.onInitLoadingNextData() { asyncState in
                self.viewModel.state = asyncState
            }
        }
    }
    */

    // init action handle
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let state = self.viewModel.state

        if self.viewModel.isInitLoadingData() {
            // do nothing
        } else {
            let event = state.items[indexPath.row]
            self.viewModel.onClickEvent(event)
        }
    }



    private func initNavBarItems() {
        self.navigationItem.title = loc_explore
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "nav-menu"), style: .Plain, target: self, action: #selector(handleClickMenuNavItem))
    }
    func handleClickMenuNavItem() {
        self.viewModel.displaySlideMenu?()
    }
}




