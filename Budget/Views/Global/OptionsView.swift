//
//  OptionsView.swift
//  Budget
//
//  Created by Elisey Ozerov on 15/11/2020.
//  Copyright © 2020 Elisey Ozerov. All rights reserved.
//

import SwiftUI

struct OptionsView: View {
    @Binding var selection: Int
    
    var options: Array<String>
    
    @Environment(\.presentationMode) var presentation
    
    var body: some View {
        ZStack(alignment: .top) {
            Color("cardBackground")
            VStack(spacing: 0) {
                Divider()
                ForEach(0 ..< self.options.count) { i in
                    VStack(spacing: 0) {
                        HStack {
                            Text(self.options[i])
                            Spacer()
                            if i == selection {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.vertical)
                        .padding(.trailing)
                        .background(Color.white)
                        .onTapGesture {
                            selection = i
                            self.presentation.wrappedValue.dismiss()
                        }
                        Divider()
                    }
                }
            }
            .padding(.leading)
            .padding(.bottom)
            .background(
                Color.white
                    .edgesIgnoringSafeArea(.top)
                    .shadow(color: Color("shadow"), radius: 10, y: 4)
            )
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct OptionsView_Previews: PreviewProvider {
    static var previews: some View {
        OptionsView(selection: .constant(0), options: ["1", "2", "3"])
    }
}
