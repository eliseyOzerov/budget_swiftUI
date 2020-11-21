//
//  IncomeCardView.swift
//  Budget
//
//  Created by Elisey Ozerov on 16/11/2020.
//  Copyright © 2020 Elisey Ozerov. All rights reserved.
//

import SwiftUI

struct TransactionCardView: View {
    var model: Transaction
    
    @State var offset: CGFloat = 0
    
    @State var startOffset: CGFloat = 0
    @State var lastChange: CGFloat = 0
    
    @State var open = false
    @State var showOverlay = false
    
    @State var showSheet = false
    @State var shouldShowSheet = false
    
    @State var shouldDelete = false
    @State var deletePressed = false
    
    @State var showConfirmAlert = false
    @State var showDeleteErrorAlert = false
    
    var openOffset: CGFloat = -(24 + 32*2 - 16)
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                HStack {
                    Spacer()
                    Image(systemName: "trash")
                        .foregroundColor(Color("red").opacity(deletePressed ? 0.9 : 1))
                        .frame(width: 24, height: 24)
                        .padding(.horizontal, 32)
                }
                .gesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .local)
                        .onChanged { value in
                            if abs(value.translation.width) < 10 {
                                shouldDelete = true
                            } else {
                                shouldDelete = false
                            }
                            withAnimation(.linear(duration: 0.05)) {
                                deletePressed = true
                            }
                        }
                        .onEnded { _ in
                            if shouldDelete {
                                showConfirmAlert = true
                            }
                            
                            withAnimation(.linear(duration: 0.05)) {
                                deletePressed = false
                            }
                        }
                )
                ZStack {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(alignment: .firstTextBaseline, spacing: 12) {
                            Text(model.category)
                                .font(.headline)
                            Text(model.date.time())
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                            Spacer()
                            Text("€\(model.total, specifier: "%.2f")")
                                .font(.headline)
                                .foregroundColor(Color(model.type == TransactionType.expense ? "red" : "green"))
                        }
                        Text(model.secondParty)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color("cardBackground"))
                    Color("cardBackground").opacity(showOverlay ? 0.4 : 0)
                }
                .cornerRadius(10)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .offset(x: offset)
                .gesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .local)
                        .onChanged { value in
                            if abs(value.translation.width) < 10 {
                                shouldShowSheet = true
                            } else {
                                shouldShowSheet = false
                            }
                            withAnimation(.linear(duration: 0.05)) {
                                showOverlay = true
                            }
                        }
                        .onEnded { _ in
                            if shouldShowSheet {
                                showSheet = true
                            }
                            withAnimation(.linear(duration: 0.05)) {
                                showOverlay = false
                            }
                        }.simultaneously(
                            with: DragGesture(minimumDistance: 10, coordinateSpace: .local)
                                .onChanged { value in
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7, blendDuration: 0)) {
                                        if !open && value.translation.width < 0 || // drag left
                                            open && offset < 0 && value.translation.width > 0 { // drag right
                                            offset = startOffset + value.translation.width
                                            lastChange = value.translation.width
                                        }
                                    }
                                    
                                }
                                .onEnded { _ in
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7, blendDuration: 0)) {
                                        if open && lastChange > 0 {
                                            offset = 0
                                            open = false
                                        } else if !open && lastChange < 0 {
                                            offset = -(24 + 32*2 - 16)
                                            open = true
                                        }
                                        startOffset = offset
                                    }
                                }
                        )
                    
                )
            }
            .sheet(
                isPresented: $showSheet,
                content: {
                    EditTransactionView(
                        transaction: model,
                        isShown: $showSheet
                    )
                }
            )
            .alert(isPresented: $showConfirmAlert) {
                Alert(title: Text("Are you sure?"), message: Text("This action is irreversible."), primaryButton: .default(Text("Ok")) {
                    model.delete(onSuccess: {}, onError: { showDeleteErrorAlert = true })
                }, secondaryButton: .cancel())
            }
//            .alert(isPresented: $showDeleteErrorAlert) {
//                Alert(title: Text("Error"), message: Text("We were unable to delete this transaction. Please try again."))
//            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

struct TransactionCardView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TransactionCardView(model: Transaction())
            TransactionCardView(model: Transaction())
        }
    }
}
