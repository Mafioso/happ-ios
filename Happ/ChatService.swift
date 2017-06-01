//
//  ChatService.swift
//  Happ
//
//  Created by Aleksei Pugachev on 2/18/17.
//  Copyright © 2017 Sattar Stamkulov. All rights reserved.
//

import Foundation
import PromiseKit
import RealmSwift
import Quickblox
import ObjectMapper
import UserNotifications

class ChatService {
    
    static let chats_limit = 25
    static let messages_limit = 1000
    
    static var isLastPage: Bool = false
    static var isChatLastPage: Bool = false
    
    class func startChat() -> Promise<Void> {
        return Promise { resolve, reject in
            QBRequest.logInWithUserLogin(ProfileService.getUserProfile().qbLogin, password: ProfileService.getUserProfile().qbPassword, successBlock: { result, user in
                if user != nil {
                    user!.password = ProfileService.getUserProfile().qbPassword
                    quickBloxUser = user!
                    QBChat.instance().connectWithUser(quickBloxUser) { (error: NSError?) -> Void in
                        if error == nil {
                            if QBChat.instance().isConnected {
                                self.registerForPushNotifications()
                                resolve()
                            }else{
                                reject(RequestError.UnknownError)
                            }
                        }else{
                            if error?.code == -1000 {
                                QBChat.instance().disconnectWithCompletionBlock { _ in
                                    QBRequest.destroySessionWithSuccessBlock({ _ in }, errorBlock: { _ in })
                                }
                            }
                            reject(error!)
                        }
                    }
                }else{
                    reject(RequestError.UnknownError)
                }
            }, errorBlock: { error in
                reject(RequestError.UnknownError)
            })
        }
    }

    class func fetchChats(page: Int = 1, overwrite: Bool = false, manager: Bool = false) -> Promise<Void> {
        return Promise { resolve, reject in
            let page = QBResponsePage(limit: chats_limit, skip: chats_limit * (page - 1))
            
            QBRequest.dialogsForPage(page, extendedRequest: ["sort_desc" : "last_message_date_sent", "data[class_name]" : "HappChat", "data[\(manager ? "author" : "participator")]" : ProfileService.getUserProfile().id], successBlock: { (response: QBResponse, dialogs: [QBChatDialog]?, dialogsUsersIDs: Set<NSNumber>?, page: QBResponsePage?) -> Void in
                
                self.isLastPage = dialogs?.count < chats_limit
                
                let realm = try! Realm()
                try! realm.write {
                    if overwrite {
                        let exists = realm.objects(ChatModel)
                        realm.delete(exists)
                    }
                    dialogs?.forEach() { chat in
                        if let inst = ChatModel(chat, manager: manager) {
                            realm.add(inst, update: true)
                        }
                    }
                }
                
                resolve()
                
            }) { (response: QBResponse) -> Void in
                reject(RequestError.UnknownError)
            }
        }
    }
    
    class func getChat(id: String?, page: Int = 1) -> Promise<[QBChatMessage]?> {
        return Promise { resolve, reject in
            let page = QBResponsePage(limit: messages_limit, skip: messages_limit * (page - 1))
            
            if id == nil {
                reject(RequestError.UnknownError)
                return
            }
            
            QBRequest.messagesWithDialogID(id!, extendedRequest: ["sort_desc" : "date_sent"], forPage: page, successBlock: {(response: QBResponse, messages: [QBChatMessage]?, responcePage: QBResponsePage?) in
                
                self.isChatLastPage = messages?.count < messages_limit
                resolve(messages)
                
            }, errorBlock: {(response: QBResponse!) in
                reject(RequestError.UnknownError)
            })
        }
    }
    
    class func sendMessage(message: QBChatMessage) -> Promise<Void> {
        return Promise { resolve, reject in
            QBRequest.createMessage(message, successBlock: {(response: QBResponse!, createdMessage: QBChatMessage!) in
                resolve()
            }, errorBlock: {(response: QBResponse!) in
                reject(RequestError.UnknownError)
            })
        }
    }
    
    class func getChatByAuthorId(id: String = ProfileService.getUserProfile().id, orParticipatorId: String = ProfileService.getUserProfile().id, opponentID: Int, opponentName: String? = nil) -> Promise<QBChatDialog?> {
        return Promise { resolve, reject in
            let page = QBResponsePage(limit: 1, skip: 0)
            
            QBRequest.dialogsForPage(page, extendedRequest: ["data[class_name]": "HappChat", "data[author]" : id, "data[participator]" : orParticipatorId], successBlock: { (response: QBResponse, dialogs: [QBChatDialog]?, dialogsUsersIDs: Set<NSNumber>?, page: QBResponsePage?) -> Void in
                
                if dialogs?.count > 0 {
                    resolve(dialogs?.first)
                    return
                }
                
                let dialog = QBChatDialog(dialogID: nil, type: .Private)
                dialog.occupantIDs = [opponentID]
                dialog.data = ["class_name": "HappChat", "author": id, "participator": orParticipatorId, "participator_name": ProfileService.getUserProfile().fullname == "" ? ProfileService.getUserProfile().username : ProfileService.getUserProfile().fullname, "author_name": opponentName!]
                
                QBRequest.createDialog(dialog, successBlock: { response, dialog in
                    resolve(dialog)
                }, errorBlock: { error in
                    reject(RequestError.UnknownError)
                })
                
            }) { (response: QBResponse) -> Void in
                reject(RequestError.UnknownError)
            }
        }
    }
    
    class func getChats() -> Results<ChatModel> {
        let realm = try! Realm()
        let result = realm.objects(ChatModel)
        return result
    }
    
    class func registerForPushNotifications() {
        if #available(iOS 10.0, *){
            UNUserNotificationCenter.currentNotificationCenter().requestAuthorizationWithOptions([.Badge, .Sound, .Alert], completionHandler: {(granted, error) in
                if granted {
                    UIApplication.sharedApplication().registerForRemoteNotifications()
                }
            })
        }else{
            let notificationSettings = UIUserNotificationSettings(
                forTypes: [.Badge, .Sound, .Alert], categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
        }
    }
    
}
