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
        private(set) var isLoadingLocation: Bool = false
        var position: MapCameraPosition = .userLocation(followsHeading: true, fallback: .automatic)
        var locationAuthorized: Bool? = nil
        var showAlert = false
        var showSheet = false
        private(set) var lookAroundScene: MKLookAroundScene?
        private(set) var route: MKRoute?
        var searchSuggestions: [SearchSuggestion] = [SearchSuggestion]()
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
            
            let status = locationManager.authorizationStatus
            locationAuthorized = status == .authorizedWhenInUse || status == .authorizedAlways
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
                updateAuthorizationStatus(true)
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .denied, .restricted:
                updateAuthorizationStatus(false)
            default:
                updateAuthorizationStatus(false)
            }
        }
        
        func updateAuthorizationStatus(_ isAuthorized: Bool) {
            DispatchQueue.main.async {
                self.locationAuthorized = isAuthorized
            }
            
        }
        
        func search(for query: String, resultType:MKLocalSearch.ResultType = .pointOfInterest ) {
            self.isLoadingLocation = true
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
                    self.searchSuggestions = result.compactMap{self.formatAddress(from: $0)}
                    self.isLoadingLocation = false
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
        func formatAddress(from mapItem: MKMapItem) -> SearchSuggestion {
            //placemark: MKPlacemark
            let addressParts = [
                mapItem.placemark.subThoroughfare,  // House/building number
                mapItem.placemark.thoroughfare,     // Street name
                mapItem.placemark.locality,         // City
                mapItem.placemark.administrativeArea, // State/Region
                mapItem.placemark.postalCode,       // ZIP code
                mapItem.placemark.country           // Country
            ]
            let  formattedAddress = addressParts.compactMap { $0 }.joined(separator: ", ")
            return SearchSuggestion(id: mapItem.placemark.region?.identifier ?? "", address: formattedAddress)
        }
    }
}


