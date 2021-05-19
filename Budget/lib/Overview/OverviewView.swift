//
//  OverviewView.swift
//  Budget
//
//  Created by Elisey Ozerov on 09/03/2021.
//

import SwiftUI

struct OverviewView: View {
    var categories = ["Streaming", "Groceries", "Gas", "Clothes", "Partying",
                      "Streaming", "Groceries", "Gas", "Clothes", "Partying",
                      "Streaming", "Groceries", "Gas", "Clothes", "Partying"]
    var body: some View {
        GeometryReader { geo in
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading) {
                    Text(14325.41.toCurrencyString())
                        .font(.system(size: 42))
                        .fontWeight(.bold)
                    Text("total net worth")
                        .foregroundColor(.gray)
                }
                .padding(.top, geo.safeAreaInsets.top)
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Text("savings")
                            .foregroundColor(.gray)
                        Spacer()
                        Text(12025.41.toCurrencyString())
                            .font(.title)
                            .fontWeight(.bold)
                        HStack(spacing: 5) {
                            Image(systemName: "arrowtriangle.up.fill")
                            Text("\(48.5, specifier: "%.2f") %")
                        }
                        .font(.caption)
                        .foregroundColor(Color("green"))
                    }
                    HStack {
                        Text("budgeted")
                            .foregroundColor(.gray)
                        Spacer()
                        Text(1205.41.toCurrencyString())
                            .font(.title)
                            .fontWeight(.bold)
                        HStack(spacing: 5) {
                            Image(systemName: "arrowtriangle.down.fill")
                            Text("\(5.1, specifier: "%.2f") %")
                        }
                        .font(.caption)
                        .foregroundColor(Color("red"))
                    }
                }
                VStack(alignment: .leading) {
                    Text("top spending")
                        .foregroundColor(.gray)
                    TagCloudView(tags: categories)
                }
                VStack(alignment: .leading) {
                    Text("top savings")
                        .foregroundColor(.gray)
                    TagCloudView(tags: categories)
                }
            }
            .padding()
            .background(Color(UIColor.systemGroupedBackground))
            .edgesIgnoringSafeArea(.top)
        }
    }
}

struct OverviewView_Previews: PreviewProvider {
    static var previews: some View {
        OverviewView()
    }
}


