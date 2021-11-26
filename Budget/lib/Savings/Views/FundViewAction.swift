////
//  FundView.swift
//  Budget
//
//  Created by Elisey Ozerov on 17/02/2021.
//

import SwiftUI
import RealmSwift

enum EditAction: String {
    case deposit = "Deposit"
    case withdraw = "Withdraw"
    case transfer = "Transfer"
}

struct FundViewAction: View {
    @ObservedObject var transactionsModel = TransactionsViewModel.shared
    @ObservedObject var budgetsModel = BudgetsViewModel.shared
    
    @ObservedObject var model = SavingsViewModel.shared
    @ObservedObject var fund: Fund
    var saved: Double
    
    @State var isActive = false
    @State var transferRecepient: Fund?
    @State var showingTransferRecepients = false
    @State var didTapSubmit = false

    var showError: Bool {
        switch editAction {
        case .withdraw, .transfer:
            return actionAmountString.toDouble() > saved
        case .deposit:
            return didTapSubmit && (actionAmountString.isEmpty || actionAmountString.toDouble() == 0) ||
                actionAmountString.toDouble() > unallocated
        }
    }
    
    // user wants to withdraw/transfer more than they have in the fund - error
    // user wants to deposit more than they have unallocated - error
    // user wants to deposit 0 - error
    var errorMessage: String {
        switch editAction {
        case .withdraw, .transfer:
            return "Not enough funds."
        case .deposit:
            if actionAmountString.toDouble() > unallocated {
                return "Not enough funds"
            }
            if didTapSubmit && (actionAmountString.isEmpty || actionAmountString.toDouble() == 0) {
                return "Please enter a valid value."
            }
        }
        return "Error." // shouldnt appear
    }
    
    var submitDisabled: Bool {
        if actionAmountString.toDouble() == 0 {
            return true
        }
        switch editAction {
        case .withdraw, .transfer:
            return actionAmountString.toDouble() > saved
        case .deposit:
            return actionAmountString.isEmpty || actionAmountString.toDouble() > unallocated
        }
    }

    @State var editAction: EditAction = .deposit
    @State var actionAmountString: String = ""

    init(model: SavingsViewModel, fund: Fund, saved: Double) {
        self.model = model
        self.fund = fund
        self.saved = saved
    }

    var editActionBinding: Binding<EditAction> {
        Binding(
            get: {editAction},
            set: {action in
                withAnimation {
                    editAction = action
                    if action == .transfer {
                        transferRecepient = model.funds.filter({$0.id != fund.id}).first!
                    }
                }
                
            }
        )
    }

    var actionAmount: Double {
        // define regex to remove non-numeric characters
        let regex = try! NSRegularExpression(pattern: "[^0-9]")
        // get string representation of all numeric characters
        let string = regex.stringByReplacingMatches(in: actionAmountString, range: NSMakeRange(0, actionAmountString.count), withTemplate: "")
        // assuming 2 decimal places for formatted string value
        return (string as NSString).doubleValue / 100
    }

    var actionAmountBinding: Binding<String> {
        Binding(
            get: {
                return actionAmountString
            },
            set: { newVal in
                // if user deleted a character
                if(newVal.count < actionAmountString.count && !actionAmountString.last!.isNumber) {
                    // define regex to remove non-numeric characters
                    let regex = try! NSRegularExpression(pattern: "[^0-9]")
                    // get string representation of all numeric characters
                    let string = regex.stringByReplacingMatches(in: newVal, range: NSMakeRange(0, newVal.count), withTemplate: "")
                    // remove last character and create double from resulting value
                    let double = (string[..<string.index(string.endIndex, offsetBy: -1)] as NSString).doubleValue / 100
                    // makes sure that textfield value reformats, even if the underlying double doesn't change. if this isn't done, when value stays 0 for example (same as in the beginning), the textfield value doesn't reformat which enables user to delete currency symbol if it's placed at the end or add zero's after the currency symbol
                    actionAmountString = newVal
                    
                    withAnimation {
                        actionAmountString = double.toCurrencyString()
                        // can't add 0 as the first char
                        if double == 0 {
                            actionAmountString = ""
                        }
                    }
                } else {
                    
                    withAnimation {
                        actionAmountString = newVal
                        actionAmountString = newVal.toDouble().toCurrencyString()
                        // can't add 0 as the first char
                        if newVal.toDouble() == 0 {
                            actionAmountString = ""
                        }
                        didTapSubmit = false
                    }
                }
            }
        )
    }
    
