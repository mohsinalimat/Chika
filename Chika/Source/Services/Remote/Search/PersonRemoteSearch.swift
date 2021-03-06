//
//  PersonRemoteSearch.swift
//  Chika
//
//  Created by Mounir Ybanez on 12/12/17.
//  Copyright © 2017 Nir. All rights reserved.
//

import FirebaseDatabase
import FirebaseAuth

protocol PersonRemoteSearch: class {

    func search(withKeyword: String, callback: @escaping ([PersonSearchObject]) -> Void)
}

class PersonRemoteSearchProvider: PersonRemoteSearch {
    
    var database: Database
    var meID: String
    var emailValidator: EmailValidator
    var personsQuery: PersonsRemoteQuery
    var chatsQuery: ChatsRemoteQuery
    
    init(meID: String = Auth.auth().currentUser?.uid ?? "", database: Database = Database.database(), emailValidator: EmailValidator = EmailValidatorProvider(), personsQuery: PersonsRemoteQuery = PersonsRemoteQueryProvider(), chatsQuery: ChatsRemoteQuery = ChatsRemoteQueryProvider()) {
        self.database = database
        self.meID = meID
        self.emailValidator = emailValidator
        self.personsQuery = personsQuery
        self.chatsQuery = chatsQuery
    }
    
    func search(withKeyword keyword: String, callback: @escaping ([PersonSearchObject]) -> Void) {
        let meID = self.meID
        
        guard !meID.isEmpty, !keyword.isEmpty else {
            callback([])
            return
        }
        
        var path = "name"
        var searchText = keyword.lowercased()
        if emailValidator.isValid(keyword) {
            let words = searchText.split(separator: "@")
            if !words.isEmpty {
                searchText = String(words[0])
                path = "email"
            }
        }
        
        let rootRef = database.reference()
        let ref = rootRef.child("persons:search")
        let query = ref.queryOrdered(byChild: path).queryStarting(atValue: searchText).queryEnding(atValue: searchText+"\u{f8ff}")
        
        query.observeSingleEvent(of: .value) { [weak self] snapshot in
            if snapshot.exists(), snapshot.hasChildren() {
                if path == "email" {
                    self?.handleSearchResult(snapshot, callback)
                    
                } else {
                    self?.handleSearchResult(snapshot) { objects1 in
                        let query = ref.queryOrdered(byChild: "display:name").queryStarting(atValue: searchText).queryEnding(atValue: searchText+"\u{f8ff}")
                        
                        query.observeSingleEvent(of: .value) { snapshot in
                            self?.handleSearchResult(snapshot) { objects2 in
                                var objects = objects1
                                objects.append(contentsOf: objects2)
                                objects = Array(Set(objects))
                                callback(objects)
                            }
                        }
                    }
                }
            
            } else if path == "name" {
                let query = ref.queryOrdered(byChild: "display:name").queryStarting(atValue: searchText).queryEnding(atValue: searchText+"\u{f8ff}")
                
                query.observeSingleEvent(of: .value) { snapshot in
                    guard snapshot.exists(), snapshot.hasChildren() else {
                        callback([])
                        return
                    }
                    
                    self?.handleSearchResult(snapshot, callback)
                }
                
            } else {
                callback([])
            }
        }
    }
    
    private func handleSearchResult(_ snapshot: DataSnapshot, _ callback: @escaping ([PersonSearchObject]) -> Void) {
        let meID = self.meID
        let chatsQuery = self.chatsQuery
        let personsQuery = self.personsQuery
        let rootRef = database.reference()
        
        var contactInfo = [String: Bool]()
        var requestedInfo = [String: Bool]()
        var pendingInfo = [String: Bool]()
        var chatInfo = [String: Chat]()
        var personKeys = [String]()
        var personKeyCounter: UInt = 0 {
            didSet {
                guard personKeyCounter == snapshot.childrenCount else {
                    return
                }
                
                guard !personKeys.isEmpty else {
                    callback([])
                    return
                }
                
                personsQuery.getPersons(for: personKeys) { persons in
                    let persons = Array(Set(persons)).filter({
                        guard let isContact = contactInfo[$0.id],
                            requestedInfo[$0.id] != nil,
                            pendingInfo[$0.id] != nil else {
                                return false
                        }
                        
                        if (isContact && chatInfo[$0.id] == nil) ||
                            (!isContact && chatInfo[$0.id] != nil){
                            return false
                        }
                        
                        return true
                    })
                    
                    guard !persons.isEmpty else {
                        callback([])
                        return
                    }
                    
                    let objects: [PersonSearchObject] = persons.map({ person -> PersonSearchObject in
                        var object = PersonSearchObject()
                        object.person = person
                        object.isContact = contactInfo[person.id] ?? false
                        object.isRequested = requestedInfo[person.id] ?? false
                        object.isPending = pendingInfo[person.id] ?? false
                        if let chat = chatInfo[person.id] {
                            object.chat = chat
                        }
                        return object
                    })
                    
                    callback(objects)
                }
            }
        }
        
        for child in snapshot.children {
            guard let child = child as? DataSnapshot, !child.key.isEmpty, child.key != meID else {
                personKeyCounter += 1
                continue
            }
            
            let personID = child.key
            let ref = rootRef.child("person:contacts/\(meID)/\(personID)")
            
            ref.observeSingleEvent(of: .value)  { snapshot in
                let isContact = snapshot.exists()
                let chatID = snapshot.childSnapshot(forPath: "chat").value as? String ?? ""
                let establishedRef = rootRef.child("person:contact:request:established/\(meID)/\(personID)")
                
                establishedRef.observeSingleEvent(of: .value) { snapshot in
                    var isRequested = false
                    var isPending = false
                    
                    if snapshot.exists() {
                        isPending = snapshot.hasChild("requestee") && snapshot.childSnapshot(forPath: "requestee").value as? String == meID
                        isRequested = snapshot.hasChild("requestor") && snapshot.childSnapshot(forPath: "requestor").value as? String == meID
                    }
                    
                    chatsQuery.getChats(for: [chatID]) { chats in
                        if isContact, chats.count == 1, chats[0].id == chatID {
                            chatInfo[personID] = chats[0]
                        }
                        contactInfo[personID] = isContact
                        requestedInfo[personID] = isRequested
                        pendingInfo[personID] = isPending
                        personKeys.append(personID)
                        personKeyCounter += 1
                    }
                }
            }
        }
    }
}
