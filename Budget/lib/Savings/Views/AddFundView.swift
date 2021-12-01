//
//  FundViewEdit.swift
//  Budget
//
//  Created by Elisey Ozerov on 18/02/2021.
//

import SwiftUI
import RealmSwift

struct AddFundView: View {
    @Environment(\.presentationMode) var presentation
    
    @ObservedObject var model = SavingsViewModel.shared
    @State var title: String = ""
    @State var goalString: String = ""
    @State var currentString: String = 0.0.toCurrencyString()
    
    var goalBinding: Binding<String> {
        Binding(
            get: {
                return goalString
            },
            set: {
                // if user deleted a character
                if($0.count < goalString.count && !goalString.last!.isNumber) {
                    // define regex to remove non-numeric characters
                    let regex = try! NSRegularExpression(pattern: "[^0-9]")
                    // get string representation of all numeric characters
                    let string = regex.stringByReplacingMatches(in: $0, range: NSMakeRange(0, $0.count), withTemplate: "")
                    // remove last character and create double from resulting value
                    let double = (string[..<string.index(string.endIndex, offsetBy: -1)] as NSString).doubleValue / 100
                    // makes sure that textfield value reformats, even if the underlying double doesn't change. if this isn't done, when value stays 0 for example (same as in the beginning), the textfield value doesn't reformat which enables user to delete currency symbol if it's placed at the end or add zero's after the currency symbol
                    goalString = $0
                    goalString = double.toCurrencyString()
                } else {
                    goalString = $0
                    goalString = $0.toDouble().toCurrencyString()
                }
            }
        )
    }
    
    var currentBinding: Binding<String> {
        Binding(
            get: {
                return currentString
            },
            set: {
                // if user deleted a character
                if($0.count < currentString.count && !currentString.last!.isNumber) {
                    // define regex to remove non-numeric characters
                    let regex = try! NSRegularExpression(pattern: "[^0-9]")
                    // get string representation of all numeric characters
                    let string = regex.stringByReplacingMatches(in: $0, range: NSMakeRange(0, $0.count), withTemplate: "")
                    // remove last character and create double from resulting value
                    let double = (string[..<string.index(string.endIndex, offsetBy: -1)] as NSString).doubleValue / 100
                    // makes sure that textfield value reformats, even if the underlying double doesn't change. if this isn't done, when value stays 0 for example (same as in the beginning), the textfield value doesn't reformat which enables user to delete currency symbol if it's placed at the end or add zero's after the currency symbol
                    currentString = $0
                    currentString = double.toCurrencyString()
                } else {
                    currentString = $0
                    currentString = $0.toDouble().toCurrencyString()
                }
            }
        )
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Title")){
                    TextField("Type something", text: $title)
                }
                Section(header: Text("Goal")) {
                    TextField(0.0.toCurrencyString(), text: goalBinding)
                        .keyboardType(.numberPad)
                }
                Section(header: Text("Currently saved")) {
                    TextField(0.0.toCurrencyString(), text: currentBinding)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("New goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentation.wrappedValue.dismiss()
                    }, label: {
                        Text("Cancel")
                    })
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        model.addModifyFund(
                            Fund(
                                title: title,
                                goal: goalString.toDouble()
                            )
                        )
                        presentation.wrappedValue.dismiss()
                    }, label: {
                        Text("Add")
                    })
                }
        }
        }
    }
}

struct BoldButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.font(.system(size: 16, weight: .bold))
    }
}

struct FundViewEdit_Previews: PreviewProvider {
    static var previews: some View {
        AddFundView(model: SavingsViewModel.shared)
    }
}
