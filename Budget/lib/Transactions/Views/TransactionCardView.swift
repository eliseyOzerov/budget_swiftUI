//
//  IncomeCardView.swift
//  Budget
//
//  Created by Elisey Ozerov on 16/11/2020.
//  Copyright © 2020 Elisey Ozerov. All rights reserved.
//

import SwiftUI

struct TransactionCardView: View {
    var transaction: Transaction
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text(transaction.category)
                    .font(.headline)
                Text(transaction.date.time())
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                Spacer()
                Text(transaction.total.toCurrencyString())
                    .font(.headline)
                    .foregroundColor(Color(transaction.type == TransactionType.expense ? "red" : "green"))
            }
            Text(transaction.secondParty)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}

struct TransactionCardView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            TransactionCardView(
                transaction: Transaction()
            )
        }
    }
}
