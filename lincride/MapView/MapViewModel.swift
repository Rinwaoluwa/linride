//
//  MapViewModel.swift
//  lincride
//
//  Created by Adeoluwa on 24/02/2025.
//

import Foundation
import CoreLocation
import SwiftUI
import MapKit

extension MapView {
    @Observable
    class ViewModel: NSObject, CLLocationManagerDelegate {
        var searchQuery = ""
        var selectedLocation: MKMapItem?
        var showSearchModal: Bool = false
        var position: MapCameraPosition = .userLocation(followsHeading: true, fallback: .automatic)
        var locationAuthorized: Bool = false
        var showAlert = false
        var showSheet = false
        private(set) var lookAroundScene: MKLookAroundScene?
        private(set) var route: MKRoute?
        private(set)  var recentSearches: [String] = [String]()
        private(set)  var searchResults: [MKMapItem] = [MKMapItem]()
        private(set) var region: MKCoordinateRegion?
        private let locationManager = CLLocationManager()
        private let lagosCoordinates = CLLocationCoordinate2D(latitude: 6.5244, longitude: 3.3792)
        
        override init() {
            super.init()
            locationManager.delegate = self
            let userLocation = locationManager.location?.coordinate ?? lagosCoordinates
            self.region =  MKCoordinateRegion(
                center: userLocation, span: MKCoordinateSpan(latitudeDelta: 0.1,longitudeDelta: 0.1)
            )
        }
        
        func requestLocationPermission() {
            locationManager.requestWhenInUseAuthorization()
        }
        
        func updateRegion(to cooridnates: MKCoordinateRegion) {
            region = cooridnates
        }
        func updateMap(position cameraPosition: MapCameraPosition) {
            position = cameraPosition
        }
        
        func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                self.locationAuthorized = true
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .denied, .restricted:
                self.locationAuthorized = false
            default:
                self.locationAuthorized = false
            }
        }
        
        
        func search(for query: String, resultType:MKLocalSearch.ResultType = .pointOfInterest ) {
            //TODO: ADD IS LOADING
            let userLocation = locationManager.location?.coordinate ?? lagosCoordinates
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = query
            request.resultTypes = resultType
            request.region = region ?? MKCoordinateRegion(
                center: userLocation,
                span: MKCoordinateSpan(latitudeDelta: 0.0125, longitudeDelta: 0.0125)
            )
            
            Task {
                let search = MKLocalSearch(request: request)
                let response = try? await search.start()
                DispatchQueue.main.async {
                    let result =  response?.mapItems ?? []
                    self.searchResults = result
                    self.recentSearches = result.compactMap{self.formatAddress(from: $0.placemark)}
                }
            }
        }
        
        func getLookAroundScene() {
            lookAroundScene = nil
            Task {
                guard let selectedLocation else { return }
                let request = MKLookAroundSceneRequest(mapItem: selectedLocation)
                lookAroundScene = try? await request.scene
            }
        }
        
        func getDirections() {
            route = nil
            guard let selectedLocation else { return }
            let userLocation = locationManager.location?.coordinate ?? lagosCoordinates
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: userLocation))
            request.destination = selectedLocation
            Task {
                let directions = MKDirections(request: request)
                let response = try? await directions.calculate()
                route = response?.routes.first
            }
        }
        func formatAddress(from placemark: MKPlacemark) -> String {
            let addressParts = [
                placemark.subThoroughfare,  // House/building number
                placemark.thoroughfare,     // Street name
                placemark.locality,         // City
                placemark.administrativeArea, // State/Region
                placemark.postalCode,       // ZIP code
                placemark.country           // Country
            ]
            
            return addressParts.compactMap { $0 }.joined(separator: ", ")
        }
    }
}


