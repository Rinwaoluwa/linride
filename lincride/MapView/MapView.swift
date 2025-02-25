//
//  MapView.swift
//  lincride
//
//  Created by Adeoluwa on 24/02/2025.
//

import SwiftUI
import MapKit
import CoreLocation

struct MapView: View {
    @State private var viewModel = ViewModel()
    @State var showAlert = false
    @State var showSheet = false
    
    var body: some View {
        ZStack {
            Map(
                position: $viewModel.position, selection: $viewModel.selectedLocation
            ) {
                UserAnnotation()
                ForEach(viewModel.searchResults, id: \.self) { item in
                    Marker(item: item)
                }
            }
            .onChange(of: viewModel.searchResults, { _, newValue in
                viewModel.updateMap(position: .automatic)
            })
            .mapStyle(.standard(elevation: .realistic))
            .mapControls {
                MapUserLocationButton()
                MapCompass()
                MapScaleView()
            }.onMapCameraChange(frequency: .continuous, { context in
                viewModel.updateRegion(to: context.region)
            }).overlay(alignment: .topTrailing, content: {
                if let location = viewModel.selectedLocation {
                    LookAroundView(lookAroundScene: viewModel.lookAroundScene, selectedResult: location, route: viewModel.route)
                        .frame(height: 128)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding([.top, .horizontal])
                        .onAppear {
                            viewModel.getLookAroundScene()
                            
                        }
                        .onChange(of: viewModel.selectedLocation) {
                            viewModel.getLookAroundScene()
                        }
                }
            })
            .onAppear {
                viewModel.requestLocationPermission()
            }.onChange(of: viewModel.locationAuthorized, { oldValue, newValue in
                if !viewModel.locationAuthorized {
                    showAlert = true
                }
            })
            .alert("Location Permission Required", isPresented: $showAlert)  {
                Button("Open Settings") {
                    Utils().openAppSettings()
                }
            } message: {
                Text("Please grant location permission in settings to use this feature.")
            }
            .ignoresSafeArea(edges: .bottom)
            // Custom bottom sheet
            BottomSheet (showSheet: $showSheet){
                VStack(spacing:0) {
                    TextField("Search Location", text: $viewModel.searchQuery)
                        .padding()
                        .frame(height: 40)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .disabled(true)
                        .onTapGesture {
                            withAnimation {
                                viewModel.showSearchModal.toggle()
                            }
                        }
                    FavoritesView { favoriteItem in
                        viewModel.search(for: favoriteItem.value)
                        print("favoriteItem: \(favoriteItem)")
                    }
                }.padding(.horizontal)
                    .sheet(isPresented: $viewModel.showSearchModal) {
                        //DISMISS
                    } content: {
                        SearchView(viewModel: viewModel, searchText: $viewModel.searchQuery, suggestions: viewModel.recentSearches, onClear: {
                            //ON CLEAR
                            viewModel.searchQuery = ""
                        }, onCancel: {
                            viewModel.showSearchModal = false
                        }, onTapSuggestion: { suggestion in
                            viewModel.search(for: suggestion)
                            viewModel.showSearchModal = false
                            viewModel.searchQuery = suggestion
                        }
                        ).onChange(of: viewModel.searchQuery) { oldValue, newValue in
                            viewModel.search(for: newValue)
                        }.onSubmit {
                            viewModel.showSearchModal = false
                        }
                    }
            }
        }
    }
}

#Preview {
    MapView()
}
