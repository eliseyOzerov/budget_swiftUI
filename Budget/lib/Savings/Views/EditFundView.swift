//  EditFundView.swift
//  test
//
//  Created by Elisey Ozerov on 20/02/2021.
//

import SwiftUI
import RealmSwift

struct EditFundView: View {
    @Environment(\.presentationMode) var presentation
    @Binding var isPresented: Bool

    @ObservedObject var model: SavingsViewModel
    @ObservedObject var fund: Fund
    
    @State var title: String = ""
    @State var goalString: String = ""

    init(model: SavingsViewModel, fund: Fund, isPresented: Binding<Bool>) {
        self.model = model
        self.fund = fund
        self._goalString = State(initialValue: fund.goal.toCurrencyString())
        self._title = State(initialValue: fund.title)
        self._isPresented = isPresented
    }
    
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
                    if double > 0 {
                        goalString = $0
                        goalString = double.toCurrencyString()
                    }
                } else {
                    let double = $0.toDouble()
                    if double > 0 {
                        goalString = $0
                        goalString = double.toCurrencyString()
                    }
                }
            }
        )
    }

    var body: some View {
        Form {
            Section(header: Text("Title")){
                TextField("Type something", text: $title)
            }
            Section(header: Text("Goal")) {
                TextField(0.0.toCurrencyString(), text: goalBinding)
            }
        }
        .navigationTitle("Edit goal")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    fund.goal = goalString.toDouble()
                    fund.title = title
                    model.addModifyFund(
                        Fund(
                            id: fund.id,
                            title: title,
                            goal: goalString.toDouble(),
                            current: fund.current
                        )
                    )
                    presentation.wrappedValue.dismiss()
                    isPresented = false
                }, label: {
                    Text("Done")
                })
            }
        }
    }
}

struct EditFundView_Previews: PreviewProvider {
    static var previews: some View {
        EditFundView(model: SavingsViewModel(), fund: Fund(), isPresented: .constant(true))
    }
}
