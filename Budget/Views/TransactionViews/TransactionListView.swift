//
//  TransactionListView.swift
//  Budget
//
//  Created by Elisey Ozerov on 15/11/2020.
//  Copyright © 2020 Elisey Ozerov. All rights reserved.
//

import SwiftUI
import RealmSwift

struct TransactionListView: View {
    
    @State var isEditSheetShown = false
    
    @ObservedObject var list = ObservableRealmCollection<Transaction>(sortedBy: "date", ascending: false)
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                HStack {
                    NavBarActions()
                        .opacity(0)
                    Spacer()
                    Text("Transactions")
                        .font(.system(size: 20, weight: .bold))
                    Spacer()
                    NavBarActions()
                }
                .padding()
                
                ScrollView {
                    VStack(spacing: 0) {
                        if let transactions = list.array {
                            ForEach(transactions) { transaction in
                                TransactionCardView(model: transaction)
                            }
                        } else {
                            EmptyView()
                        }
                    }
                    .padding(.vertical, 8)
                }
                Spacer()
            }
            .navigationBarHidden(true)
        }
    }
}

struct NavBarActions: View {
    @State private var showAddSheet = false
    @State private var transactionType = TransactionType.income
    
    var body: some View {
        HStack {
            Button(action: {}, label: {
                Image(systemName: "line.horizontal.3.decrease")
                    .frame(width: 24, height: 24)
            })
            Button(action: {showAddSheet.toggle()}, label: {
                Image(systemName: "plus")
                    .frame(width: 24, height: 24)
            })
            .sheet(isPresented: self.$showAddSheet) {
                AddTransactionView(isShown: $showAddSheet)
            }
        }
    }
}

struct TransactionListView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionListView()
    }
}

/// Added mapped to Array to improve debugging experience
class ObservableRealmCollection<T>: ObservableObject where T: Object, T: Identifiable {
    @Published var array: Array<T>?
    @Published var results: Results<T>?
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
            token = results?.observe { changes in
                switch changes {
                case .initial(let results):
                    self.array = results.map { $0 }
                case .error(let error):
                    debugPrint(error)
                case .update(let results, _, _, _):
                    self.array = results.freeze().map { $0 }
                }
            }
        } catch {
            debugPrint(error)
        }
    }
}