    var unallocated: Double {
        max(0, transactionsModel.balance -
            budgetsModel.budgets.reduce(0) { $0 + max(0, $1.budget) }) // max used bcs if budget is negative, it can't count towards unallocated/available funds
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                ProgressView(value: min(saved, fund.goal), total: fund.goal)
                    .progressViewStyle(ProgressBarStyleNoBgr())
                    .padding(.horizontal)
                    .padding(.top)

                HStack(alignment: .firstTextBaseline) {
                    Text(saved.toCurrencyString())
                        .font(.title)
                        .fontWeight(.bold)
                    Text("of \(fund.goal.toCurrencyString())")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top)
                .padding(.bottom, 20)
                .contentShape(Rectangle())
                .onTapGesture {
                    self.hideKeyboard()
                    withAnimation {
                        didTapSubmit = false
                    }
                }


                if saved > 0 {
                    Picker(selection: editActionBinding, label: Text("Action")) {
                        Text(EditAction.deposit.rawValue).tag(EditAction.deposit)
                        Text(EditAction.withdraw.rawValue).tag(EditAction.withdraw)
                        if model.funds.count > 1 {
                            Text(EditAction.transfer.rawValue).tag(EditAction.transfer)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                }


                VStack {
                    VStack(spacing: 0) {
                        HStack {
                            VStack(alignment: .leading) {
                                TextField(0.0.toCurrencyString(), text: actionAmountBinding)
                                    .keyboardType(.numberPad)
                                if showError{
                                    Text(errorMessage)
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                            }
                            Button(action: {
                                switch editAction {
                                case .withdraw, .transfer:
                                    actionAmountString = saved.toCurrencyString()
                                    break
                                case .deposit:
                                    actionAmountString = min(unallocated, fund.goal - saved).toCurrencyString()
                                    break
                                }
                            }, label: {
                                Text("max")
                            })
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 10)

                        if editAction == .transfer {
                            VStack(spacing: 0) {
                                Rectangle()
                                    .frame(height:0.3)
                                    .foregroundColor(Color(UIColor.separator))
                                    .padding(.leading)

                                NavigationLink(
                                    destination: PickerOptionsView(
                                        options: model.funds.filter({$0.id != fund.id}),
                                        selection: Binding(get: {transferRecepient!}, set: {transferRecepient = $0})
                                    ),
                                    isActive: $showingTransferRecepients){
                                    HStack {
                                        Text("To")
                                        Spacer()
                                        Text(transferRecepient!.title)
                                            .foregroundColor(Color(UIColor.systemGray4))
                                        Image(systemName: "chevron.right")
                                            .font(.headline)
                                            .foregroundColor(Color(UIColor.systemGray4))
                                    }
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.horizontal)
                                .padding(.vertical, 10)
                            }
                        }
                    }
                    .background(Color("formRow"))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.top)
                    .padding(.bottom, 10)

                    HStack(alignment: .top) {
                        if editAction == .deposit {
                            HStack(alignment: .firstTextBaseline) {
                                Text("\(unallocated.toCurrencyString())")
                                Text(" available.")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal)
                        }
                        
                        Spacer()
                        Button(action: {
                            switch editAction {
                            case .deposit:
                                transactionsModel.addModifyTx(
                                    Transaction(
                                        date: Date(),
                                        total: actionAmount,
                                        type: .deposit,
                                        category: "Deposit",
                                        secondParty: fund.title
                                    )
                                )
                                break
                            case .withdraw:
                                transactionsModel.addModifyTx(
                                    Transaction(
                                        date: Date(),
                                        total: actionAmount,
                                        type: .withdrawal,
                                        category: "Withdrawal",
                                        secondParty: fund.title
                                    )
                                )
                                break
                            case .transfer:
                                transactionsModel.addModifyTx(
                                    Transaction(
                                        date: Date(),
                                        total: actionAmount,
                                        type: .transfer,
                                        category: "Transfer",
                                        secondParty: "\(fund.title) -> \(transferRecepient!.title)"
                                    )
                                )
                                break
                            }
                            
                            actionAmountString = ""

                            if saved <= 0 {
                                editAction = .deposit
                            }

                        }) {
                            Text(editAction.rawValue.uppercased())
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                                .padding(.vertical, 10)
                                .background(Color.blue)
                                .cornerRadius(30)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(submitDisabled)
                        .onTapGesture {
                            withAnimation {
                                didTapSubmit = true
                            }
                        }
                    }
                    .padding(.horizontal)
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    self.hideKeyboard()
                    withAnimation {
                        didTapSubmit = false
                    }
                }
                    
            }
            .background(Color(UIColor.systemGroupedBackground))
            .edgesIgnoringSafeArea(.bottom)
            .navigationTitle(fund.title)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: EditFundView(fund: fund, isPresented: $isActive), isActive: $isActive){
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
    }
}

struct ProgressBarStyleNoBgr: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color("formRow"))
            Rectangle()
                .foregroundColor(Color.green)
                .scaleEffect(x: CGFloat(configuration.fractionCompleted ?? 0), y: 1.0, anchor: .leading)
        }
        .frame(height: 10)
        .cornerRadius(10)
    }
}

struct FundViewAction_Previews: PreviewProvider {
    static var previews: some View {
        FundViewAction(model: SavingsViewModel.shared, fund: Fund(), saved: 100.0)
    }
}

protocol Titled {
    var title: String {get}
}
