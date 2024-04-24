//
//  TodoModel.swift
//  TodoApp
//
//  Created by rehanchrl on 24/04/24.
//

import SwiftUI

class TodoList: ObservableObject {
    @Published var todoItems: [TodoItem] = []
    @Published var doneItems: [TodoItem] = []
    
    init() {
        loadItems()
    }
    
    private func loadItems() {
        if let data = UserDefaults.standard.data(forKey: "todoItems"),
           let decodedItems = try? JSONDecoder().decode([TodoItem].self, from: data) {
            todoItems = decodedItems
        }
        
        if let data = UserDefaults.standard.data(forKey: "doneItems"),
           let decodedItems = try? JSONDecoder().decode([TodoItem].self, from: data) {
            doneItems = decodedItems
        }
    }
    
    func saveItems() {
        if let encodedData = try? JSONEncoder().encode(todoItems) {
            UserDefaults.standard.set(encodedData, forKey: "todoItems")
        }
        
        if let encodedData = try? JSONEncoder().encode(doneItems) {
            UserDefaults.standard.set(encodedData, forKey: "doneItems")
        }
    }
    
    func addItem(_ item: TodoItem) {
        todoItems.append(item)
        saveItems()
    }
    
    func deleteItem(at index: Int) {
        todoItems.remove(at: index)
        saveItems()
    }
    
    func markAsDone(at index: Int) {
        let item = todoItems[index]
        todoItems.remove(at: index)
        doneItems.append(item)
        saveItems()
    }
    
    func deleteDoneItem(at index: Int) {
        doneItems.remove(at: index)
        saveItems()
    }
}

struct TodoItem: Codable, Hashable {
    let text: String
    let category: Category
}

struct Category: Codable, Hashable {
    let name: String
    let color: Color
}
