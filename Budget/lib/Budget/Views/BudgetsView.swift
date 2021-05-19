//
//  HomeView.swift
//  Budget
//
//  Created by Elisey Ozerov on 15/11/2020.
//  Copyright © 2020 Elisey Ozerov. All rights reserved.
//

import SwiftUI
import RealmSwift

class BudgetsViewModel: ObservableObject {
    @Published var budgets: [Budget] = []
    
    private var results: Results<BudgetDB>?
    private var token: NotificationToken?
    
    init() {
        let realm = try! Realm()
        results = realm.objects(BudgetDB.self)
        token = results?.observe { [self] changes in
            switch changes {
            case .initial(let results):
                budgets = results.map({Budget(from: $0)})
            case .error(let error):
                debugPrint(error)
            case .update(_,let deletions,let insertions,let modifications):
                for id in deletions {
                    deleteBudgetOnUpdate(at: id)
                }
                for id in insertions {
                    addBudgetOnUpdate(at: id)
                }
                for id in modifications {
                    modifyBudgetOnUpdate(at: id)
                }
            }
        }
    }
    
    func addModifyBudget(_ budget: Budget) {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(BudgetDB(from: budget), update: .modified)
            }
        } catch {
            debugPrint(error)
        }
    }
    
    func deleteBudget(_ fnd: Budget) {
        do {
            let realm = try Realm()
            try realm.write {
                let obj = results?.filter({$0.id == fnd.id})
                realm.delete(obj!)
            }
        } catch {
            debugPrint(error)
        }
    }
    
    private func addBudgetOnUpdate(at: Int) {
        budgets.insert(Budget(from: results![at]), at: at)
    }
    
    private func modifyBudgetOnUpdate(at: Int) {
         budgets[at] = Budget(from: results![at])
    }
    
    private func deleteBudgetOnUpdate(at: Int) {
        budgets.remove(at: at)
    }
    
}

struct BudgetsView: View {
    @Environment(\.presentationMode) var presentation
    
    @ObservedObject var model = BudgetsViewModel()
    @State var sheetItem: SavingsSheetItem?
    
    func sheetView(_ sheetItem: SavingsSheetItem) -> AnyView {
        switch sheetItem {
        case .add: return AnyView(
            AddFundView(model: model)
        )
        case .edit(let fund): return AnyView(
            FundViewAction(
                model: model,
                fund: fund
            )
        )
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                List {
                    ForEach(model.funds) { fund in
                        Button(action: {sheetItem = .edit(fund)}, label: {
                            FundCardView(fund: fund, geometry: geometry)
                        })
                        .buttonStyle(PlainButtonStyle())
                    }
                    .onDelete { set in
                        model.deleteFund(model.funds[set.first!])
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .navigationTitle("Savings")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {sheetItem = .add}, label: {
                            HStack(spacing: 5) {
                                Text("Add goal")
                                Image(systemName: "plus")
                            }
                        })
                    }
                }
            }
            .sheet(item: $sheetItem) { sheetView($0) }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        BudgetsView()
    }
}
