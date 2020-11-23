//
//  IncomeSheetView.swift
//  Budget
//
//  Created by Elisey Ozerov on 15/11/2020.
//  Copyright © 2020 Elisey Ozerov. All rights reserved.
//

import SwiftUI

struct AddTransactionView: View {
    @State var type = TransactionType.expense
    @State var sumString = ""
    @State var category = ""
    @State var source = ""
    @State var date = Date()
    
    var sum: Double { Double(sumString.replacingOccurrences(of: ",", with: ".")) ?? 0.00 }
    
    var onDone: (Transaction) -> Void
    var onCancel: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 25) {
                SheetTitleBar(
                    title: "New transaction",
                    doneText: "Add",
                    onDone: {
                        onDone(
                            Transaction(
                                date: date,
                                total: sum,
                                type: type,
                                category: category,
                                secondParty: source
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
                TextField("Company", text: $source)
                    .padding(10)
                    .background(Color("textFieldBackground"))
                    .cornerRadius(10)
                DatePicker(selection: $date){}.labelsHidden()
                
                
                Spacer()
            }
            .padding()
            .navigationBarHidden(true)
        }
    }
}

struct AddTransactionView_Previews: PreviewProvider {
    static var previews: some View {
        AddTransactionView(
            onDone: { _ in },
            onCancel: {}
        )
    }
}

struct SheetTitleBar: View {
    
    var title: String
    var doneText: String
    var onDone = {}
    var onCancel = {}
    
    var body: some View {
        HStack {
            Button(action: onCancel, label: {
                Text("Cancel")
            })
            Spacer()
            Text(title)
                .font(.headline)
            Spacer()
            Button(action: onDone, label: {
                Text(doneText)
            })
        }
        .padding(.bottom)
    }
}


