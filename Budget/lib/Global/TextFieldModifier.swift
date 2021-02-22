//
//  TextFieldModifier.swift
//  Budget
//
//  Created by Elisey Ozerov on 27/11/2020.
//

import SwiftUI


struct BudgetTextField: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(10)
            .background(Color("textFieldBackground"))
            .cornerRadius(10)
    }
}

struct TextInputView: UIViewRepresentable {
    @Binding var text: String
    @State var placeholder: String
    
    init(_ placeholder: String, text: Binding<String>) {
        self._text = text
        self._placeholder = State(initialValue: placeholder)
    }

    func makeUIView(context: Context) -> UITextField {
        let view = TextFieldPadded()
        view.placeholder = placeholder
        view.backgroundColor = UIColor(Color("textFieldBackground"))
        return view
    }
    
    class TextFieldPadded: UITextField {
        var textPadding = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

        override func textRect(forBounds bounds: CGRect) -> CGRect {
            let rect = super.textRect(forBounds: bounds)
            return rect.inset(by: textPadding)
        }

        override func editingRect(forBounds bounds: CGRect) -> CGRect {
            let rect = super.editingRect(forBounds: bounds)
            return rect.inset(by: textPadding)
        }
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
    }
}
