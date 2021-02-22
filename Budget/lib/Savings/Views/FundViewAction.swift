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
    @ObservedObject var model: SavingsViewModel
    @ObservedObject var fund: Fund
    @State var isActive = false
    @State var transferRecepient: Fund?
    @State var showingTransferRecepients = false

    var showError: Bool {
        actionAmountString.toDouble() > fund.current && editAction == .withdraw
    }

    @State var editAction: EditAction = .deposit
    @State var actionAmountString: String = ""

    init(model: SavingsViewModel, fund: Fund) {
        self.model = model
        self.fund = fund
    }

    var editActionBinding: Binding<EditAction> {
        Binding(
            get: {editAction},
            set: {action in
                editAction = action
                if action == .transfer {
                    transferRecepient = model.funds.filter({$0.id != fund.id}).first!
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
            set: {
                // if user deleted a character
                if($0.count < actionAmountString.count && !actionAmountString.last!.isNumber) {
                    // define regex to remove non-numeric characters
                    let regex = try! NSRegularExpression(pattern: "[^0-9]")
                    // get string representation of all numeric characters
                    let string = regex.stringByReplacingMatches(in: $0, range: NSMakeRange(0, $0.count), withTemplate: "")
                    // remove last character and create double from resulting value
                    let double = (string[..<string.index(string.endIndex, offsetBy: -1)] as NSString).doubleValue / 100
                    // makes sure that textfield value reformats, even if the underlying double doesn't change. if this isn't done, when value stays 0 for example (same as in the beginning), the textfield value doesn't reformat which enables user to delete currency symbol if it's placed at the end or add zero's after the currency symbol
                    actionAmountString = $0
                    actionAmountString = double.toCurrencyString()
                } else {
                    actionAmountString = $0
                    actionAmountString = $0.toDouble().toCurrencyString()
                }
            }
        )
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                ProgressView(value: min(fund.current, fund.goal), total: fund.goal)
                    .progressViewStyle(ProgressBarStyleNoBgr())
                    .padding(.horizontal)
                    .padding(.top)

                HStack(alignment: .firstTextBaseline) {
                    Text(fund.current.toCurrencyString())
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


                if fund.current > 0 {
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



                VStack(spacing: 0) {
                    HStack {
                        VStack(alignment: .leading) {
                            TextField(0.0.toCurrencyString(), text: actionAmountBinding)
                            if showError {
                                Text("Not enough funds")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        Button(action: {
                            switch editAction {
                            case .withdraw, .transfer:
                                actionAmountString = fund.current.toCurrencyString()
                                break
                            case .deposit:
                                actionAmountString = (fund.goal - fund.current).toCurrencyString()
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
                .padding()

                HStack {
                    Spacer()
                    Button(action: {
                        switch editAction {
                        case .deposit:
                            fund.current += actionAmount
                            break
                        case .withdraw:
                            fund.current -= actionAmount
                            break
                        case .transfer:
                            fund.current -= actionAmount
                            transferRecepient!.current += actionAmount
                            break
                        }
                        actionAmountString = ""

                        if fund.current <= 0 {
                            editAction = .deposit
                        }

                    }) {
                        Text(editAction.rawValue.uppercased())
                            .fontWeight(.bold)
                    }
                    .disabled(showError)
                }
                .padding(.horizontal)
                .padding(.horizontal)
                Spacer()
                    
            }
            .background(Color(UIColor.systemGroupedBackground))
            .edgesIgnoringSafeArea(.bottom)
            .navigationTitle(fund.title)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: EditFundView(model: model, fund: fund, isPresented: $isActive), isActive: $isActive){
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
                .scaleEffect(x: CGFloat(configuration.fractionCompleted!), y: 1.0, anchor: .leading)
        }
        .frame(height: 10)
        .cornerRadius(10)
    }
}

struct FundViewAction_Previews: PreviewProvider {
    static var previews: some View {
        FundViewAction(model: SavingsViewModel(), fund: Fund())
    }
}

protocol Titled {
    var title: String {get set}
}
