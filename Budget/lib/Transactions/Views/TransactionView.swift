//
//  IncomeSheetView.swift
//  Budget
//
//  Created by Elisey Ozerov on 15/11/2020.
//  Copyright © 2020 Elisey Ozerov. All rights reserved.
//

import SwiftUI
import RealmSwift

struct TransactionView: View {
    @Environment(\.presentationMode) var presentation
    @ObservedObject var budgetModel = BudgetsViewModel.shared
    
    @State var type = TransactionType.expense
    @State var sumString = ""
    @State var category = ""
    @State var source = ""
    @State var date = Date()
    
    @State var showErrors = false
    @State var showTypePicker = false
    @State var showCategoryError = false
    
    var canAdd: Bool {
        !showErrors && !showCategoryError
    }
    
    @FocusState var categoryFocus: Bool
    
    private var id: ObjectId?
    
    var onDone: (Transaction) -> Void
    var onCancel: () -> Void
    
    var sum: Double {
        // define regex to remove non-numeric characters
        let regex = try! NSRegularExpression(pattern: "[^0-9]")
        // get string representation of all numeric characters
        let string = regex.stringByReplacingMatches(in: sumString, range: NSMakeRange(0, sumString.count), withTemplate: "")
        // assuming 2 decimal places for formatted string value
        return (string as NSString).doubleValue / 100
    }
    
    var suggestedCategory: String {
        let categories = budgetModel.budgets.map { $0.title }
        let filtered = categories.filter { $0.contains(category) }
        
        if !filtered.isEmpty && type == .expense {
            return filtered.first!
        } else {
            return ""
        }
    }
    
    init(transaction: Transaction? = nil, onDone: @escaping (Transaction) -> Void, onCancel: @escaping () -> Void) {
        if let transaction = transaction {
            id = transaction.id
            _type = State(initialValue: transaction.type)
            _sumString = State(initialValue: transaction.total.toCurrencyString())
            _category = State(initialValue: transaction.category)
            _source = State(initialValue: transaction.secondParty)
            _date = State(initialValue: transaction.date)
        }
        self.onDone = onDone
        self.onCancel = onCancel
    }
    
    var body: some View {
        let sumBinding = Binding(
            get: {
                return sumString
            },
            set: {
                // if user deleted a character
                if($0.count < sumString.count && !sumString.last!.isNumber) {
                    // define regex to remove non-numeric characters
                    let regex = try! NSRegularExpression(pattern: "[^0-9]")
                    // get string representation of all numeric characters
                    let string = regex.stringByReplacingMatches(in: $0, range: NSMakeRange(0, $0.count), withTemplate: "")
                    // remove last character and create double from resulting value
                    let double = (string[..<string.index(string.endIndex, offsetBy: -1)] as NSString).doubleValue / 100
                    // makes sure that textfield value reformats, even if the underlying double doesn't change. if this isn't done, when value stays 0 for example (same as in the beginning), the textfield value doesn't reformat which enables user to delete currency symbol if it's placed at the end or add zero's after the currency symbol
                    sumString = $0
                    sumString = double.toCurrencyString()
                } else {
                    sumString = $0
                    sumString = $0.toDouble().toCurrencyString()
                }
            }
        )
        return NavigationView {
            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        presentation.wrappedValue.dismiss()
                    }, label: {
                        Text("Cancel")
                    })
                    Spacer()
                    Text("\(id != nil ? "Edit" : "New") transaction")
                        .font(.headline)
                    Spacer()
                    Button(action: {
                        if sum == 0 ||
                            category.isEmpty ||
                            source.isEmpty {
                            showErrors = true
                            return
                        }
                        
                        let transaction = Transaction(
                            date: date,
                            total: sum,
                            type: type,
                            category: category,
                            secondParty: source
                        )
                        
                        if let id = id {
                            transaction.id = id
                        }
                        
                        onDone(transaction)
                    }, label: {
                        Text(id != nil ? "Done" : "Add")
                    })
                    .disabled(!canAdd)
                }
                .padding()
                
                NavigationLink(
                    destination: PickerOptionsView(
                        options: TransactionType.values,
                        selection: $type
                    ).navigationTitle("").navigationBarTitleDisplayMode(.inline),
                    isActive: $showTypePicker){
                    
                    HStack {
                        Text("Type")
                        Spacer()
                        Text(type.title)
                            .fontWeight(.medium)
                            .foregroundColor(Color(UIColor.systemGray2))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Color(UIColor.systemGray4))
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(Color("formRow"))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top, 20)
                
                
                VStack(spacing: 0) {
                    HStack {
                        VStack(alignment: .leading) {
                            ZStack(alignment: .leading) {
                                Text(suggestedCategory)
                                    .foregroundColor(.gray)
                                TextField("Category", text: $category)
                                    .disableAutocorrection(true)
                                    .focused($categoryFocus)
                                    .onChange(of: categoryFocus) { focused in
                                        if !focused && !category.isEmpty {
                                            if suggestedCategory != "" {
                                                category = suggestedCategory
                                            } else {
                                                if type == .expense {
                                                    showCategoryError = true
                                                }
                                            }
                                        }
                                    }
                            }
                            
                            if category.isEmpty && showErrors {
                                Text("Required")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                            
                            if suggestedCategory.isEmpty && showCategoryError {
                                Text("Category doesn't exist")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            TextField(0.0.toCurrencyString(), text: sumBinding)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                            if sum == 0 && showErrors {
                                Text("Required")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    
                    Rectangle()
                        .frame(height:0.3)
                        .foregroundColor(Color(UIColor.separator))
                        .padding(.leading)
                    
                    VStack(alignment: .leading) {
                        TextField("Company", text: $source)
                        if source.isEmpty && showErrors {
                            Text("Required")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                }
                .background(Color("formRow"))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.vertical, 25)
                
                DatePicker(selection: $date){
                    Text("Time")
                }
                .padding(.vertical, 6)
                .padding(.horizontal)
                .background(Color("formRow"))
                .cornerRadius(10)
                .padding(.horizontal)
                
                Spacer()
            }
            .background(Color(UIColor.systemGroupedBackground))
            .edgesIgnoringSafeArea(.bottom)
            .navigationTitle("")
            .navigationBarHidden(true)
            .animation(.easeInOut(duration: 0.3))
            .onTapGesture {
                self.hideKeyboard()
            }
        }
    }
}

struct TransactionView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionView(
            onDone: { _ in },
            onCancel: {}
        )
    }
}
