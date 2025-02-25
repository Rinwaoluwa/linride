//
//  SearchView.swift
//  lincride
//
//  Created by Adeoluwa on 25/02/2025.
//

import SwiftUI
import MapKit

struct SearchView: View {
    var viewModel: MapView.ViewModel
    let searchText: Binding<String>
    let suggestions: [String]
    let onClear: () -> Void
    let onCancel: () -> Void
    let onTapSuggestion: ( String) -> Void
    
    
    
    @State private var isEditing = false
    @FocusState private var isFocused: Bool
    
    
    
    var body: some View {
        VStack {
            // Search bar
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass") // Search icon
                        .foregroundColor(.gray)
                    
                    TextField("Search Maps", text: searchText)
                        .focused($isFocused)
                        .autocorrectionDisabled(true)
                        .onChange(of: isFocused) { oldValue, newValue in
                            withAnimation {
                                isEditing = newValue
                            }
                        }
                    Image(systemName: "multiply.circle") // clear icon
                        .foregroundColor(.gray)
                        .onTapGesture {
                            onClear()
                        }
                }
                .padding(10)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                
                if isFocused {
                    Button("Cancel") {
                        withAnimation {
                            isFocused   = false
                            searchText.wrappedValue = ""
                            onCancel()
                        }
                    }
                    .foregroundColor(.blue)
                    .transition(.move(edge: .trailing))
                }
            }
            .padding()
            // Suggestion searches
            if isEditing {
                if suggestions.isEmpty && !searchText.wrappedValue.isEmpty {
                    VStack(spacing: 10) {
                        Spacer()
                        Image(systemName: "multiply.circle")
                            .font(.system(size: 30))
                            .foregroundColor(.red)
                            
                        Text("No location found")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Spacer()
                        
                    }
                } else {
                    
                    List {
                        Section(header: Text(suggestions.isEmpty ? "" : "Suggestions").foregroundColor(.gray)) {
                            ForEach(suggestions, id: \.hashValue) { suggestion in
                                
                                HStack {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundColor(.gray)
                                    Text(suggestion).onTapGesture {
                                        onTapSuggestion(suggestion)
                                    }
                                    Spacer()
                                }
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            
            Spacer()
        }
        .onAppear {
            
            withAnimation {
                isFocused = true
            }
        }
    }
}

//#Preview {
//    @State var search = ""
//    SearchView(searchText: $search, suggestions: [String]()) {
//    } onCancel: {
//        
//    } onTapSuggestion: { suggestion in
//        print("SUGGESTION: \(suggestion)")
//    }
//    
//}
