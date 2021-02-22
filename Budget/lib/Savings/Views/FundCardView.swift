//
//  SwiftUIView.swift
//  Budget
//
//  Created by Elisey Ozerov on 17/02/2021.
//

import SwiftUI

struct FundCardView: View {
    var fund: Fund
    var geometry: GeometryProxy
    
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text(fund.title)
                    .font(.headline)
                Spacer()
                Text("\(fund.current.toCurrencyString()) / \(fund.goal.toCurrencyString())")
                    .font(.caption)
            }
            ProgressView(value: min(fund.current, fund.goal), total: fund.goal)
                .progressViewStyle(ProgressBarStyle())
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}

struct ProgressBarStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color(UIColor.systemGroupedBackground))
            Rectangle()
                .foregroundColor(.green)
                .scaleEffect(x: CGFloat(configuration.fractionCompleted!), y: 1.0, anchor: .leading)
        }
        .frame(height: 10)
        .cornerRadius(7)
    }
}

struct FundCardView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geometry in
            FundCardView(fund: Fund(), geometry: geometry)
        }
        
    }
}
