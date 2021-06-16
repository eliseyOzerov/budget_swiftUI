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
    @Published var editedBudget: Budget?
    
    private var results: Results<BudgetDB>?
    private var token: NotificationToken?
    
    static var shared = BudgetsViewModel()
    private init() {
        let realm = try! Realm()
        results = realm.objects(BudgetDB.self)
        token = results?.observe { [self] changes in
            switch changes {
            case .initial(let results):
                budgets = results.map({ budgetDB in
                    var budget = Budget(from: budgetDB)
                    getAutosaveFund(&budget)
                    return budget
                })
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
    
    func resetBudget(_ budget: Budget, spent: Double, trxModel: TransactionsViewModel) {
        if shouldResetBudget(budget) {
            let leftovers = budget.budget - spent
            budget.lastReset = Date()
            
            if budget.shouldAutosave {
                if let fund = budget.autosaveTo {
                    trxModel.addModifyTx(
                        Transaction(
                            date: Date(),
                            total: leftovers,
                            type: .transfer,
                            category: "Transfer",
                            secondParty: "\(budget.title) -> \(fund.title)"
                        )
                    )
                    budget.budget = 0
                }
            } else {
                budget.budget = leftovers
            }
        }
    }
    
    func shouldResetBudget(_ budget: Budget) -> Bool {
        return budget.nextReset.startOfDay().equal(Date().startOfDay()) && !budget.lastReset.startOfDay().equal(Date().startOfDay())
    }
    
    func addModifyBudget(_ budget: Budget) {
        do {
            let realm = try Realm()
            try realm.write {
                let _budget = BudgetDB(from: budget)
                realm.add(_budget, update: .modified)
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
    
    func getAutosaveFund(_ fnd: inout Budget) {
        do {
            let realm = try Realm()
            if let key = fnd.autosaveTo {
                let fundDB = realm.object(ofType: FundDB.self, forPrimaryKey: key)
                if let fundDB = fundDB {
                    fnd.autosaveTo = Fund(from: fundDB)
                }
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

enum BudgetsSheetItem: Hashable, Identifiable {
    case add
    case edit(Budget)
    
    var id: Self { self }
}

struct BudgetsView: View {
    @Environment(\.presentationMode) var presentation
    
    @ObservedObject var transactionsModel = TransactionsViewModel.shared
    @ObservedObject var savingsModel = SavingsViewModel.shared
    @ObservedObject var model = BudgetsViewModel.shared
    
    @State var budget = Budget()
    
    @State var showSheet: Bool = false
    
    init() {
        resetAllBudgets(model.budgets)
    }
    
    public func resetAllBudgets(_ budgets: [Budget]) -> Void {
        budgets.forEach { budget in
            model.resetBudget(budget, spent: spent(budget: budget), trxModel: transactionsModel)
        }
    }
    
    func spent(budget: Budget) -> Double {
        return abs(transactionsModel.getTotal(category: budget.title, from: budget.lastReset, type: .expense))
    }
    
    var unallocated: Double {
        max(0, transactionsModel.balance -
            model.budgets.reduce(0) { $0 + max(0, $1.budget) }) // max used bcs if budget is negative, it can't count towards unallocated/available funds
    }
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                VStack(spacing: 0) {
                    if unallocated > 0 {
                        HStack(alignment: .firstTextBaseline) {
                            Text(unallocated.toCurrencyString())
                                .font(.footnote)
                                .fontWeight(.bold)
                            Text("unallocated")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.top)
                    }
                    if !model.budgets.isEmpty {
                        List {
                            ForEach(model.budgets) { budget in
                                Button(action: {
                                    self.budget = budget
                                    model.editedBudget = budget
                                    showSheet = true
                                }, label: {
                                    BudgetCardView(budget: budget, spent: spent(budget: budget))
                                })
                                .buttonStyle(PlainButtonStyle())
                            }
                            .onDelete { set in
                                model.deleteBudget(model.budgets[set.first!])
                            }
                        }
                        .listStyle(InsetGroupedListStyle())
                    } else {
                        ZStack {
                            Color(UIColor.systemGroupedBackground)
                            Text("Nothing to see here yet!")
                                .font(.headline)
                                .foregroundColor(.gray)
                                .fontWeight(.bold)
                        }
                        
                    }
                    
                }
                .animation(.easeInOut(duration: 0.15))
                .navigationBarTitle("Budget")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            model.editedBudget = nil
                            showSheet = true
                        }, label: {
                            HStack(spacing: 5) {
                                Text("Add")
                                Image(systemName: "plus")
                            }
                        })
                    }
                }
                .background(Color(UIColor.systemGroupedBackground))
            }
            .sheet(isPresented: $showSheet) {
                BudgetView(model: model, available: unallocated)
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        BudgetsView()
    }
}
