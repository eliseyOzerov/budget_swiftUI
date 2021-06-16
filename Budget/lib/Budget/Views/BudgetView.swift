//
//  FundViewEdit.swift
//  Budget
//
//  Created by Elisey Ozerov on 18/02/2021.
//

import SwiftUI
import RealmSwift

enum Weekday: String, Titled, CaseIterable, Identifiable, RealmOptionalType {
    
    case monday = "Monday"
    case tuesday = "Tuesday"
    case wednesday = "Wednesday"
    case thursday = "Thursday"
    case friday = "Friday"
    case saturday = "Saturday"
    case sunday = "Sunday"
    
    var title: String { self.rawValue }
    
    var id: Self { self }
    var index: Int { Self.allCases.firstIndex(of: self)! }
}

struct BudgetView: View {
    @Environment(\.presentationMode) var presentation
    
    @ObservedObject var model = BudgetsViewModel.shared
    @ObservedObject var savingsModel = SavingsViewModel.shared
    
    var id: ObjectId?
    @State var title: String = ""
    @State var available: Double
    @State var budgetString: String = ""
    @State var showUnavailableError = false
    @State var enableResets = false
    @State var resetPeriod: ResetPeriod = .monthly
    @State var weekday: Weekday = Weekday.allCases[Date().weekday]
    @State var day: Int = Date().day
    @State var month: Int = Date().month
    @State var shouldAutosave = false
    @State var autosaveTo: Fund?
    
    @State var showMonthPicker = false
    @State var showResetPeriodPicker = false
    @State var showWeekdayPicker = false
    @State var showSavingsFundPicker = false
    
    init(model: BudgetsViewModel, available: Double) {
        self.model = model
        self._available = State(initialValue: available)
        if let budget = model.editedBudget {
            self.id = budget.id
            self._title = State(initialValue: budget.title)
            self._available = State(initialValue: available + budget.budget)
            self._budgetString = State(initialValue: budget.budget.toCurrencyString())
            self._enableResets = State(initialValue: budget.enableResets)
            self._resetPeriod = State(initialValue: budget.resetPeriod)
            self._weekday = State(initialValue: budget.weekdayResetSetting ?? .monday)
            self._day = State(initialValue: budget.dayResetSetting ?? Date().day)
            self._month = State(initialValue: budget.monthResetSetting ?? Date().month)
            self._shouldAutosave = State(initialValue: budget.shouldAutosave)
            self._autosaveTo = State(initialValue: budget.autosaveTo)
        }
    }
    
    var resetDateBinding: Binding<Date> {
        Binding(
            get: {
                return Date(from: DateComponents(year: Date().year, month: month, day: day))
            },
            set: { date in
                day = date.day
                month = date.month
            }
        )
    }
    
    var components: [DatePickerComponent] {
        switch resetPeriod {
        case .weekly: return [.weekday]
        case .monthly: return [.day]
        case .yearly: return [.month, .day]
        }
    }
    
    var budgetBiding: Binding<String> {
        Binding(
            get: {
                return budgetString
            },
            set: {
                update(base: &budgetString, new: $0)
                showUnavailableError = budgetString.toDouble() > available
            }
        )
    }
    
    var fundBinding: Binding<Fund> {
        Binding(
            get: { autosaveTo ?? savingsModel.funds.first! },
            set: {
                autosaveTo = $0
            }
        )
    }
    
