//
//  Repository.swift
//  Budget
//
//  Created by Elisey Ozerov on 28/12/2021.
//

import Foundation

struct Query<T> {
    var sort: (T,T) -> Bool
    var filter: (T) -> Bool
    var limit: Int?
}

protocol RepositoryProtocol {
    associatedtype Item
    
    func create(_ item: Item)
    func read(query: Query<Item>) -> [Item]
    func update(_ item: Item) throws
    func delete(_ item: Item) throws
}

struct RepositoryException: Error {
    var message: String
}


class MemoryRepository<T>: RepositoryProtocol where T: Hashable, T: Identifiable {
    private var store = Set<T>()
    
    func create(_ item: T) {
        store.insert(item)
    }
    
    func read(query: Query<T>) -> [T] {
        let filtered = store.filter { query.filter($0) }
        let sorted = filtered.sorted { query.sort($0, $1) }
        var result = sorted
        
        if let limit = query.limit, limit < result.count {
            result = Array(sorted[..<limit])
        }
        
        return result
    }
    
    func update(_ item: T) throws {
        if let index = store.firstIndex(of: item) {
            store.remove(at: index)
            store.insert(item)
            return
        }
        throw RepositoryException(message: "Item \(item) was not found.")
    }
    
    func delete(_ item: T) throws {
        if let index = store.firstIndex(of: item) {
            store.remove(at: index)
        }
        throw RepositoryException(message: "Item \(item) was not found.")
    }
}
