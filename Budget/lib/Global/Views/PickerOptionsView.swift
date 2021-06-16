//
//  PickerOptionsView.swift
//  Budget
//
//  Created by Elisey Ozerov on 19/02/2021.
//

import SwiftUI

struct PickerOptionsView<T>: View where T: Titled, T: Identifiable {
    @Binding var selection: T
    private var options: [T]
    @Environment(\.presentationMode) var presentation
    
    init(options: [T], selection: Binding<T>) {
        self._selection = selection
        self.options = options
    }
    
    var body: some View {
        NavigationView {
            List(options) { option in
                HStack {
                    Text(option.title)
                        .onTapGesture {
                            selection = option
                            presentation.wrappedValue.dismiss()
                        }
                    if selection.id == option.id {
                        Spacer()
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding(.top)
            .listStyle(InsetGroupedListStyle())
            .background(Color(UIColor.systemGroupedBackground))
            .edgesIgnoringSafeArea(.bottom)
            .navigationBarTitle("") // swiftui thing
            .navigationBarHidden(true)
        }
        .onAppear{
            UITableView.appearance().separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 100)
        }
    }
}

struct PickerOptionsView_Previews: PreviewProvider {
    static let arr = [Fund(title: "Somethign", goal: 2000),
    Fund(title: "Else", goal: 100)]
    
    static var previews: some View {
        PickerOptionsView(options: arr, selection: .constant(arr[1]))
    }
}