    var canSaveOrAdd: Bool {
        return !title.isEmpty && !budgetString.isEmpty
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    HStack {
                        Button(action: {
                            presentation.wrappedValue.dismiss()
                        }, label: {
                            Text("Cancel")
                        })
                        Spacer()
                        Text("\(model.editedBudget != nil ? "Edit" : "New") budget")
                            .font(.headline)
                        Spacer()
                        Button(action: {
                            model.addModifyBudget(
                                Budget(
                                    id: id ?? ObjectId.generate(),
                                    title: title,
                                    budget: budgetString.toDouble(),
                                    enableResets: enableResets,
                                    resetPeriod: resetPeriod,
                                    weekday: weekday,
                                    day: day,
                                    month: month,
                                    shouldAutosave: shouldAutosave,
                                    autosaveTo: autosaveTo // fundBinding not good - force unwrapping
                                )
                            )
                            model.editedBudget = nil
                            presentation.wrappedValue.dismiss()
                        }, label: {
                            Text("\(model.editedBudget != nil ? "Save" : "Add")")
                        })
                        .disabled(!canSaveOrAdd)
                    }
                    .padding()
                    
                    VStack(alignment: .leading) {
                        Text("TITLE")
                            .font(.footnote)
                            .foregroundColor(.gray)
                        TextField("Type something", text: $title)
                            .padding(.horizontal)
                            .padding(.vertical, 10)
                            .background(Color("formRow"))
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading) {
                        HStack(alignment: .firstTextBaseline, spacing: 5) {
                            Text("BUDGET")
                                .font(.footnote)
                                .foregroundColor(.gray)
                                .padding(.trailing, 10)
                            Text("\(available.toCurrencyString())")
                                .font(.footnote)
                                .fontWeight(.bold)
                            Text("available")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        VStack(alignment: .leading) {
                            TextField(0.0.toCurrencyString(), text: budgetBiding)
                                .keyboardType(.numberPad)
                            if showUnavailableError {
                                Text("Not enough funds")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        .background(Color("formRow"))
                        .cornerRadius(10)
                        .animation(.easeInOut(duration: 0.3))
                    }
                    .padding()
                    
                    Toggle(isOn: $enableResets, label: {
                        Text("Reset")
                    })
                    .padding(.vertical, 6)
                    .padding(.horizontal)
                    .background(Color("formRow"))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    if enableResets {
                        
                        ResetsView(
                            resetPeriod: $resetPeriod,
                            showResetPeriodPicker: $showResetPeriodPicker,
                            weekday: $weekday,
                            day: $day,
                            month: $month,
                            showWeekdayPicker: $showWeekdayPicker,
                            showMonthPicker: $showMonthPicker
                        )
                        
                        if !savingsModel.funds.isEmpty {
                            AutosaveView(
                                shouldAutosave: $shouldAutosave,
                                showSavingsFundPicker: $showSavingsFundPicker,
                                fundBinding: fundBinding,
                                savingsModel: savingsModel
                            )
                        } else {
                            Text("Add a savings goal to enable autosaving.")
                                .font(.headline)
                                .foregroundColor(.gray)
                                .padding(.top, 16)
                        }
                    }

                    Spacer()
                }
                
                CustomDatePickerView(selection: resetDateBinding, isShowing: $showMonthPicker, components: components)
                
            }
            .background(Color(UIColor.systemGroupedBackground))
            .edgesIgnoringSafeArea(.bottom)
            .navigationTitle("")
            .navigationBarHidden(true)
            .animation(.easeInOut(duration: 0.3))
            .onTapGesture {
                self.hideKeyboard()
            }
        }
    }
}

struct ResetsView: View {
    @Binding var resetPeriod: ResetPeriod
    @Binding var showResetPeriodPicker: Bool
    @Binding var weekday: Weekday
    @Binding var day: Int
    @Binding var month: Int
    @Binding var showWeekdayPicker: Bool
    @Binding var showMonthPicker: Bool
    
    var monthDayEnding: String {
        switch day {
            case 1,21,31: return "st"
            case 2,22: return "nd"
            case 3,23: return "rd"
            default: return "th"
        }
    }
    
    func nextReset(resetPeriod: ResetPeriod) -> Date {
        var result: Date?
        let today = Date().add(component: .day, value: 1)

        switch resetPeriod {
        case .weekly:
            let todaysWeekdayIndex = today.weekday
            if weekday.index > todaysWeekdayIndex {
                result = today.add(component: .day, value: weekday.index - todaysWeekdayIndex)
            } else if weekday.index < todaysWeekdayIndex {
                result = today.add(component: .day, value: 7 - (todaysWeekdayIndex - weekday.index))
            }
        case .monthly:
            let currentMonthWithDaySetting = Date(from: DateComponents(year: today.year, month: today.month, day: day))
            result = currentMonthWithDaySetting.add(component: .month, value: today.startOfDay() <= currentMonthWithDaySetting.startOfDay() ? 0 : 1)
        case .yearly:
            let currentYearWithMonthSetting = Date(from: DateComponents(year: today.year, month: month, day: day))
            result = currentYearWithMonthSetting.add(component: .year, value: today.startOfDay() <= currentYearWithMonthSetting.startOfDay() ? 0 : 1)
        }
        
        return result ?? today
    }
    
