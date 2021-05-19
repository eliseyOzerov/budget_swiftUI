//
//  SavingsView.swift
//  Budget
//
//  Created by Elisey Ozerov on 17/02/2021.
//

import SwiftUI
import RealmSwift

enum SavingsSheetItem: Hashable, Identifiable {
    case add
    case edit(Fund)
    
    var id: Self { self }
}

class SavingsViewModel: ObservableObject {
    @Published var funds: [Fund] = []
    
    private var results: Results<FundDB>?
    private var token: NotificationToken?
    
    init() {
        let realm = try! Realm()
        results = realm.objects(FundDB.self)
        print("Realm is located at: \(realm.configuration.fileURL!)")
        token = results?.observe { [self] changes in
            switch changes {
            case .initial(let results):
                funds = results.map({Fund(from: $0)})
            case .error(let error):
                debugPrint(error)
            case .update(_,let deletions,let insertions,let modifications):
                for id in deletions {
                    deleteFundOnUpdate(at: id)
                }
                for id in insertions {
                    addFundOnUpdate(at: id)
                }
                for id in modifications {
                    modifyFundOnUpdate(at: id)
                }
            }
        }
    }
    
    func addModifyFund(_ fnd: Fund) {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(FundDB(from: fnd), update: .modified)
            }
        } catch {
            debugPrint(error)
        }
    }
    
    func deleteFund(_ fnd: Fund) {
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
    
    private func addFundOnUpdate(at: Int) {
        funds.insert(Fund(from: results![at]), at: at)
    }
    
    private func modifyFundOnUpdate(at: Int) {
        funds[at] = Fund(from: results![at])
    }
    
    private func deleteFundOnUpdate(at: Int) {
        funds.remove(at: at)
    }
    
}

struct SavingsView: View {
    @Environment(\.presentationMode) var presentation
    
    @EnvironmentObject var model: SavingsViewModel
    
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
                if !model.funds.isEmpty {
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
                } else {
                    ZStack {
                        Color(UIColor.systemGroupedBackground)
                        Text("Nothing to see here yet!")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .fontWeight(.bold)
                    }
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
            }
            .sheet(item: $sheetItem) { sheetView($0) }
        }
    }
}

struct SavingsView_Previews: PreviewProvider {
    static var previews: some View {
        SavingsView()
    }
}
