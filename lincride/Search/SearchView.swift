import SwiftUI
import MapKit

struct SearchView: View {
    let viewModel: SearchViewViewModel
    @ObservedObject var mapScreenViewModel: MapView.ViewModel
    @FocusState private var isFocused: Bool
    
    @Environment(\.managedObjectContext) var context
    
    var body: some View {
        VStack {
            VStack {
                // Search bar
                HStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search Location", text: $mapScreenViewModel.searchQuery)
                            .focused($isFocused)
                            .autocorrectionDisabled(true)
                            .onChange(of: isFocused) { _, newValue in
                                withAnimation {
                                    viewModel.isEditing = newValue
                                }
                            }
                        
                        Image(systemName: "multiply.circle")
                            .foregroundColor(.gray)
                            .onTapGesture {
                                mapScreenViewModel.searchQuery = ""
                            }
                    }
                    .padding(10)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    
                    if isFocused {
                        Button("Cancel") {
                            withAnimation {
                                isFocused = false
                                mapScreenViewModel.searchQuery = ""
                                mapScreenViewModel.showSearchModal = false
                            }
                        }
                        .foregroundColor(.blue)
                        .transition(.move(edge: .trailing))
                    }
                }
                .padding()
                
                // Suggestions + results
                if viewModel.isEditing {
                    if mapScreenViewModel.isLoadingLocation {
                        LoadingView()
                    }
                    
                    if mapScreenViewModel.showError, let errorModel = mapScreenViewModel.errorPageModel {
                        ErrorView(model: errorModel)
                            .padding(.top, 40)
                    } else if mapScreenViewModel.searchSuggestions.isEmpty && !mapScreenViewModel.searchQuery.isEmpty && !mapScreenViewModel.isLoadingLocation {
                        VStack(spacing: 10) {
                            Spacer()
                            Image(systemName: "mappin.slash")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            
                            Text("No Results Found")
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            Text("Try searching for a different location")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                    } else {
                        List {
                            Section(header: Text(mapScreenViewModel.searchSuggestions.isEmpty ? "" : "Suggestions").foregroundColor(.gray)) {
                                ForEach(mapScreenViewModel.searchSuggestions, id: \.id) { suggestion in
                                    HStack {
                                        Image(systemName: "magnifyingglass")
                                            .foregroundColor(.gray)
                                        Text(suggestion.address).onTapGesture {
                                            mapScreenViewModel.search(for: suggestion.address)
                                            mapScreenViewModel.showSearchModal = false
                                            mapScreenViewModel.searchQuery = suggestion.address
                                        }
                                        Spacer()
                                        Image(systemName: suggestion.isSelected ? "bookmark.fill" : "bookmark")
                                            .foregroundColor(.gray)
                                            .onTapGesture {
                                                if let index = mapScreenViewModel.searchSuggestions.firstIndex(where: { $0.id == suggestion.id }) {
                                                    if !mapScreenViewModel.searchSuggestions[index].isSelected {
                                                        viewModel.savedSuggestedLocation(mapScreenViewModel.searchSuggestions[index])
                                                    }
                                                    mapScreenViewModel.searchSuggestions[index].isSelected.toggle()
                                                }
                                            }
                                        
                                        Spacer().frame(width: 10)
                                    }
                                }
                            }
                        }
                        .listStyle(PlainListStyle())
                    }
                }
                
                Spacer()
            }
            
        }.onDisappear {
            if !viewModel.savedLocations.isEmpty {
                viewModel.savedLocations.forEach { location in
                    let _ = SavedLocation(name: "Place", address: location.address, locationId: location.id, timestamp: Date(), context: context)
                    PersistenceController.shared.save()
                }
            }
        }
    }
}