    var dateFromSettings: Date {
        return Date(from: DateComponents(year: Date().year, month: month, day: day))
    }
    
    
    var resetOn: AnyView {
        switch resetPeriod {
        case .weekly:
            return AnyView(
                NavigationLink(
                    destination: PickerOptionsView(
                        options: Weekday.allCases,
                        selection: $weekday
                    ).navigationTitle("").navigationBarTitleDisplayMode(.inline),
                    isActive: $showWeekdayPicker){
                    HStack {
                        Text("On")
                        Spacer()
                        Text(weekday.title)
                            .fontWeight(.medium)
                            .foregroundColor(Color(UIColor.systemGray2))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Color(UIColor.systemGray4))
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal)
                .padding(.vertical, 10)
            )
        case .monthly:
            return AnyView(
                HStack {
                    Text("On")
                    Spacer()
                    Button(action: {
                        showMonthPicker = true
                    }){
                        Text("\(day)\(monthDayEnding)")
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(5)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 6)
            )
        case .yearly:
            return AnyView(
                HStack {
                    Text("On")
                    Spacer()
                    Button(action: {
                        showMonthPicker = true
                    }){
                        Text("\(dateFromSettings.format(format: "MMM dd"))\(monthDayEnding)")
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(5)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 6)
            )
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            NavigationLink(
                destination: PickerOptionsView(
                    options: ResetPeriod.values,
                    selection: $resetPeriod
                ).navigationTitle("").navigationBarTitleDisplayMode(.inline),
                isActive: $showResetPeriodPicker){
                HStack {
                    Text("Period")
                    Spacer()
                    Text(resetPeriod.title)
                        .fontWeight(.medium)
                        .foregroundColor(Color(UIColor.systemGray2))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color(UIColor.systemGray4))
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal)
            .padding(.vertical, 10)
            
            Rectangle()
                .frame(height:0.3)
                .foregroundColor(Color(UIColor.separator))
                .padding(.leading)
            
            resetOn
        }
        .background(Color("formRow"))
        .cornerRadius(10)
        .padding(.horizontal)
        .padding(.top)

        HStack {
            Text("The amount you spend until the reset will be subtracted from the budget.")
                .font(.caption)
                .foregroundColor(.gray)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.horizontal)
        
        HStack {
            Text("Next reset on:")
            Text(nextReset(resetPeriod: resetPeriod).format(format: "MMMM d yyyy"))
                .fontWeight(.bold)
            Spacer()
        }
        .font(.callout)
        .padding()
        .padding(.horizontal)
    }
}

struct AutosaveView: View {
    
    @Binding var shouldAutosave: Bool
    @Binding var showSavingsFundPicker: Bool
    var fundBinding: Binding<Fund>
    var savingsModel: SavingsViewModel
    
    var body: some View {
        VStack {
            VStack(spacing: 0) {
                Toggle(isOn: $shouldAutosave, label: {
                    Text("Auto-save")
                })
                .padding(.vertical, 6)
                .padding(.horizontal)
                
                if shouldAutosave {
                    Rectangle()
                        .frame(height:0.3)
                        .foregroundColor(Color(UIColor.separator))
                        .padding(.leading)
                    
                    NavigationLink(
                        destination: PickerOptionsView(
                            options: savingsModel.funds,
                            selection: fundBinding
                        ).navigationTitle("").navigationBarTitleDisplayMode(.inline),
                        isActive: $showSavingsFundPicker){
                        HStack {
                            Text("To")
                            Spacer()
                            Text(fundBinding.wrappedValue.title)
                                .fontWeight(.medium)
                                .foregroundColor(Color(UIColor.systemGray2))
                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(Color(UIColor.systemGray4))
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                }
            }
            .background(Color("formRow"))
            .cornerRadius(10)
            .padding(.horizontal)
            .padding(.top)
            
            HStack {
                Text("What's left after the reset will be transferred towards the selected savings goal.")
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.horizontal)
        }
        .animation(.easeInOut(duration: 0.3))
    }
}

struct AddBudgetView_Previews: PreviewProvider {
    static var previews: some View {
        BudgetView(model: BudgetsViewModel.shared, available: 200)
    }
}
