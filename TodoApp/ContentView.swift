//
//  ContentView.swift
//  TodoApp
//
//  Created by rehanchrl on 23/04/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var todoList = TodoList()
    
    @State private var selectedItem: String = ""
    @State private var selectedCategory: Category = Category(name: "Design", color: .red)
    @State private var showingCategoriesDropdown = false
    @State private var showTextFieldSuggestions: Bool = false
    @State private var showCategorySuggestions: Bool = false
    @State private var highlightedIndex: Int?
    @FocusState private var focus: FocusableField?
    @State private var lastFocused: FocusableField?
    

    var body: some View {
        NavigationView {
            VStack {
                Button(action: { 
                    showingCategoriesDropdown.toggle()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                        lastFocused = focus
                        focus = .categoryDropdown
                    }
                }) {
                    HStack {
                        Text(selectedCategory.name)
                            .padding(4)
                            .background(selectedCategory.color.opacity(0.2))
                            .cornerRadius(4)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)
                .overlay(alignment: .topTrailing) {
                    if showingCategoriesDropdown {
                        CategoriesDropdown(selectedCategory: $selectedCategory, showingDropdown: $showingCategoriesDropdown, textFieldValue: $selectedItem, lastFocused: $lastFocused, isFocused: _focus)
                        .offset(y: 45)
                    }
                }.zIndex(3)
                
                TextField("What's your focus?", text: $selectedItem)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .focused($focus, equals: .textField)
                    .onChange(of: selectedItem) { oldValue, newValue in
                        if newValue.hasSuffix("@") {
                            showTextFieldSuggestions = false
                            showCategorySuggestions = true
                        } else if newValue.isEmpty {
                            showTextFieldSuggestions = false
                            showCategorySuggestions = false
                        } else {
                            showTextFieldSuggestions = true
                            showCategorySuggestions = false
                        }
                    }
                    .overlay(alignment: .topTrailing) {
                        if showTextFieldSuggestions {
                            SuggestionsDropdown(selectedSuggestion: $selectedItem, showingSuggestion: $showTextFieldSuggestions, textFieldValue: $selectedItem, lastFocused: $lastFocused, isFocusedSuggestions: _focus)
                                
                                .offset(y: 45)
                        }
                        if showCategorySuggestions {
                            CategoriesDropdown(selectedCategory: $selectedCategory, showingDropdown: $showCategorySuggestions, textFieldValue: $selectedItem, lastFocused: $lastFocused, isFocused: _focus)
                                .offset(y: 65)
                        }
                    }.zIndex(2)
                    .onSubmit {
                        self.addItem()
                    }
                    
                
                List {
                    ForEach(todoList.todoItems.indices, id: \.self) { index in
                        let item = todoList.todoItems[index]
                        HStack {
                            VStack(alignment: .leading) {
                                Text(item.text)
                                    .font(.headline)
                                HStack {
                                    Circle()
                                        .fill(item.category.color)
                                        .frame(width: 8, height: 8)
                                    Text(item.category.name)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                            Spacer()
                            Button(action: {
                                todoList.markAsDone(at: index)
                            }) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.green)
                            }
                        }
                        .listRowBackground(highlightedIndex == index ? Color.accentColor.opacity(0.2) : Color.clear)
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { todoList.deleteItem(at: $0) }
                    }
                }
                .listStyle(PlainListStyle())
                .focusable()
                .focused($focus, equals: .todoList)
                .onKeyPress(.upArrow) {
                    highlightPreviousItem()
                    return .handled
                }
                .onKeyPress(.downArrow) {
                    highlightNextItem()
                    return .handled
                }
                .onKeyPress(.return) {
                    if let index = highlightedIndex {
                        todoList.markAsDone(at: index)
                        highlightedIndex = nil
                    }
                    return .handled
                }
                
                if todoList.todoItems.isEmpty {
                    Text("List is empty")
                        .foregroundColor(.gray)
                        .padding()
                }
                
                if !todoList.doneItems.isEmpty {
                    Section(header: Text("Done")) {
                        List {
                            ForEach(todoList.doneItems.indices, id: \.self) { index in
                                let item = todoList.doneItems[index]
                                HStack {
                                    Text(item.text)
                                        .strikethrough()
                                        .foregroundColor(.gray)
                                    Spacer()
                                    Text(item.category.name)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    Button(action: {
                                        todoList.deleteDoneItem(at: index)
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                        }
                        .listStyle(PlainListStyle())
                    }
                }
                
            }
            .navigationBarTitle("My List")
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                    focus = .todoList
                }
            }
        }
        
    }

    

    private func addItem() {
        guard !selectedItem.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        let item = TodoItem(text: selectedItem, category: selectedCategory)
        todoList.addItem(item)
        selectedItem = ""
        focus = .todoList
    }
    
    private func highlightPreviousItem() {
            if let currentIndex = highlightedIndex {
                highlightedIndex = currentIndex == 0 ? todoList.todoItems.count - 1 : currentIndex - 1
            } else {
                highlightedIndex = todoList.todoItems.count - 1
            }
        }
        
        private func highlightNextItem() {
            if let currentIndex = highlightedIndex {
                highlightedIndex = currentIndex == todoList.todoItems.count - 1 ? 0 : currentIndex + 1
            } else {
                highlightedIndex = 0
            }
        }
}

#Preview {
    ContentView()
}
