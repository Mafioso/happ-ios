//
//  ChatsController.swift
//  Happ
//
//  Created by Aleksei Pugachev on 2/18/17.
//  Copyright © 2017 Sattar Stamkulov. All rights reserved.
//

import UIKit

let loc_manager_empty_chats = NSLocalizedString("Nobody post a message to you, begin with creating an event", comment: "Message displayed in ChatsController when manager chats are empty")
let loc_empty_chats = NSLocalizedString("You can start a chat in Events feed", comment: "Message displayed in ChatsController when chats are empty")
let loc_manager_empty_chats_button = NSLocalizedString("Create your Event", comment: "Button title in ChatsController when manager chats are empty")
let loc_empty_chats_button = NSLocalizedString("Find Awesome Events", comment: "Button title in ChatsController when chats are empty")

class ChatsController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var buttonAction: UIButton!
    @IBOutlet weak var emptyDescription: UILabel!
    
    var viewModel: ChatsViewModel! {
        didSet {
            self.updateView()
        }
    }
    
    @IBAction func buttonActionClick(sender: AnyObject) {
        if self.viewModel.manager {
            self.viewModel.navigateEventCreate?()
        }else{
            self.viewModel.navigateEvents?()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initTableView()
        self.initDataLoading()
        self.extMakeStatusBarWhite()
        
        buttonAction.extMakeCircle()
        
        emptyDescription.text = viewModel.manager ? loc_manager_empty_chats : loc_empty_chats
        buttonAction.setTitle(viewModel.manager ? loc_manager_empty_chats_button : loc_empty_chats_button, forState: .Normal)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.initNavBarItems()
        self.extMakeNavBarVisible()
        self.extMakeNavBarTransparrent()
    }
    
    private func updateView() {
        guard self.isViewLoaded() else { return }
        
        if self.viewModel.isLoadingFirstDataPage() || !self.viewModel.state.items.isEmpty {
            self.emptyView.hidden = true
            self.tableView.reloadData()
        } else {
            self.emptyView.hidden = false
        }
    }
    
    private func initDataLoading() {
        if self.viewModel.willLoadNextDataPage() {
            self.viewModel.onLoadFirstDataPage() { state in
                self.viewModel.state = state
            }
        }
    }
    
    private func initNavBarItems() {
        self.navigationItem.title = loc_chats_long
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "nav-menu"), style: .Plain, target: self, action: #selector(handleClickNavItemMenu(withSender:)))
    }
    
    private func initTableView() {
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    func handleClickNavItemMenu(withSender sender: UIButton) {
        self.viewModel.displaySlideMenu?()
    }
    
}

extension ChatsController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.viewModel.isLoadingFirstDataPage() {
            return 4
        } else {
            return self.viewModel.state.items.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if self.viewModel.isLoadingFirstDataPage() {
            let cell = self.tableView.dequeueReusableCellWithIdentifier(ReuseIdentifier.Loading.rawValue, forIndexPath: indexPath) as! ChatLoadingTableCell
            cell.selectionStyle = .None
            return cell
        } else {
            let cell = self.tableView.dequeueReusableCellWithIdentifier(ReuseIdentifier.Cell.rawValue, forIndexPath: indexPath) as! ChatTableCell
            
            if let chat = self.viewModel.state.items[indexPath.row] as? ChatModel {
                cell.avatar.image = nil
                cell.avatar.hnk_setImageFromURL(NSURL(string: "http://happ.skills.kz/static/images/noavatar.jpg")!)
                cell.selectionStyle = .None
                cell.name.text = chat.name
                cell.message.text = chat.message
                if chat.unread > 0 {
                    cell.newMessages.text = "\(chat.unread)"
                    cell.newMessages.hidden = false
                }else{
                    cell.newMessages.hidden = true
                }
            }
            
            return cell
        }
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return ChatTableCell.estimatedHeight
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == self.viewModel.state.items.count - 3 {
            self.viewModel.onLoadNextDataPage() { state in
                self.viewModel.state = state
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if !self.viewModel.isLoadingFirstDataPage() {
            if let chat = self.viewModel.state.items[indexPath.row] as? ChatModel {
                if let author = chat.author {
                    if self.viewModel.manager {
                        self.viewModel.navigateChat?(object: author)
                    }else{
                        self.viewModel.navigateAsk?(object: author)
                    }
                }
            }
        }
    }
    
}
