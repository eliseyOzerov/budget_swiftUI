//
//  ExpandableFAB.swift
//  Budget
//
//  Created by Elisey Ozerov on 10/11/2020.
//  Copyright © 2020 Elisey Ozerov. All rights reserved.
//

import SwiftUI

struct ExpandableFAB: View{
    
    @State private var open = false
    
    let buttonSize: CGFloat = 54
    let iconSize: CGFloat = 14
    let itemSpacing: CGFloat = 10
    var animation: Animation {
        Animation.spring(response: 0.3, dampingFraction: open ? 0.8 : 0.6, blendDuration: 0)
    }
    
    @State var items: Array<FABItem>
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ForEach(self.items.indices, id: \.self) { i in
                FABItemView(
                    i: i,
                    item: self.items[i],
                    size: self.buttonSize,
                    spacing: self.itemSpacing,
                    open: self.open
                )
            }

            Image(systemName: "plus")
                .font(.system(size: self.iconSize, weight: .semibold))
                .frame(width: self.buttonSize, height: self.buttonSize)
                .background(Color.blue)
                .clipShape(Circle())
                .foregroundColor(Color.white)
                .rotationEffect(.degrees(self.open ? 135 : 0))
                .animation(self.animation)
                .onTapGesture {
                    withAnimation(self.animation) {
                        self.open.toggle()
                    }
            }
            .padding(.horizontal, 20)
        }
    }
}

struct ExpandableFAB_Previews: PreviewProvider {
    static var previews: some View {
        ExpandableFAB(items: [
            FABItem(title: "Debt"){AnyView(EmptyView())},
            FABItem(title: "Expense"){AnyView(EmptyView())},
            FABItem(title: "Income"){AnyView(EmptyView())}
        ])
    }
}

struct FABItem: Identifiable {
    let id = UUID()
    
    var title: String
    var content: () -> AnyView
}

struct FABItemView: View, Identifiable{
    var id = UUID()
    
    var i: Int
    var item: FABItem
    var size: CGFloat
    var spacing: CGFloat
    var open: Bool = false
    
    @State private var expanded: Bool = false
    
    var initialOffset: CGFloat {
        size / 2 - 44 / 2
    }
    
    func offset(of index: Int) -> CGFloat {
        CGFloat(index) * 44 + spacing * CGFloat(index + 1) + size
    }
    var animation: Animation {
        Animation.spring(response: 0.3, dampingFraction: open ? 0.8 : 0.6, blendDuration: 0)
    }
    
    var bottomOffset: CGFloat {
        return self.open ? self.offset(of: self.i) : self.initialOffset
    }
    
    var trailingOffset: CGFloat {
        return self.open ? 20 : self.initialOffset + 20
    }
    
    func build() -> some View {
        Button(action: {self.expanded.toggle()}, label: {
            Text(self.item.title)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color.white)
                .opacity(self.open ? 1 : 0)
                .frame(maxWidth: self.open ? 92 : 44, maxHeight: 44)
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: self.size / 2))
                .padding(.bottom, self.bottomOffset)
                .padding(.trailing, self.trailingOffset)
                .sheet(isPresented: $expanded, content: {self.item.content()})
        })
        
    }
    
    var body: some View {
        self.build()
    }
}
