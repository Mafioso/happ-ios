//
//  FeedCollectionViewController.swift
//  Happ
//
//  Created by MacBook Pro on 9/19/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit
import Foundation


private let reuseIdentifier = "Cell"


class FeedCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {


    var viewModel: FeedViewModel! {
        didSet {
            self.bindToViewModel()
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        self.displayNavigationBar()

        self.collectionView!.registerNib(UINib(nibName: EventCollectionCell.nibName, bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)

        self.viewModelDidUpdate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    private func bindToViewModel() {
        self.viewModel.didUpdate = { [weak self] _ in
            self?.viewModelDidUpdate()
        }
    }

    func viewModelDidUpdate() {
        self.collectionView?.reloadData()
    }


    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {


        return CGSizeMake(collectionView.bounds.size.width, 233)
    }


    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.events.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! EventCollectionCell

        // configure cell
        let event = self.viewModel.events[indexPath.row]
        cell.setup(event)
        cell.onClickLikeButton = self.viewModel.clickedLikeOnEvent
        
        return cell
    }
    
    
    // MARK: UICollectionViewDelegate

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let event = self.viewModel.events[indexPath.row]

        self.viewModel.clickedOnEvent(event)
    }

}



extension FeedCollectionViewController {
    
    private func displayNavigationBar() {
        // Create the navigation bar
        let navigationBar = UINavigationBar(frame: CGRectMake(0, 20, self.view.frame.size.width, 44)) // Offset by 20 pixels vertically to take the status bar into account
        navigationBar.backgroundColor = UIColor.whiteColor()

        // Create a navigation item with a title
        let navigationItem = UINavigationItem()
        navigationItem.title = "Title"
        
        // Create left and right button for navigation item
        let leftButton = UIBarButtonItem(image: UIImage(named: "menu-tab"), style: .Plain, target: self, action: #selector(FeedCollectionViewController.handleClickOnMenu))
        let rightButton = UIBarButtonItem(title: "Right", style: .Plain, target: self, action: nil)

        // Create two buttons for the navigation item
        navigationItem.leftBarButtonItem = leftButton
        navigationItem.rightBarButtonItem = rightButton
        
        // Assign the navigation item to the navigation bar
        navigationBar.items = [navigationItem]
        
        // Make the navigation bar a subview of the current view controller
        self.view.addSubview(navigationBar)
    }

    func handleClickOnMenu() {
        self.viewModel.displaySlideMenu!()
    }
}




