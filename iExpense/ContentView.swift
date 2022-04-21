//
//  ContentView.swift
//  iExpense
//
//  Created by Alex Liou on 4/18/22.
//

import SwiftUI

struct ExpenseItem: Identifiable, Codable {
    var id = UUID()
    let name: String
    let type: String
    let amount: Double
    let currencyCode: String
}

class Expenses: ObservableObject {
    @Published var items = [ExpenseItem]() {
        didSet {
            if let encoded = try? JSONEncoder().encode(items) {
                UserDefaults.standard.set(encoded, forKey: "Items")
            }
        }
    }
    
    init() {
        if let savedItems = UserDefaults.standard.data(forKey: "Items") {
            if let decodedItems = try? JSONDecoder().decode([ExpenseItem].self, from: savedItems) {
                items = decodedItems
                return
            }
        }
        
        items = []
    }
    
    func getPersonal() -> [ExpenseItem] {
        var res = [ExpenseItem]()
        for i in items {
            if i.type == "Personal" {
                res.append(i)
            }
        }
        return res
    }
    
    func getBusiness() -> [ExpenseItem] {
        var res = [ExpenseItem]()
        for i in items {
            if i.type == "Business" {
                res.append(i)
            }
        }
        return res
    }
}

struct ContentView: View {
    @State private var showingAddExpense = false
    @StateObject var expenses = Expenses()
//    var businessExp = expenses.getBusiness()
      
    var body: some View {
        NavigationView {
            List {
                Section {
                    let personalExp = expenses.getPersonal()

                    ForEach(personalExp) { item in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(item.name)
                                    .font(.headline)
                                Text(item.type)
                            }
                            Spacer()
                            Text(item.amount, format: .currency(code: item.currencyCode))
                                .bold()
                                .italic()
                                .foregroundColor(item.color)
                        }
                    }
                    .onDelete(perform: removeItems)
                } header: {
                    Text("Personal")
                        .font(.headline)
                }
                
                Section {
                    let businessExp = expenses.getBusiness()
                    ForEach(businessExp) { item in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(item.name)
                                    .font(.headline)
                                Text(item.type)
                            }
                            Spacer()
                            Text(item.amount, format: .currency(code: item.currencyCode))
                                .bold()
                                .italic()
                                .foregroundColor(item.color)
                        }
                    }
                    .onDelete(perform: removeItems)
                } header: {
                    Text("Business")
                        .font(.headline)
                }
                
            }
            .navigationTitle("iExpense")
            .toolbar {
                Button {
                    showingAddExpense = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddExpense) {
            AddView(expenses: expenses)
        }
    }
    
    func removeItems(at offsets: IndexSet) {
        expenses.items.remove(atOffsets: offsets)
    }
}

extension ExpenseItem {
    var color: Color {
        switch amount {
        case let amount where amount < 10:
            return Color.black
        case let amount where amount < 100:
            return Color.green
        default:
            return Color.red
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
