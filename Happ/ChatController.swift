//
//  ChatController.swift
//  Happ
//
//  Created by Aleksei Pugachev on 2/19/17.
//  Copyright © 2017 Sattar Stamkulov. All rights reserved.
//

import UIKit
import QMChatViewController
import PromiseKit

class ChatController: QMChatViewController, QBChatDelegate {
    
    var viewModel: ChatViewModel!
    var recipientID: UInt = 0
    
    var loaderView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.inputToolbar.contentView.leftBarButtonItem.enabled = false
        self.navigationController?.navigationBar.topItem?.title = ""
        
        let imageView = UIImageView(image: UIImage(named: "chat-background"))
        imageView.frame.origin.y = 65
        self.view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
        
        let navView = UIView(frame: CGRect(x: 0, y: 20, width: ScreenSize.SCREEN_WIDTH, height: 45))
        navView.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(navView)
        
        loaderView = UIView(frame: CGRect(x: 0, y: 65, width: ScreenSize.SCREEN_WIDTH, height: ScreenSize.SCREEN_HEIGHT - 114))
        loaderView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.8)
        self.view.addSubview(loaderView)
        
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        spinner.color = UIColor.happOrangeColor()
        spinner.center.x = loaderView.center.x
        spinner.center.y = loaderView.frame.height / 2 - spinner.frame.height / 2
        spinner.startAnimating()
        self.loaderView.addSubview(spinner)
        
        viewModel.chatDidLoad = {
            self.loadMessages()
        }
        
        self.extMakeStatusBarWhiteSolid()
        self.extMakeNavBarTransparrent()
        
        self.senderDisplayName = ProfileService.getUserProfile().fullname
        self.senderID = UInt(ProfileService.getUserProfile().qbID)
        
        self.title = self.viewModel.opponent?.fn
        self.recipientID = UInt(self.viewModel.opponent!.qbID)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        QBChat.instance().addDelegate(self)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        QBChat.instance().removeDelegate(self)
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: UInt, senderDisplayName: String!, date: NSDate!) {
        if let chat = self.viewModel.chat {
            let message = QBChatMessage()
            message.text = text
            message.senderID = self.senderID
            message.dialogID = chat.ID
            message.dateSent = date
            message.readIDs = [(NSNumber(unsignedInteger: self.senderID))]
            message.markable = true
            
            let params = NSMutableDictionary()
            params["send_to_chat"] = "1"
            message.customParameters = params
            
            sendMessage(message)
        }
    }
    
    func loadMessages() {
        self.viewModel.getData(true).then { _messages -> Void in
            if let messages = _messages {
                self.chatDataSource.addMessages(messages)
                messages.forEach {
                    if $0.markable {
                        if $0.readIDs?.contains(self.senderID) == nil {
                            QBChat.instance().readMessage($0, completion: { _ in })
                        }
                    }
                }
                self.finishReceivingMessage()
                UIView.animateWithDuration(0.3) {
                    self.loaderView.alpha = 0
                }
            }
        }
    }
    
    func sendMessage(message: QBChatMessage) {
        self.chatDataSource.addMessage(message)
        self.finishSendingMessage()
        ChatService.sendMessage(message).then { _ -> Void in }
    }
    
    func chatDidReceiveMessage(message: QBChatMessage) {
        if self.viewModel.chat?.ID == message.dialogID {
            QBChat.instance().readMessage(message, completion: { _ in })
            self.chatDataSource.addMessage(message)
            self.finishReceivingMessage()
        }
    }
    
    override func viewClassForItem(item: QBChatMessage!) -> AnyClass! {
        if item.customParameters["kQBDateDividerCustomParameterKey"] as? Int == 1 {
            return QMChatNotificationCell.self
        }
        
        if item.senderID != self.senderID {
            return QMChatIncomingCell.self
        }else{
            return QMChatOutgoingCell.self
        }
    }
    
    override func collectionView(collectionView: QMChatCollectionView!, dynamicSizeAtIndexPath indexPath: NSIndexPath!, maxWidth: CGFloat) -> CGSize {
        var size = CGSize.zero
        
        guard let message = self.chatDataSource.messageForIndexPath(indexPath) else {
            return size
        }
        
        let messageCellClass: AnyClass! = self.viewClassForItem(message)
        
        if messageCellClass === QMChatNotificationCell.self {
            let attributedString = self.attributedStringForItem(message)
            size = TTTAttributedLabel.sizeThatFitsAttributedString(attributedString, withConstraints: CGSize(width: maxWidth, height: CGFloat.max), limitedToNumberOfLines: 0)
        } else {
            let attributedString = self.attributedStringForItem(message)
            size = TTTAttributedLabel.sizeThatFitsAttributedString(attributedString, withConstraints: CGSize(width: maxWidth, height: CGFloat.max), limitedToNumberOfLines: 0)
        }
        
        return size
    }
    
    override func collectionView(collectionView: QMChatCollectionView!, minWidthAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        let item = self.chatDataSource.messageForIndexPath(indexPath)
        let attributedString = item.senderID == self.senderID ? self.bottomLabelAttributedStringForItem(item) : self.topLabelAttributedStringForItem(item)
        let size = TTTAttributedLabel.sizeThatFitsAttributedString(attributedString, withConstraints: CGSize(width: 1000, height: 10000), limitedToNumberOfLines: 1)
        return size.width
    }
    
    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
        let item = self.chatDataSource.messageForIndexPath(indexPath)
        UIPasteboard.generalPasteboard().string = item.text
    }
    
    override func attributedStringForItem(messageItem: QBChatMessage!) -> NSAttributedString! {
        let textColor = messageItem.senderID == self.senderID ?
            UIColor.whiteColor() : UIColor.blackColor()
        let font = UIFont.systemFontOfSize(15)
        let attributes = [NSForegroundColorAttributeName:textColor, NSFontAttributeName:font]
        let attrStr = NSAttributedString(string: messageItem.text!, attributes: attributes)
        return attrStr
    }
    
    override func bottomLabelAttributedStringForItem(messageItem: QBChatMessage!) -> NSAttributedString! {
        let textColor = messageItem.senderID == self.senderID ?
            UIColor.whiteColor().colorWithAlphaComponent(0.4) : UIColor.blackColor().colorWithAlphaComponent(0.4)
        let font = UIFont.systemFontOfSize(12)
        let attributes = [NSForegroundColorAttributeName:textColor, NSFontAttributeName:font, NSBaselineOffsetAttributeName:-5]
        let attrStr = NSAttributedString(string: HappDateFormats.OnlyTime.toString(messageItem.dateSent != nil ? messageItem.dateSent! : NSDate()), attributes: attributes)
        return attrStr
    }
    
    override func topLabelAttributedStringForItem(messageItem: QBChatMessage!) -> NSAttributedString! {
        return nil
    }

}
