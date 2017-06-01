//
//  ChatViewModel.swift
//  Happ
//
//  Created by Aleksei Pugachev on 2/19/17.
//  Copyright © 2017 Sattar Stamkulov. All rights reserved.
//

import Foundation
import PromiseKit
import RealmSwift
import Quickblox

struct ChatState: DataStateProtocol {
    var page: Int
    var items: [Object]
    var isFetching: Bool
    
    static func getInitialState() -> ChatState {
        return ChatState(page: 0, items: [], isFetching: false)
    }
}

class ChatViewModel {
    var state: ChatState
    var navigateBack: NavigationFunc
    
    var chat: QBChatDialog?
    var opponent: AuthorModel?
    
    var manager = false
    var chatDidLoad: (Void -> Void)?
    
    init() {
        self.state = ChatState.getInitialState()
    }
    
    convenience init(forObject: Object, manager: Bool = false) {
        self.init()
        self.manager = manager
        if let opponent = forObject as? AuthorModel {
            self.opponent = opponent
            if manager {
                ChatService.getChatByAuthorId(orParticipatorId: opponent.id, opponentID: opponent.qbID).then { dialog -> Void in
                    self.chat = dialog
                    self.chatDidLoad?()
                }
            }else{
                ChatService.getChatByAuthorId(opponent.id, opponentID: opponent.qbID, opponentName: opponent.fn).then { dialog -> Void in
                    self.chat = dialog
                    self.chatDidLoad?()
                }
            }
        }
    }
    
    func getData(overwrite: Bool = false) -> Promise<[QBChatMessage]?> {
        if overwrite { ChatService.isChatLastPage = false }
        if !self.state.isFetching && !ChatService.isChatLastPage {
            self.state.isFetching = true
            self.state.page += 1
            return ChatService.getChat(chat?.ID, page: self.state.page).then { messages -> Promise<[QBChatMessage]?> in
                self.state.isFetching = false
                return Promise<[QBChatMessage]?>(messages)
            }
        }
        return Promise<[QBChatMessage]?>(nil)
    }
}
