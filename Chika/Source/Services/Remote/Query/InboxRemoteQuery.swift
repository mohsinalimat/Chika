//
//  InboxRemoteQuery.swift
//  Chika
//
//  Created by Mounir Ybanez on 11/21/17.
//  Copyright © 2017 Nir. All rights reserved.
//

import FirebaseDatabase

protocol InboxRemoteQuery: class {
    
    func getInbox(for personID: String, completion: @escaping ([Chat]) -> Void)
}

class InboxRemoteQueryProvider: InboxRemoteQuery {

    var chatsQuery: ChatsRemoteQuery
    var path: String
    var database: Database
    
    init(database: Database = Database.database(), path: String = "person:inbox", chatsQuery: ChatsRemoteQuery = ChatsRemoteQueryProvider()) {
        self.database = database
        self.path = path
        self.chatsQuery = chatsQuery
    }
    
    func getInbox(for personID: String, completion: @escaping ([Chat]) -> Void) {
        let rootRef = database.reference()
        let ref = rootRef.child("\(path)/\(personID)")
        let chatsQuery = self.chatsQuery
        
        ref.queryOrdered(byChild: "updated_on").observe(.value) { snapshot in
            guard snapshot.exists(), let info = snapshot.value as? [String : Any] else {
                completion([])
                return
            }
            
            let chatKeys: [String] = info.flatMap({ $0.key })
            
            chatsQuery.getChats(for: chatKeys) { chats in
                guard chatKeys.count == chats.count,
                    chatKeys == chats.map({ $0.id }) else {
                        completion([])
                        return
                }
                
                completion(chats)
            }
        }
    }
}