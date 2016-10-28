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
    var viewModelSelectCity: SelectCityViewModel! {
        didSet {
            self.bindToSelectCityViewModel()
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
    @IBAction func clickedChangeProfile(sender: UIButton) {
        self.viewModelMenu.navigateProfile?()
    }

    // constants
    let segueEmbeddedTableMenu = "embeddedTableMenu"
    let segueEmbeddedSelectCity = "embeddedTableSelectCity"

    // variables
    var tableMenuActions: UITableView!
    var tableViewControllerSelectCity: MenuSelectCityController!


    override func viewDidLoad() {
        super.viewDidLoad()

        self.initNavigationBarItems()
        
        let tappableGesture = UITapGestureRecognizer(target: self, action: #selector(onClickChangeCity))
        self.tappableViewChangeCity.addGestureRecognizer(tappableGesture)


        if let user = self.viewModelMenu.user {
            // TODO
            // let imageURL = NSURL(user...)
            // imageUserPhoto.hnk_setImageFromURL(imageURL)
            imageUserPhoto.image = UIImage(named: "bg-feed")
            labelUserFullname.text = user.fullname
        }
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        let highlightedIndexPath = NSIndexPath(forRow: self.viewModelMenu.highlight.rawValue, inSection: 0)
        self.tableMenuActions.selectRowAtIndexPath(highlightedIndexPath, animated: true, scrollPosition: .None)
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == segueEmbeddedTableMenu {
            let dest = segue.destinationViewController as! UITableViewController
            self.tableMenuActions = dest.tableView
            self.tableMenuActions.delegate = self
        }
        if segue.identifier == segueEmbeddedSelectCity {
            let dest = segue.destinationViewController as! MenuSelectCityController
            self.tableViewControllerSelectCity = dest
            self.tableViewControllerSelectCity.viewModel = self.viewModelSelectCity
        }
    }


    func viewModelDidUpdate() {
        self.updateScopeViews()
    }
    func viewModelSelectCityDidLoad() {
        labelChangeCity.text = self.viewModelSelectCity.selectedCity?.name
    }

    private func bindToViewModel() {
        self.viewModelMenu.didUpdate = { [weak self] _ in
            self?.viewModelDidUpdate()
        }
    }
    func bindToSelectCityViewModel() {
        self.viewModelSelectCity.didLoad = { [weak self] _ in
            self?.viewModelSelectCityDidLoad()
        }
        self.viewModelSelectCity.didSelectCity = { [weak self] (city: CityModel) in
            self?.onChangeCity()
        }
    }

    

    func updateScopeViews() {
        switch self.viewModelMenu.scope {
        case .Normal:
            UIView.transitionFromView(viewSelectCity, toView: viewMenu, duration: 0.0, options: UIViewAnimationOptions.ShowHideTransitionViews, completion: nil)
            labelChangeCity.text = self.viewModelSelectCity.selectedCity?.name

            UIView.animateWithDuration(0.25, animations: {
                self.iconChangeCity.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
            })

        case .ChangeCity:
            UIView.transitionFromView(viewMenu, toView: viewSelectCity, duration: 0.0, options: UIViewAnimationOptions.ShowHideTransitionViews, completion: nil)
            labelChangeCity.text = "select city"

            UIView.animateWithDuration(0.25, animations: {
                self.iconChangeCity.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
            })
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print(".menu.selectAction")
        let action = MenuActions(rawValue: indexPath.section * 10 + indexPath.row)!
        self.viewModelMenu.onClickAction(action)
    }
    func onClickChangeCity() {
        print(".menu.changeScope")
        let newScope = self.viewModelMenu.scope.opposite()
        self.viewModelMenu.onChangeScope(newScope)
    }
    func onChangeCity() {
        print(".menu.changeCity")
        self.viewModelMenu.onChangeScope(.Normal)
    }

}


extension MenuViewController {

    private func initNavigationBarItems() {
        let navBarBack = HappNavBarItem(position: .Left, icon: "nav-close-shadow")
        navBarBack.button.addTarget(self, action: #selector(handleClickNavBack), forControlEvents: .TouchUpInside)
        self.view.addSubview(navBarBack)
    }
    func handleClickNavBack() {
        self.viewModelMenu.navigateBack?()
    }
}


