//
//  ConvoSceneWorker.swift
//  Chika
//
//  Created by Mounir Ybanez on 11/23/17.
//  Copyright © 2017 Nir. All rights reserved.
//

protocol ConvoSceneWorker: class {

    func fetchNewMessages() -> Bool
    func fetchNextMessages() -> Bool
    func sendMessage(_ content: String) -> Bool
    func listenForUpdates()
    func changeTypingStatus(isTyping: Bool, forced: Bool)
}

protocol ConvoSceneWorkerOutput: class {
    
    func workerDidFetchNew(messages: [Message])
    func workerDidFetchNext(messages: [Message])
    func workerDidFetchWithError(_ error: Error)
    func workerDidSend(message: Message)
    func workerDidSendWithError(_ error: Error)
    func workerDidUpdateConvo(message: Message)
    func workerDidUpdateTypingStatus(for person: Person, isTyping: Bool)
}

extension ConvoScene {
    
    class Worker: ConvoSceneWorker {
        
        struct Listener {
            
            var chatMessage: ChatMessageRemoteListener
            var typingStatus: TypingStatusRemoteListener
        }
        
        enum Fetch {
            
            case new, next
        }
        
        weak var output: ConvoSceneWorkerOutput?
        var service: ChatRemoteService
        var writer: TypingStatusRemoteWriter
        var listener: Listener
        var chatID: String
        var participantIDs: [String]
        var offset: Double?
        var limit: UInt
        var isFetching: Bool
        var isListening: Bool
        var isChangingTypingStatus: Bool
        var isTyping: Bool
        
        init(chatID: String, participantIDs: [String], service: ChatRemoteService, listener: Listener, writer: TypingStatusRemoteWriter, limit: UInt) {
            self.chatID = chatID
            self.participantIDs = participantIDs
            self.service = service
            self.listener = listener
            self.writer = writer
            self.offset = 0
            self.limit = limit
            self.isFetching = false
            self.isListening = false
            self.isTyping = false
            self.isChangingTypingStatus = false
        }
        
        convenience init(chatID: String, participantIDs: [String]) {
            let service = ChatRemoteServiceProvider()
            let chatMessage = ChatMessageRemoteListenerProvider(chatID: chatID)
            let typingStatus = TypingStatusRemoteListenerProvider(chatID: chatID)
            let listener = Listener(chatMessage: chatMessage, typingStatus: typingStatus)
            let writer = TypingStatusRemoteWriterProvider()
            let limit: UInt = 50
            self.init(chatID: chatID, participantIDs: participantIDs, service: service, listener: listener, writer: writer, limit: limit)
        }
        
        func changeTypingStatus(isTyping typing: Bool, forced: Bool) {
            guard (!isChangingTypingStatus && isTyping != typing) || forced else {
                return
            }
            
            isChangingTypingStatus = true
            writer.changeTypingStatus(typing, for: chatID) { [weak self] result in
                switch result {
                case .ok:
                    self?.isTyping = typing
                
                default:
                    break
                }
                
                self?.isChangingTypingStatus = false
            }
        }
        
        func listenForUpdates() {
            guard !isListening, !chatID.isEmpty else {
                return
            }
            
            isListening = true
            
            listener.chatMessage.listen { [weak self] message in
                self?.output?.workerDidUpdateConvo(message: message)
            }
            
            listener.typingStatus.listen { [weak self] person, isTyping in
                self?.output?.workerDidUpdateTypingStatus(for: person, isTyping: isTyping)
            }
        }
        
        func sendMessage(_ content: String) -> Bool {
            guard !content.isEmpty else {
                return false
            }
            
            service.writeMessage(for: chatID, participantIDs: participantIDs, content: content) { [weak self] result in
                switch result {
                case .err(let info):
                    self?.output?.workerDidSendWithError(info)
                
                case .ok(let message):
                    self?.output?.workerDidSend(message: message)
                }
            }
            
            return true
        }
        
        func fetchNewMessages() -> Bool {
            return fetchMessages(.new)
        }
        
        func fetchNextMessages() -> Bool {
            return fetchMessages(.next)
        }
        
        private func fetchMessages(_ fetch: Fetch) -> Bool {
            guard !isFetching else {
                return false
            }
            
            switch fetch {
            case .new:
                offset = 0
            
            case .next:
                if offset == nil {
                    return false
                }
            }
            
            isFetching = true
            service.getMessages(for: chatID, offset: offset!, limit: limit) { [weak self] result in
                switch result {
                case .err(let info):
                    self?.output?.workerDidFetchWithError(info)
                    self?.isFetching = false
                    
                case .ok(let (messages, nextOffset)):
                    let currentOffset = self?.offset
                    self?.offset = nextOffset
                    
                    guard currentOffset != nil, currentOffset! > 0 else {
                        self?.output?.workerDidFetchNew(messages: messages)
                        self?.isFetching = false
                        return
                    }
                    
                    self?.output?.workerDidFetchNext(messages: messages)
                    self?.isFetching = false
                }
            }
            
            return true
        }
    }
}
