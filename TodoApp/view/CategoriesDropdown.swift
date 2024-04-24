//
//  CategoriesDropdown.swift
//  TodoApp
//
//  Created by rehanchrl on 23/04/24.
//

import SwiftUI

struct CategoriesDropdown: View {
    @Binding var selectedCategory: Category
    @Binding var showingDropdown: Bool
    @Binding var textFieldValue: String
    @Binding var lastFocused: FocusableField?
    
    @State private var highlightedIndex: Int?
    @FocusState var isFocused: FocusableField?
    
    let categories: [Category] = [
        Category(name: "Design", color: .red),
        Category(name: "Programming", color: .yellow),
        Category(name: "Marketing", color: .green),
        Category(name: "Finance", color: .mint),
        Category(name: "Support", color: .blue),
        Category(name: "Sleep", color: .purple)
    ]
    
    var body: some View {
        VStack {
            ForEach(Array(categories.enumerated()), id: \.element) { index, category in
                Button(action: {
                    selectedCategory = category
                    highlightedIndex = index
                    showingDropdown = false
                    textFieldValue = textFieldValue.replacingOccurrences(of: "@", with: "")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                        isFocused = lastFocused
                    }
                }) {
                    HStack {
                        Circle()
                            .fill(category.color)
                            .frame(width: 8, height: 8)
                        Text(category.name)
                            .foregroundColor(selectedCategory == category ? .primary : .secondary)
                        Spacer()
                        if selectedCategory == category {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                    .padding(.horizontal)
                    .background(highlightedIndex == index ? Color.accentColor.opacity(0.2) : Color.clear)
                    .id(index)
                }
            }
            
        }
        .focusable()
        .focused($isFocused, equals: .categoryDropdown)
        .onKeyPress(.upArrow) {
            highlightPreviousCategory()
            return .handled
        }
        .onKeyPress(.downArrow) {
            highlightNextCategory()
            return .handled
        }
        .onKeyPress(.return) {
            selectHighlightedCategory()
            return .handled
        }
        .onDisappear {
            isFocused = lastFocused
        }
        .padding(.all, 12)
        .background(RoundedRectangle(cornerRadius: 6).foregroundColor(.white).shadow(radius: 2))
    
        
        
    }
    
    private func highlightPreviousCategory() {
        if let currentIndex = highlightedIndex {
            let previousIndex = currentIndex - 1
            highlightedIndex = previousIndex >= 0 ? previousIndex : categories.count - 1
        } else {
            highlightedIndex = categories.count - 1
        }
    }
    
    private func highlightNextCategory() {
        if let currentIndex = highlightedIndex {
            let nextIndex = currentIndex + 1
            highlightedIndex = nextIndex < categories.count ? nextIndex : 0
        } else {
            highlightedIndex = 0
        }
    }
    
    private func selectHighlightedCategory() {
        if let index = highlightedIndex {
            selectedCategory = categories[index]
        }
        showingDropdown = false
        textFieldValue = textFieldValue.replacingOccurrences(of: "@", with: " ")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
            isFocused = lastFocused
        }
    }
}
