//
//  MenuViewController.swift
//  Happ
//
//  Created by Aigerim'sMac on 28.09.16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit
import Haneke


class MenuViewController: UIViewController, UITableViewDelegate {

    var viewModelMenu: MenuViewModel! {
        didSet {
            self.bindToViewModel()
        }
    }


    // outlets
    @IBOutlet weak var imageUserPhoto: UIImageView!
    @IBOutlet weak var labelUserFullname: UILabel!
    @IBOutlet weak var labelChangeCity: UILabel!
    @IBOutlet weak var iconChangeCity: UIImageView!

    @IBOutlet weak var tappableViewChangeCity: UIView!
    @IBOutlet weak var viewMenu: UIView!
    @IBOutlet weak var viewSelectCity: UIView!


    // action
    @IBAction func clickedCloseButton(sender: UIButton) {
        self.viewModelMenu.navigateBack?()
    }
    @IBAction func clickedChangeProfile(sender: UIButton) {
        self.viewModelMenu.navigateProfile?()
    }

    // constants
    let segueEmbeddedTableMenu = "embeddedTableMenu"
    let segueEmbeddedSelectCity = "embeddedTableSelectCity"

    // variables
    var tableMenuActions: UITableView!
    var tableViewControllerSelectCity: SelectCityOnMenuController!


    override func viewDidLoad() {
        super.viewDidLoad()

        let tappableGesture = UITapGestureRecognizer(target: self, action: #selector(onClickChangeCity))
        self.tappableViewChangeCity.addGestureRecognizer(tappableGesture)
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.viewModelDidUpdate()
        
        let highlightedIndexPath = NSIndexPath(forRow: self.viewModelMenu.highlight.rawValue, inSection: 0)
        self.tableMenuActions.selectRowAtIndexPath(highlightedIndexPath, animated: true, scrollPosition: .None)
    }
    override func viewDidLayoutSubviews() {
        let footerHeight = CGFloat(37)
        self.tableMenuActions.contentSize.height = self.tableMenuActions.contentSize.height + footerHeight
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == segueEmbeddedTableMenu {
            let dest = segue.destinationViewController as! UITableViewController
            self.tableMenuActions = dest.tableView
            self.tableMenuActions.delegate = self
        }
        if segue.identifier == segueEmbeddedSelectCity {
            // TODO
            // let dest = segue.destinationViewController as! SelectCityOnMenuController
            // self.tableViewControllerSelectCity = dest
            // self.tableViewControllerSelectCity.viewModel = self.viewModelSelectCity
        }
    }


    func viewModelDidUpdate() {
        // let imageURL = NSURL(user...)
        // imageUserPhoto.hnk_setImageFromURL(imageURL)
        imageUserPhoto.image = UIImage(named: "bg-feed")
        labelUserFullname.text = self.viewModelMenu.getUser().fullname

        self.updateScopeViews()
        self.tableMenuActions.reloadData()
    }


    private func bindToViewModel() {
        self.viewModelMenu.didUpdate = { [weak self] _ in
            self?.viewModelDidUpdate()
            //self?.viewModelSelectCity.didUpdate?()
        }
    }/*
    func bindToSelectCityViewModel() {
        self.viewModelSelectCity.didChangeCity = { [weak self] in
            self?.viewModelMenu.onChangeCity()
        }
    }*/


    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {

        if  let action = MenuActions(rawValue: indexPath.section * 10 + indexPath.row)
            where action == self.viewModelMenu.highlight {
            cell.extSetHighlighted()
        } else {
            cell.extUnsetHighlighted()
        }
        
    }


    func updateScopeViews() {
        switch self.viewModelMenu.state {
        case .Normal:
            UIView.transitionFromView(viewSelectCity, toView: viewMenu, duration: 0.5, options: UIViewAnimationOptions.ShowHideTransitionViews, completion: nil)
            //TODO labelChangeCity.text = self.viewModelSelectCity.selectCityState.selected!.name

            UIView.animateWithDuration(0.25, animations: {
                self.iconChangeCity.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
            })

        case .ChangeCity:
            UIView.transitionFromView(viewMenu, toView: viewSelectCity, duration: 0.5, options: UIViewAnimationOptions.ShowHideTransitionViews, completion: nil)
            labelChangeCity.text = "select city"

            UIView.animateWithDuration(0.25, animations: {
                self.iconChangeCity.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
            })
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print(".menu.selectAction")
        if let action = MenuActions(rawValue: indexPath.section * 10 + indexPath.row) {
            self.viewModelMenu.onClickAction(action)
        }
    }
    func onClickChangeCity() {
        self.viewModelMenu.onClickChangeCity()
    }

}


