//
//  MonthDayPickerView.swift
//  Budget
//
//  Created by Elisey Ozerov on 24/02/2021.
//

import SwiftUI

enum Month: String, Identifiable, CaseIterable, Titled {
    case january
    case february
    case march
    case april
    case may
    case june
    case july
    case august
    case september
    case october
    case november
    case december
    
    var id: Self { self }
    var title: String { self.rawValue.capitalized }
}

enum DatePickerComponent: String, Identifiable, CaseIterable, Titled {
    case year
    case month
    case day
    case weekday
    case time
    
    var id: Self { self }
    var title: String { self.rawValue.capitalized }
}

struct CustomDatePickerView: View {
    @Binding var selection: Date
    @Binding var isShowing: Bool
    var components: [DatePickerComponent]
    
    func buildGrid() -> [[Int]] {
        var c = 1
        var result = [[Int]]()
        
        for i in 0 ..< 5 {
            result.append([Int]())
            for _ in 0 ..< 7 {
                if c <= 31 {
                    result[i].append(c)
                }
                c+=1
            }
        }
        return result
    }
    
    var body: some View {
        ZStack {
            if isShowing  {
                Color.gray.opacity(0.3)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    isShowing = false
                }
            
                VStack(alignment: .leading, spacing: 7) {
                    if components.contains(.month) {
                        HStack {
                            Text(Month.allCases[selection.month - 1].title)
                                .fontWeight(.bold)
                            Spacer()
                            HStack(spacing: 20) {
                                Button(action: {
                                    selection = selection.add(component: .month, value: -1)
                                }){
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 17, weight: .medium))
                                }
                                Button(action: {
                                    selection = selection.add(component: .month, value: 1)
                                }){
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 17, weight: .medium))
                                }
                            }
                        }
                        .frame(maxWidth: 210)
                        .padding(.bottom)
                    }
                    
                    ForEach(buildGrid(), id: \.self) { i in
                        HStack(spacing: 2) {
                            ForEach(i, id: \.self) { j in
                                ZStack {
                                    if j == selection.day {
                                        Circle()
                                            .frame(width: 35, height: 35)
                                            .foregroundColor(.blue)
                                    }
                                    
                                    Button(action: {
                                        selection = selection.add(component: .day, value: j - selection.day)
                                        if components.count == 1 {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                                isShowing = false
                                            }
                                        }
                                    }) {
                                        Text("\(j)")
                                            .foregroundColor(j == selection.day ? .white : .primary)
                                            .fontWeight(j == selection.day ? .bold : .regular)
                                            .frame(width: 30, height: 30)
                                    }
                                    
                                }
                                .frame(width: 30, height: 30)
                            }
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(20)
                .transition(.scale)
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0.1))
    }
}

struct MonthDayPickerView_Previews: PreviewProvider {
    static var previews: some View {
        CustomDatePickerView(selection: .constant(Date()), isShowing: .constant(true), components: [.month, .day])
    }
}
