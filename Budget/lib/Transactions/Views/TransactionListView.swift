//
//  TransactionListView.swift
//  Budget
//
//  Created by Elisey Ozerov on 15/11/2020.
//  Copyright © 2020 Elisey Ozerov. All rights reserved.
//

import SwiftUI
import RealmSwift

enum TransactionListAlert {
    case addError (value: String = "add")
    case editError (value: String = "edit")
    case deleteError (value: String = "delete")
    case deleteConfirm (Transaction)
}

struct TransactionListView: View {
    
    @ObservedObject var list = ObservableRealmCollection<Transaction>(sortedBy: "date", ascending: false)
    
    @State var showAddSheet = false
    @State var showEditSheet = false
    
    @State var showAlert = false
    @State var alert: TransactionListAlert?
    
//    var transactions = [
//        Transaction(),
//        Transaction(),
//        Transaction()
//    ]
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                HStack {
                    Color.white.frame(width: 48, height: 0)
                        .opacity(0)
                    Spacer()
                    Text("Transactions")
                        .font(.system(size: 20, weight: .bold))
                    Spacer()
                    HStack {
                        Button(action: {}, label: {
                            Image(systemName: "line.horizontal.3.decrease")
                                .frame(width: 24, height: 24)
                        })
                        Button(action: { showAddSheet = true }, label: {
                            Image(systemName: "plus")
                                .frame(width: 24, height: 24)
                        })
                        .sheet(isPresented: $showAddSheet) {
                            AddTransactionView(
                                onDone: {
                                    list.add(object: $0, onSuccess: {showAddSheet = false}, onError: {
                                        alert = .addError()
                                        showAlert = true
                                    })
                                },
                                onCancel: { showAddSheet = false }
                            )
                        }
                    }
                }
                .padding()
                
                GeometryReader { geo in
                    ScrollView {
                        VStack(spacing: 0) {
                            if let transactions = list.results {
                                ForEach(transactions) { transaction in
                                    TransactionCardView(
                                        model: transaction,
                                        cardSize: geo.size,
                                        onPressed: { showEditSheet = true },
                                        onDelete: {
                                            alert = .deleteConfirm (transaction)
                                            showAlert = true
                                        }
                                    )
                                    .transition(AnyTransition.scale)
                                    .sheet(isPresented: $showEditSheet) {
                                        EditTransactionView(
                                            transaction: transaction,
                                            onDone: {
                                                list.add(object: $0, onSuccess: { showEditSheet = false }, onError: {
                                                    alert = .editError()
                                                    showAlert = true
                                                })
                                            },
                                            onCancel: { showEditSheet = false }
                                        )
                                    }
                                }
                            }
                        }
                    }
                    .animation(.spring(), value: list.results)
                }
            }
            .navigationBarHidden(true)
            .alert(isPresented: $showAlert) {
                switch alert {
                case .addError(let value), .editError(let value), .deleteError(let value):
                    return Alert(
                        title: Text("Error"),
                        message: Text("We were unable to \(value) this transaction. Please try again."),
                        dismissButton: .default(Text("Ok"))
                    )
                case .deleteConfirm (let transaction):
                    return Alert(
                        title: Text("Are you sure?"),
                        message: Text("This action is irreversible."),
                        primaryButton: .destructive(Text("Delete")) {
                            list.delete(object: transaction, onSuccess: {}, onError: {})
                        },
                        secondaryButton: .cancel())
                case .none:
                    return Alert(title: Text("Dummy"))
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
