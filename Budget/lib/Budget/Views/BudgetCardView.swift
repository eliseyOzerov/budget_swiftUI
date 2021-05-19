//
//  SwiftUIView.swift
//  Budget
//
//  Created by Elisey Ozerov on 17/02/2021.
//

import SwiftUI

struct BudgetCardView: View {
    var budget:  Budget
    var spent: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text(budget.title)
                    .font(.headline)
                Spacer()
                HStack(alignment: .firstTextBaseline) {
                    Text("\((budget.budget - spent).toCurrencyString())")
                        .fontWeight(.bold)
                    Text("left")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
            }
            ProgressView(value: min(spent, budget.budget), total: budget.budget)
                .progressViewStyle(BudgetProgressBarStyle(total: budget.budget, spent: spent))
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}

struct BudgetProgressBarStyle: ProgressViewStyle {
    var total: Double
    var spent: Double
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .foregroundColor(Color(UIColor.systemGroupedBackground))
            Rectangle()
                .foregroundColor(.blue)
                .scaleEffect(x: CGFloat(configuration.fractionCompleted ?? 0), y: 1.0, anchor: .leading)
            HStack {
                Text("\(spent.toCurrencyString())")
                Spacer()
                Text(total.toCurrencyString())
            }
            .font(.caption)
            .foregroundColor(.gray)
            .padding(.horizontal, 5)
            
            HStack {
                Text("\(spent.toCurrencyString())")
                Spacer()
                Text(total.toCurrencyString())
            }
            .font(.caption)
            .foregroundColor(.white)
            .padding(.horizontal, 5)
            .clipShape(Rectangle()
                        .transform(.init(scaleX: CGFloat(configuration.fractionCompleted ?? 0), y: 1.0)))
        }
        .frame(height: 20)
        .cornerRadius(7)
    }
}

struct BudgetCardView_Previews: PreviewProvider {
    static var previews: some View {
        BudgetCardView(budget: Budget(), spent: 70)
    }
}
