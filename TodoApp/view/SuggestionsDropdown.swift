//
//  SuggestionsDropdown.swift
//  TodoApp
//
//  Created by rehanchrl on 24/04/24.
//

import SwiftUI

import SwiftUI

struct SuggestionsDropdown: View {
    @Binding var selectedSuggestion: String
    @Binding var showingSuggestion: Bool
    @Binding var textFieldValue: String
    @Binding var lastFocused: FocusableField?
    
    @State private var highlightedSuggestionIndex: Int?
    @FocusState var isFocusedSuggestions: FocusableField?
    
    let textFieldSuggestions = [
        "Designer",
        "Developer",
        "Debussy",
        "Declarative",
        "Design",
        "Decremendum",
        "Designing interface"
    ]
    
    var body: some View {
        VStack {
            ForEach(Array(filteredTextFieldSuggestions.enumerated()), id: \.element) { index, suggestion in
                Button(action: {
                    selectedSuggestion = suggestion
                    showingSuggestion = false
                    textFieldValue = textFieldValue.replacingOccurrences(of: "@", with: " ")
                }) {
                    HStack {
                        Text(suggestion)
                            .foregroundStyle(.black)
                        Spacer()
                        
                    }
                    .padding(.horizontal)
                    .background(highlightedSuggestionIndex == index ? Color.accentColor.opacity(0.2) : Color.clear)
                    .id(index)
                }
            }
            
        }
        .focusable()
        .focused($isFocusedSuggestions, equals: .textSuggestion)
        .onKeyPress(.upArrow) {
            highlightPreviousSuggestion()
            return .handled
        }
        .onKeyPress(.downArrow) {
            highlightNextSuggestion()
            return .handled
        }
        .onKeyPress(.return) {
            selectHighlightedSuggestion()
            return .handled
        }
        .onDisappear {
            isFocusedSuggestions = lastFocused
        }
        .padding(.all, 12)
        .background(RoundedRectangle(cornerRadius: 6).foregroundColor(.white).shadow(radius: 2))
    
        
        var filteredTextFieldSuggestions: [String] {
            if textFieldValue.isEmpty {
                return textFieldSuggestions
            } else {
                return textFieldSuggestions.filter { $0.localizedCaseInsensitiveContains(textFieldValue) }
            }
        }
    }
    
    private func highlightPreviousSuggestion() {
        if let currentIndex = highlightedSuggestionIndex {
            let previousIndex = currentIndex - 1
            highlightedSuggestionIndex = previousIndex >= 0 ? previousIndex : textFieldSuggestions.count - 1
        } else {
            highlightedSuggestionIndex = textFieldSuggestions.count - 1
        }
    }
    
    private func highlightNextSuggestion() {
        if let currentIndex = highlightedSuggestionIndex {
            let nextIndex = currentIndex + 1
            highlightedSuggestionIndex = nextIndex < textFieldSuggestions.count ? nextIndex : 0
        } else {
            highlightedSuggestionIndex = 0
        }
    }
    
    private func selectHighlightedSuggestion() {
        if let index = highlightedSuggestionIndex {
            selectedSuggestion = textFieldSuggestions[index]
        }
        showingSuggestion = false
        textFieldValue = textFieldValue.replacingOccurrences(of: "@", with: " ")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
            isFocusedSuggestions = lastFocused
        }
    }
}
