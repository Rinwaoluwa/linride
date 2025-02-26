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
    @FetchRequest(fetchRequest: SavedLocation.fetch(), animation: .bouncy) var locations
    @Environment(\.managedObjectContext) var context
    @Environment(\.scenePhase) var scenePhase
    
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
                if let _ = viewModel.selectedLocation {
                    LookAroundView(viewModel: viewModel)
                        .frame(height: 128)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding([.top, .horizontal])
                }
            }).onChange(of: viewModel.locationAuthorized, { oldValue, newValue in
                if let authorized = viewModel.locationAuthorized, !authorized {
                    viewModel.showAlert = true
                }
            })
            .onAppear {
                viewModel.requestLocationPermission()
            }
            .alert("Location Permission Required", isPresented: $viewModel.showAlert)  {
                Button("Open Settings") {
                    Utils().openAppSettings()
                }
            } message: {
                Text("Please grant location permission in settings to use LincRide.")
            }
            .ignoresSafeArea(edges: .bottom)
            // Custom bottom sheet
            BottomSheet (showSheet: $viewModel.showSheet){
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
                        viewModel.searchQuery = favoriteItem.value
                        viewModel.showSheet = false
                    }
                    Spacer().frame(height: 8)
                    // Horizontal LazyScrollView Section
                    List {
                        Section(header: Text(locations.isEmpty ? "" :"Saved Location").font(.headline)) {
                            ForEach(locations, content: { place in
                                
                                HStack {
                                    Image(systemName: "bookmark")
                                        .font(.system(size: 20))
                                        .foregroundColor(.accentColor)
                                        .padding(.leading, -5)
                                    Text(place.address)
                                }.listRowBackground(Color.clear)
                                    .onTapGesture {
                                        viewModel.search(for: place.address)
                                        viewModel.showSheet = false
                                        viewModel.searchQuery = place.address
                                    }
                            })
                            .onDelete { offsets in
                                if let index = offsets.first {
                                    let location = locations[index]
                                    SavedLocation.delete(location: location)
                                    PersistenceController.shared.save()
                                }
                            }
                        }
                    }.scrollContentBackground(.hidden)
                        .scrollIndicators(.hidden)
                    
                }.padding(.horizontal)
                    .sheet(isPresented: $viewModel.showSearchModal) {
                        //DISMISS
                    } content: {
                        SearchView(mapScreenViewModel: viewModel).onChange(of: viewModel.searchQuery) { oldValue, newValue in
                            viewModel.search(for: newValue)
                        }.onSubmit {
                            viewModel.showSearchModal = false
                        }
                    }
            }
        }.onChange(of: scenePhase) { oldValue, newValue in
            if newValue == .active  {
                if let authorized = viewModel.locationAuthorized, !authorized {
                    viewModel.showAlert = true
                }
            }
        }
    }
}

//#Preview {
//    MapView()
//}
