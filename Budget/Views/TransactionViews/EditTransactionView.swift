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
    
    @Binding var isShown: Bool
    
    @State var type: TransactionType
    @State var sumString: String
    @State var category: String
    @State var date: Date
    @State var secondParty: String
    
    private var id: ObjectId
    
    init(transaction: Transaction, isShown: Binding<Bool>) {
        self._isShown = isShown
        id = transaction.id
        _type = State(initialValue: transaction.type)
        _sumString = State(initialValue: "\(transaction.total)")
        _category = State(initialValue: transaction.category)
        _secondParty = State(initialValue: transaction.secondParty)
        _date = State(initialValue: transaction.date)
    }
    
    var sum: Double { Double(sumString.replacingOccurrences(of: ",", with: ".")) ?? 0.00 }
    
    @State private var errorShowing = false
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(alignment: .leading, spacing: 25) {
            SheetTitleBar(title: "Edit transaction", onDone: {
                Transaction(
                    id: id,
                    date: date,
                    total: sum,
                    type: type,
                    category: category,
                    secondParty: secondParty
                ).save(
                    onSuccess: { self.presentationMode.wrappedValue.dismiss() },
                    onError: { self.errorShowing = true }
                )
            }, onCancel: { isShown = false })
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
        .alert(isPresented: $errorShowing) {
            Alert(title: Text("Error"), message: Text("We were unable to update your transaction. Please try again."))
        }
    }
}

struct EditTransactionView_Previews: PreviewProvider {
    static var previews: some View {
        EditTransactionView(transaction: Transaction(), isShown: .constant(true))
    }
}

class CurrencyFormatter: Formatter {
    // TODO: - Implement CurrencyFormatter
}
