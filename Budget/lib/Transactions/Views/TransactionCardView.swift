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
    var cardSize: CGSize
    var onPressed: () -> Void
    var onDelete: () -> Void
    
    @State var offset: CGFloat = 0
    
    @State var startOffset: CGFloat = 0
    @State var lastChange: CGFloat = 0
    
    @State var open = false
    @State var showOverlay = false
    
    @State var shouldCallOnPressed = false
    
    var openOffset: CGFloat = -(44 + 16)
    
    
    var body: some View {
        HStack(spacing: 0) {
            Button(action: onPressed) {
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
                .overlay(Color.gray.opacity(showOverlay ? 0.05 : 0))
                .cornerRadius(10)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .frame(width: cardSize.width)
                .gesture(
                    DragGesture(minimumDistance: 10, coordinateSpace: .local)
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
                                    offset = openOffset
                                    open = true
                                }
                                startOffset = offset
                            }
                        }
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(Color("red"))
                    .frame(width: 44, height: 44)
            }
        }
        .offset(x: offset)
    }
}

struct TransactionCardView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            TransactionCardView(
                model: Transaction(),
                cardSize: geo.size,
                onPressed: {},
                onDelete: {}
            )
        }
    }
}
