//
//  ExploreController.swift
//  Happ
//
//  Created by MacBook Pro on 11/10/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit

private let reuseIdentifier = "cell"



class EventsExploreViewController: UICollectionViewController {

    
    var viewModel: EventsExploreViewModel! {
        didSet {
            self.bindToViewModel()
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()

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


    
    func viewModelDidUpdate() {
        print(".VMdidUpdate", self.viewModel.events.count)

        self.collectionView!.reloadData()
    }

    private func bindToViewModel() {
        self.viewModel.didUpdate = { [weak self] _ in
            self?.viewModelDidUpdate()
        }
    }

    
    // size
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        return CGSizeMake(screenSize.width*0.33, 164)
        //return CGSizeMake(124, 164)
    }
    // data source
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.events.count
    }
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! EventExploreCollectionViewCell
        let event = self.viewModel.events[indexPath.row]
        
        cell.labelTitle.text = event.title
        if let imageURL = event.images.first {
            cell.image.hnk_setImageFromURL(imageURL!)
        }
        if let color = event.color {
            cell.viewTitleContainer.backgroundColor = UIColor(hexString: color)
        }

        return cell
    }
    // events handle
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let event = self.viewModel.events[indexPath.row]
        self.viewModel.onClickEvent(event)
    }


    private func initNavBarItems() {
        self.navigationItem.title = "Explore"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "nav-menu"), style: .Plain, target: self, action: #selector(handleClickMenuNavItem))
    }
    func handleClickMenuNavItem() {
        self.viewModel.displaySlideMenu?()
    }
}




