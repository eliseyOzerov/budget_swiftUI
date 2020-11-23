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
    
    @ObservedObject var list = ObservableRealmCollection<Transaction>(sortedBy: "date", ascending: false)
    
    @State var showAddSheet = false
    @State var showAddErrorAlert = false
    
    @State var showEditSheet = false
    @State var showEditErrorAlert = false
    
    @State var showDeleteConfirmAlert = false
    @State var showDeleteErrorAlert = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                GeometryReader { geo in
                    ScrollView {
                        VStack(spacing: 0) {
                            if let transactions = list.results {
                                ForEach(transactions) { transaction in
                                    TransactionCardView(
                                        model: transaction,
                                        cardSize: geo.size,
                                        onPressed: { showEditSheet = true },
                                        onDelete: { list.delete(object: transaction, onSuccess: {}, onError: {}) }
                                    )
                                    .transition(AnyTransition.scale)
                                    .sheet(isPresented: $showEditSheet) {
                                        EditTransactionView(
                                            transaction: transaction,
                                            onDone: {
                                                list.add(object: $0, onSuccess: {}, onError: { showEditErrorAlert = true})
                                            },
                                            onCancel: { showEditSheet = false }
                                        )
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(InsetListStyle())
                    .navigationTitle("Transactions")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {}, label: {
                                Image(systemName: "line.horizontal.3.decrease")
                                    .frame(width: 24, height: 24)
                            })
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: { showAddSheet = true }, label: {
                                Image(systemName: "plus")
                                    .frame(width: 24, height: 24)
                            })
                            .sheet(isPresented: self.$showAddSheet) {
                                AddTransactionView(
                                    onDone: {
                                        list.add(object: $0, onSuccess: {}, onError: { showAddErrorAlert = true})
                                    },
                                    onCancel: { showAddSheet = false }
                                )
                            }
                        }
                    }
                    .animation(.spring(), value: list.results)
                }
            }
        }
    }
}

struct TransactionListView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionListView()
    }
}
