//
//  ObservableRealmCollection.swift
//  Budget
//
//  Created by Elisey Ozerov on 23/11/2020.
//  Copyright © 2020 Elisey Ozerov. All rights reserved.
//

import Foundation
import RealmSwift

class ObservableRealmCollection<T>: ObservableObject where T: Object, T: Identifiable {
    // Frozen results to display
    @Published var results: Results<T>?
    // Live results to delete from (otherwise throws error)
    private var __results: Results<T>?
    private var token: NotificationToken?
    
    init(sortedBy keyPath: String, ascending: Bool) {
        fetch(keypath: keyPath, ascending: ascending)
    }
    
    deinit {
        token?.invalidate()
    }
    
    func fetch(keypath: String, ascending: Bool) {
        do {
            let realm = try Realm()
            print("Realm is located at: \(realm.configuration.fileURL!)")
            __results = realm.objects(T.self).sorted(byKeyPath: keypath, ascending: ascending)
            results = __results
            token = self.__results?.observe { changes in
                switch changes {
                case .initial(let results):
                    debugPrint(results.count)
                case .error(let error):
                    self.__results = nil
                    self.results = nil
                    self.token = nil
                    debugPrint(error)
                case .update(_, _,_,_):
//                    self.results = self.__results?.freeze()
                    self.objectWillChange.send()
                    print(".update \(String(describing: self.__results?.count))")
                }
            }
        } catch {
            self.__results = nil
            self.results = nil
            self.token = nil
            debugPrint(error)
        }
    }
    
    func add(_ object: T, onSuccess: () -> Void = {}, onError: () -> Void = {}) {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(object, update: .modified)
            }
            onSuccess()
        } catch {
            debugPrint(error)
            onError()
        }
    }
    
    func delete(at indices: IndexSet, onSuccess: () -> Void = {}, onError: () -> Void = {}) {
        do {
            let realm = try Realm()
            try realm.write {
                guard let objs = __results?.enumerated().filter({indices.contains($0.offset)}).map({$0.element}) else { return }
                realm.delete(objs)
            }
            onSuccess()
        } catch {
            debugPrint(error)
            onError()
        }
    }
}
