//
//  ContactsSceneData.swift
//  Chika
//
//  Created by Mounir Ybanez on 12/5/17.
//  Copyright © 2017 Nir. All rights reserved.
//

import Foundation

protocol ContactsSceneData: class {

    var itemCount: Int { get }
    var indexChars: [Character] { get }
    
    func removeAll()
    func append(list: [Person])
    func remove(_ personID: String)
    func item(at index: Int) -> ContactsSceneItem?
    func updateActiveStatus(for personID: String, isActive: Bool) -> Int?
    func updateRequestStatus(for personID: String, status: ContactsSceneItem.RequestStatus) -> Int?
    func index(for char: Character) -> Int?
}

extension ContactsScene {
    
    class Data: ContactsSceneData {
        
        var items: [ContactsSceneItem]
        var itemCount: Int {
            return items.count
        }
        var indexChars: [Character] {
            let set = Set(items.filter({ !$0.person.name.isEmpty }).map({ $0.person.name.uppercased() }).map({ Array($0.characters)[0] }))
            var array = Array(set)
            array.sort(by: { String($0).localizedStandardCompare(String($1)) == .orderedAscending })
            var chars = array.filter({ String($0).rangeOfCharacter(from: CharacterSet.letters.inverted) == nil && !String($0).isEmpty })
            let hasNumber = !array.filter({ String($0).rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil && !String($0).isEmpty }).isEmpty
            
            if hasNumber {
                chars.insert("#", at: 0)
            }
            
            let hasNonAlphaNumeric = !array.filter({ String($0).rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) != nil || String($0).isEmpty }).isEmpty
            
            if hasNonAlphaNumeric {
                chars.insert("/", at: 0)
            }
            
            return chars
        }
        
        init() {
            self.items = []
        }
        
        func removeAll() {
            items.removeAll()
        }
        
        func append(list: [Person]) {
            let diff = list.filter { person -> Bool in
                return !items.contains(where: { person.id == $0.person.id })
                }.map({ ContactsSceneItem(person: $0) })
            items.append(contentsOf: diff)
            items.sort(by: { $0.person.name.localizedStandardCompare($1.person.name) == .orderedAscending })
            
        }
        
        func item(at index: Int) -> ContactsSceneItem? {
            guard index >= 0, index < items.count else {
                return nil
            }
            
            return items[index]
        }
        
        func updateActiveStatus(for personID: String, isActive: Bool) -> Int? {
            guard let index = items.index(where: { $0.person.id == personID }) else {
                return nil
            }
            
            items[index].isActive = isActive
            return index
        }
        
        func remove(_ personID: String) {
            guard let index = items.index(where: { $0.person.id == personID }) else {
                return
            }
            
            items.remove(at: index)
        }
        
        func updateRequestStatus(for personID: String, status: ContactsSceneItem.RequestStatus) -> Int? {
            guard let index = items.index(where: { $0.person.id == personID }) else {
                return nil
            }
            
            items[index].requestStatus = status
            return index
        }
        
        func index(for char: Character) -> Int? {
            if String(char) == "/" {
                return items.index(where: { $0.person.name.isEmpty || String(Array($0.person.name)[0]).rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) != nil || String(Array($0.person.name)[0]).isEmpty })
                
            } else if String(char) == "#" {
                return items.index(where: { !$0.person.name.isEmpty && String(Array($0.person.name)[0]).rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil && !String(Array($0.person.name)[0]).isEmpty })
                
            } else {
                return items.index(where: { !$0.person.name.isEmpty && String(Array($0.person.name.characters)[0]).uppercased() == String(char).uppercased() })
            }
        }
    }
}
