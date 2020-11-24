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
            results = realm.objects(T.self).sorted(byKeyPath: keypath, ascending: ascending)
            self.__results = results
            self.results = results?.freeze()
            token = self.__results?.observe { changes in
                switch changes {
                case .initial(let results):
                    debugPrint(results.count)
                case .error(let error):
                    self.__results = nil
                    self.results = nil
                    self.token = nil
                    debugPrint(error)
                case .update(let results, _, _, _):
                    self.results = results.freeze()
                }
            }
        } catch {
            self.__results = nil
            self.results = nil
            self.token = nil
            debugPrint(error)
        }
    }
    
    func add(object: T, onSuccess: () -> Void, onError: () -> Void) {
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
    
    func delete(object: T, onSuccess: () -> Void, onError: () -> Void) {
        do {
            let realm = try Realm()
            try realm.write {
                guard let obj = __results?.first(where: { $0.id == object.id }) else { return }
                realm.delete(obj)
            }
            onSuccess()
        } catch {
            debugPrint(error)
            onError()
        }
    }
}
