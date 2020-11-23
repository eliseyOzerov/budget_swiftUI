//
//  EditTransactionView.swift
//  Budget
//
//  Created by Elisey Ozerov on 18/11/2020.
//  Copyright © 2020 Elisey Ozerov. All rights reserved.
//

import SwiftUI
import RealmSwift

struct EditTransactionView: View {
    
    @State private var type: TransactionType
    @State private var sumString: String
    @State private var category: String
    @State private var date: Date
    @State private var secondParty: String
    
    private var id: ObjectId
    
    init(transaction: Transaction, onDone: @escaping (Transaction) -> Void, onCancel: @escaping () -> Void) {
        id = transaction.id
        _type = State(initialValue: transaction.type)
        _sumString = State(initialValue: "\(transaction.total)")
        _category = State(initialValue: transaction.category)
        _secondParty = State(initialValue: transaction.secondParty)
        _date = State(initialValue: transaction.date)
        
        self.onDone = onDone
        self.onCancel = onCancel
    }
    
    var sum: Double { Double(sumString.replacingOccurrences(of: ",", with: ".")) ?? 0.00 }
    
    var onDone: (Transaction) -> Void
    var onCancel: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 25) {
            SheetTitleBar(
                title: "Edit transaction",
                doneText: "Done",
                onDone: {
                    onDone(
                        Transaction(
                            id: id,
                            date: date,
                            total: sum,
                            type: type,
                            category: category,
                            secondParty: secondParty
                        )
                    )
                },
                onCancel: onCancel
            )
            Picker("Type", selection: $type) {
                Text("Expense").tag(TransactionType.expense)
                Text("Income").tag(TransactionType.income)
            }.pickerStyle(SegmentedPickerStyle())
            TextField("€€€", text: $sumString)
                .keyboardType(.decimalPad)
                .padding(10)
                .background(Color("textFieldBackground"))
                .cornerRadius(10)
            TextField("Category", text: $category)
                .padding(10)
                .background(Color("textFieldBackground"))
                .cornerRadius(10)
            TextField("Company", text: $secondParty)
                .padding(10)
                .background(Color("textFieldBackground"))
                .cornerRadius(10)
            DatePicker(selection: $date){}.labelsHidden()
            
            Spacer()
        }
        .padding()
    }
}

struct EditTransactionView_Previews: PreviewProvider {
    static var previews: some View {
        EditTransactionView(
            transaction: Transaction(),
            onDone: { _ in },
            onCancel: {}
        )
    }
}

class CurrencyFormatter: Formatter {
    // TODO: - Implement CurrencyFormatter
}
