//
//  TransactionListView.swift
//  Budget
//
//  Created by Elisey Ozerov on 15/11/2020.
//  Copyright © 2020 Elisey Ozerov. All rights reserved.
//

import SwiftUI
import RealmSwift

enum SheetView: Hashable, Identifiable {
    case add
    case edit(Transaction)
    case filter
    
    var id: Self { self }
}

struct TransactionSection: Identifiable {
    var id = UUID()
    var transactions: [Transaction] = []
    var total: Double {
        transactions.reduce(into: 0){ result, tx in
            result += tx.type == .income ? tx.total : -tx.total
        }
    }
}

class TransactionListViewModel: ObservableObject {
    @Published var sections: [TransactionSection] = []
    
    private var results: Results<TransactionDB>?
    private var token: NotificationToken?
    
    init() {
        results = try! Realm().objects(TransactionDB.self).sorted(byKeyPath: "date", ascending: false)
        token = results?.observe { [self] changes in
            switch changes {
            case .initial:
                sections = groupTransactions()
            case .error(let error):
                debugPrint(error)
            case .update(_,let deletions,let insertions,let modifications):
                for id in deletions {
                    removeTxOnUpdate(at: id)
                }
                for id in insertions {
                    addTxOnUpdate(at: id)
                }
                for id in modifications {
                    modifyTxOnUpdate(at: id)
                }
            }
        }
    }
    
    func groupTransactions() -> [TransactionSection] {
        guard let trx = results?.map({Transaction(from: $0)}) else {return [TransactionSection]()}
        return trx.reduce([TransactionSection]()) { result, transaction in
            var new = result

            guard var lastSection = result.last else {
                return [TransactionSection(transactions: [transaction])]
            }

            guard let lastTransaction = lastSection.transactions.last else {
                return [TransactionSection(transactions: [transaction])]
            }

            let lastDate = lastTransaction.date.startOfDay()
            let transactionDate = transaction.date.startOfDay()

            if lastDate.equal(transactionDate) {
                lastSection.transactions.append(transaction)
                new[new.count - 1] = lastSection
            } else {
                new.append(TransactionSection(transactions: [transaction]))
            }

            return new
        }
    }
    
    func addTxOnUpdate(at index: Int) {
        var txCount = 0
        for sectionId in 0 ..< sections.count {
            let localTxCount = sections[sectionId].transactions.count
            txCount += localTxCount
            let lastTxId = txCount - 1
            if lastTxId >= index {
                let offsetFromEnd = lastTxId - index
                let lastTxLocalId = localTxCount - 1
                let txSectionOffset = lastTxLocalId - offsetFromEnd
                // in case this section is the correct section id-wise, but not date-wise,
                // we need to insert another section
                if sections[sectionId].transactions.first!.date.startOfDay() != results![index].date.startOfDay() {
                    sections.insert(TransactionSection(transactions: [Transaction(from: results![index])]), at: sectionId)
                    return
                }
                sections[sectionId].transactions.insert(Transaction(from: results![index]), at: txSectionOffset)
                return
            }
        }
        // if function didn't return, there was no satisfactory section, therefore append new one
        sections.append(TransactionSection(transactions: [Transaction(from: results![index])]))
    }
    
    func modifyTxOnUpdate(at index: Int) {
        var txCount = 0
        for sectionId in 0 ..< sections.count {
            let section = sections[sectionId]
            let localTxCount = section.transactions.count
            txCount += localTxCount
            let lastTxId = txCount - 1
            if lastTxId >= index {
                let offsetFromEnd = lastTxId - index
                let lastTxLocalId = localTxCount - 1
                let txSectionOffset = lastTxLocalId - offsetFromEnd
                sections[sectionId].transactions[txSectionOffset] = Transaction(from: results![index])
                return
            }
        }
    }
    
    func removeTxOnUpdate(at index: Int) {
        var txCount = 0
        var sectionIdsToDelete = [Int]()
        for sectionId in 0 ..< sections.count {
            let section = sections[sectionId]
            let localTxCount = section.transactions.count
            txCount += localTxCount
            let lastTxId = txCount - 1
            if lastTxId >= index {
                let offsetFromEnd = lastTxId - index
                let lastTxLocalId = localTxCount - 1
                let txSectionOffset = lastTxLocalId - offsetFromEnd
                if sections[sectionId].transactions.count == 1 {
                    sectionIdsToDelete.append(sectionId)
                    break
                }
                sections[sectionId].transactions.remove(at: txSectionOffset)
                return
            }
        }
        for sectionId in sectionIdsToDelete {
            sections.remove(at: sectionId)
        }
    }
    
    func addModifyTx(_ tx: Transaction) {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(TransactionDB(from: tx), update: .modified)
            }
        } catch {
            debugPrint(error)
        }
    }
    
    func deleteTx(_ tx: Transaction) {
        do {
            let realm = try Realm()
            try realm.write {
                let obj = results?.filter({$0.id == tx.id})
                realm.delete(obj!)
            }
        } catch {
            debugPrint(error)
        }
    }
}

struct TransactionListView: View {
    
    @Environment(\.presentationMode) var presentation
    
    @ObservedObject var model = TransactionListViewModel()
    @ObservedObject var filter = TransactionFilter()
    
    @State var sheetView: SheetView?
    
    func getSheetView(_ sheetView: SheetView) -> AnyView {
        switch sheetView {
        case .add:
            return AnyView(
                TransactionView(
                    onDone: { tx in
                        model.addModifyTx(tx)
                        self.sheetView = nil
                    },
                    onCancel: { self.sheetView = nil }
                )
            )
        case .edit(let transaction):
            return AnyView(
                TransactionView(
                    transaction: transaction,
                    onDone: { tx in
                        model.addModifyTx(tx)
                        self.sheetView = nil
                    },
                    onCancel: { self.sheetView = nil }
                )
            )
        case .filter:
            return AnyView(
                TransactionFilterView(sheetView: $sheetView)
                    .environmentObject(filter)
            )
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(model.sections) { section in
                    Section(header: HStack {
                        Text(section.transactions.first?.date.format() ?? "")
                        Spacer()
                        Text(section.total.toCurrencyString())
                    }) {
                        ForEach(section.transactions) { transaction in
                            Button(action: {sheetView = .edit(transaction)}, label: {
                                TransactionCardView(transaction: transaction)
                            }).buttonStyle(PlainButtonStyle())
                        }
                        .onDelete { set in
                            // async because otherwise section is deleted immediately and the animation
                            // for the row deletion jumps to the top of the list
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                model.deleteTx(section.transactions[set.first!])
                            }
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Transactions")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading){
                    Button(action: {
                            sheetView = .add
                    }) {
                        HStack(spacing: 5) {
                            Text("Add")
                            Image(systemName: "plus")
                        }.contentShape(Rectangle())
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                            sheetView = .filter
                    }) {
                        HStack(spacing: 5) {
                            Text("Filter")
                            Image(systemName: "line.horizontal.3.decrease.circle")
                        }.contentShape(Rectangle())
                    }
                }
            }
            .sheet(item: $sheetView){
                getSheetView($0)
            }
        }
    }
}

struct TransactionListView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionListView()
    }
}
