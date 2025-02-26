//
//  SearchBar.swift
//  lincride
//
//  Created by Adeoluwa on 25/02/2025.
//

import SwiftUI

struct SearchBar: View {
    @State private var searchText = ""
    @State private var isSearchActive = false
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Home Screen")
                    .font(.largeTitle)
                    .padding()
                
                // Custom search bar that navigates when tapped
                ZStack {
                    Button(action: {
                        isSearchActive = true
                    }) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            
                            Text("Search...")
                                .foregroundColor(.gray)
                            
                            Spacer()
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(.systemGray6))
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding()
                
                Spacer()
            }
            .navigationBarTitle("My App", displayMode: .large)
        }
    }
    
}

//#Preview {
//    SearchBar()
//}
