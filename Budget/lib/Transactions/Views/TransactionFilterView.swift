//
//  TransactionFilter.swift
//  Budget
//
//  Created by Elisey Ozerov on 03/01/2021.
//

import SwiftUI

struct TransactionFilterView: View {
    
    //MARK: - Misc
    
    let dateFormatter = DateFormatter()
    @ObservedObject var filter: TransactionFilter
    
    init(sheetView: Binding<SheetView?>, filter: TransactionFilter) {
        self._sheetView = sheetView
        self.filter = filter
        if let from = filter.totalFrom?.toCurrencyString() {
            self._totalFromString = State(initialValue: from)
        }
        if let to = filter.totalTo?.toCurrencyString() {
            self._totalToString = State(initialValue: to)
        }
        dateFormatter.dateFormat = "dd.MM.yyyy"
    }
    
    //MARK: - State fields
    
    @Binding var sheetView: SheetView?
    
    @State var totalFromString: String = ""
    @State var totalToString: String = ""
    
    @State var showFromDatePicker = false
    @State var showToDatePicker = false
    
    //MARK: - Bindings
    
    // double assignments of values to the strings are bcs without them, the string doesnt reformat
    // try seeing if this can be removed in the future
    var totalFromBinding: Binding<String> {
        Binding(
            get: {
                return totalFromString
            },
            set: {
                if($0.count < totalFromString.count && !totalFromString.last!.isNumber) {
                    let regex = try! NSRegularExpression(pattern: "[^0-9]")
                    let string = regex.stringByReplacingMatches(in: $0, range: NSMakeRange(0, $0.count), withTemplate: "")
                    let double = (string[..<string.index(string.endIndex, offsetBy: -1)] as NSString).doubleValue / 100
                    if double == 0 {
                        totalFromString = ""
                        filter.totalFrom = nil
                        return
                    }
                    filter.totalFrom = double
                    totalFromString = $0
                    totalFromString = double.toCurrencyString()
                } else {
                    let double = $0.toDouble()
                    if double == 0 {
                        totalFromString = "0"
                        totalFromString = ""
                        return
                    }
                    filter.totalFrom = double
                    totalFromString = $0
                    totalFromString = double.toCurrencyString()
                }
            }
        )
    }
    
    var totalToBinding: Binding<String> {
        Binding(
            get: {
                return totalToString
            },
            set: {
                if($0.count < totalToString.count && !totalToString.last!.isNumber) {
                    let regex = try! NSRegularExpression(pattern: "[^0-9]")
                    let string = regex.stringByReplacingMatches(in: $0, range: NSMakeRange(0, $0.count), withTemplate: "")
                    let double = (string[..<string.index(string.endIndex, offsetBy: -1)] as NSString).doubleValue / 100
                    if double == 0 {
                        totalToString = ""
                        filter.totalTo = nil
                        return
                    }
                    filter.totalTo = double
                    totalToString = $0
                    totalToString = double.toCurrencyString()
                } else {
                    let double = $0.toDouble()
                    if double == 0 {
                        totalToString = ""
                        return
                    }
                    filter.totalTo = double
                    totalToString = $0
                    totalToString = double.toCurrencyString()
                }
            }
        )
    }
    
    var dateFromBinding: Binding<Date> {
        Binding(
            get: {
                return filter.dateFrom ?? Date()
            },
            set: {
                filter.dateFrom = $0
            }
        )
    }
    
    var dateToBinding: Binding<Date> {
        Binding(
            get: {
                return filter.dateTo ?? Date()
            },
            set: {
                filter.dateTo = $0
            }
        )
    }
    
    var boolToDateBinding: Binding<Bool> {
        Binding(
            get: {
                return filter.dateTo != nil
            },
            set: { val in
                withAnimation(.easeInOut(duration: 0.5)) {
                    showToDatePicker = val
                    if showToDatePicker && showFromDatePicker {
                        showFromDatePicker = false
                    }
                    filter.dateTo = val ? Date() : nil
                }
            }
        )
    }
    
    var boolFromDateBinding: Binding<Bool> {
        Binding(
            get: {
                return filter.dateFrom != nil
            },
            set: { val in
                withAnimation() {
                    showFromDatePicker = val
                    if showToDatePicker && showFromDatePicker {
                        showToDatePicker = false
                    }
                    filter.dateFrom = val ? Date() : nil
                }
            }
        )
    }
    
    var categoryBinding: Binding<String> {
        Binding(
            get: {
                return filter.category ?? ""
            },
            set: {
                filter.category = $0
            }
        )
    }
    
    var otherPartyBinding: Binding<String> {
        Binding(
            get: {
                return filter.otherParty ?? ""
            },
            set: {
                filter.otherParty = $0
            }
        )
    }
    
    //MARK: - Body
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Picker("Type", selection: $filter.type) {
                        Text("Expense").tag(TransactionType.expense)
                        Text("Income").tag(TransactionType.income)
                        Text("None").tag(nil as TransactionType?)
                    }
                }
                Section {
                    TextField("Category", text: categoryBinding)
                    TextField("Company", text: otherPartyBinding)
                }
                Section(header: Text("Total")) {
                    HStack {
                        Text("From")
                        TextField(0.0.toCurrencyString(), text: totalFromBinding)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("To")
                        TextField(0.0.toCurrencyString(), text: totalToBinding)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                Section(header: Text("Date")) {
                    Toggle(isOn: boolFromDateBinding, label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("From")
                                if let date = filter.dateFrom {
                                    Text(dateFormatter.string(from: date))
                                        .foregroundColor(.blue)
                                        .transition(.move(edge: .bottom))
                                }
                            }
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if filter.dateFrom != nil {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    showFromDatePicker.toggle()
                                    if showFromDatePicker && showToDatePicker {
                                        showToDatePicker = false
                                    }
                                }
                            }

                        }
                    })

                    if showFromDatePicker {
                        DatePicker(selection: dateFromBinding){}
                    }

                    Toggle(isOn: boolToDateBinding, label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("To")
                                if let date = filter.dateTo {
                                    Text(dateFormatter.string(from: date))
                                        .foregroundColor(.blue)
                                        .transition(.move(edge: .bottom))
                                }
                            }
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if filter.dateTo != nil {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    showToDatePicker.toggle()
                                    if showToDatePicker && showFromDatePicker {
                                        showFromDatePicker = false
                                    }
                                }
                            }
                        }
                    })

                    if showToDatePicker {
                        DatePicker(selection: dateToBinding){}
                            .transition(.opacity)
                    }
                }
            }
            .navigationTitle("Filter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: filter.reset, label: {
                        Text("Clear")
                    })
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {sheetView = nil}, label: {
                        Text("Done")
                    })
                }
            }
        }
    }
}

struct TransactionFilterView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionFilterView(sheetView: .constant(.add), filter: TransactionFilter())
            .environmentObject(TransactionFilter())
    }
}
