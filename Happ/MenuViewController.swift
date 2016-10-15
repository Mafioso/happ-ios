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

    var viewModel: MenuViewModel! {
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
    @IBAction func clickedChangeProfile(sender: UIButton) {
        self.viewModel.navigateProfile?()
    }

    // constants
    let segueEmbeddedTableMenu = "embeddedTableMenu"
    let segueEmbeddedSelectCity = "embeddedTableSelectCity"

    // variables
    var tableMenuActions: UITableView!
    var viewControllerSelectCity: MenuSelectCityController!


    override func viewDidLoad() {
        super.viewDidLoad()


        self.initNavigationBarItems()
        
        let tappableGesture = UITapGestureRecognizer(target: self, action: #selector(onClickChangeCity))
        self.tappableViewChangeCity.addGestureRecognizer(tappableGesture)


        if let user = self.viewModel.user {
            // TODO
            // let imageURL = NSURL(user...)
            // imageUserPhoto.hnk_setImageFromURL(imageURL)
            imageUserPhoto.image = UIImage(named: "bg-feed")
            labelUserFullname.text = user.fullname
        }

        labelChangeCity.text = "Almaty" // TODO
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == segueEmbeddedTableMenu {
            let dest = segue.destinationViewController as! UITableViewController
            self.tableMenuActions = dest.tableView
            // init Menu state
            self.tableMenuActions.delegate = self
        }
        if segue.identifier == segueEmbeddedSelectCity {
            let dest = segue.destinationViewController as! MenuSelectCityController
            self.viewControllerSelectCity = dest
            // init SelectCity state
            self.viewControllerSelectCity.viewModel = SelectCityViewModel()
            self.viewControllerSelectCity.handleSelect = self.onSelectCity
        }
    }


    func viewModelDidUpdate() {
        self.updateScopeViews()
    }
    private func bindToViewModel() {
        self.viewModel.didUpdate = { [weak self] _ in
            self?.viewModelDidUpdate()
        }
    }

    
    func updateScopeViews() {
        switch self.viewModel.scope {
        case .Normal:
            UIView.transitionFromView(viewSelectCity, toView: viewMenu, duration: 0.0, options: UIViewAnimationOptions.ShowHideTransitionViews, completion: nil)
            labelChangeCity.text = "Almaty" //self.viewModel.user.city.name TODO

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

        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                self.viewModel.navigateFeed?()
            case 1:
                self.viewModel.navigateSelectInterests?()
            case 2:
                self.viewModel.navigateEventPlanner?()
            default:
                break
            }
        case 1:
            switch indexPath.row {
            case 1:
                self.viewModel.navigateSettings?()
            case 2:
                self.viewModel.navigateLogout?()
            default:
                break
            }
        default:
            break
        }
    }

    func onClickChangeCity() {
        print(".tap")
        self.viewModel.onChangeScope(self.viewModel.scope.opposite())
    }

    func onSelectCity(city: CityModel) {
        print(".here", city)
    }
}


extension MenuViewController {

    private func initNavigationBarItems() {
        let navBarBack = HappNavBarItem(position: .Left, icon: "cross-shadow")
        navBarBack.button.addTarget(self, action: #selector(handleClickNavBack), forControlEvents: .TouchUpInside)
        self.view.addSubview(navBarBack)
    }
    func handleClickNavBack() {
        self.viewModel.navigateBack?()
    }
}


