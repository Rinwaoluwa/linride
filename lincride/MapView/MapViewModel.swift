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
        
        // MARK: - Error Handling
        var currentError: Error?
        var showError: Bool = false
        var errorPageModel: ErrorPageModel?
        private let logger: Logger = DefaultLogger.shared
        
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
                logger.info("Location permission granted", category: .location)
                updateAuthorizationStatus(true)
            case .notDetermined:
                logger.debug("Location permission not determined", category: .location)
                locationManager.requestWhenInUseAuthorization()
            case .denied, .restricted:
                logger.warning("Location permission denied", category: .location)
                handleError(LocationError.permissionDenied, category: .location)
                updateAuthorizationStatus(false)
            default:
                logger.warning("Unknown location authorization status", category: .location)
                updateAuthorizationStatus(false)
            }
        }
        
        func updateAuthorizationStatus(_ isAuthorized: Bool) {
            DispatchQueue.main.async {
                self.locationAuthorized = isAuthorized
            }
            
        }
        
        func search(for query: String, resultType:MKLocalSearch.ResultType = .pointOfInterest ) {
            guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
                logger.warning("Empty search query", category: .search)
                handleError(SearchError.invalidQuery, category: .search)
                return
            }
            
            self.isLoadingLocation = true
            let userLocation = locationManager.location?.coordinate ?? lagosCoordinates
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = query
            request.resultTypes = resultType
            request.region = region ?? MKCoordinateRegion(
                center: userLocation,
                span: MKCoordinateSpan(latitudeDelta: 0.0125, longitudeDelta: 0.0125)
            )
            
            logger.info("Starting search for: \(query)", category: .search)
            
            Task {
                do {
                    let search = MKLocalSearch(request: request)
                    let response = try await search.start()
                    
                    DispatchQueue.main.async {
                        let result = response.mapItems
                        
                        // Check if results are empty
                        if result.isEmpty {
                            self.logger.info("No results found for: \(query)", category: .search)
                            self.handleError(SearchError.noResultsFound, category: .search)
                        } else {
                            self.logger.info("Found \(result.count) results", category: .search)
                            // Clear any previous errors
                            self.currentError = nil
                            self.showError = false
                        }
                        
                        self.searchResults = result
                        self.searchSuggestions = result.compactMap { self.formatAddress(from: $0) }
                        self.isLoadingLocation = false
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.isLoadingLocation = false
                        
                        if let urlError = error as? URLError,
                           urlError.code == .notConnectedToInternet {
                            self.logger.error("Network unavailable during search", category: .search)
                            self.handleError(SearchError.networkUnavailable, category: .search)
                        } else {
                            self.logger.logError(error: error, category: .search, file: #file, function: #function, line: #line)
                            self.handleError(SearchError.searchFailed(error.localizedDescription), category: .search)
                        }
                    }
                }
            }
        }
        
        func getLookAroundScene() {
            lookAroundScene = nil
            Task {
                guard let selectedLocation else {
                    logger.debug("No selected location for look around", category: .general)
                    return
                }
                
                do {
                    let request = MKLookAroundSceneRequest(mapItem: selectedLocation)
                    lookAroundScene = try await request.scene
                    logger.debug("Look around scene loaded", category: .general)
                } catch {
                    logger.warning("Failed to load look around scene: \(error.localizedDescription)", category: .general)
                }
            }
        }
        
        func getDirections() {
            route = nil
            guard let selectedLocation else {
                logger.debug("No selected location for directions", category: .general)
                return
            }
            
            let userLocation = locationManager.location?.coordinate ?? lagosCoordinates
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: userLocation))
            request.destination = selectedLocation
            
            Task {
                do {
                    let directions = MKDirections(request: request)
                    let response = try await directions.calculate()
                    route = response.routes.first
                    logger.info("Directions calculated successfully", category: .general)
                } catch {
                    logger.warning("Failed to calculate directions: \(error.localizedDescription)", category: .general)
                }
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
        
        // MARK: - Error Handling Methods 
        
        /// Handle errors with logging and user-facing error pages
        private func handleError(_ error: Error, category: LoggerCategory) {
            currentError = error
            showError = true
            
            // Create error page model for UI
            errorPageModel = ErrorPageFactory.makeErrorPage(
                from: error,
                retryAction: { [weak self] in
                    guard let self = self else { return }
                    self.clearError()
                    // Retry last search if applicable
                    if !self.searchQuery.isEmpty {
                        self.search(for: self.searchQuery)
                    }
                },
                secondaryAction: category == .location ? { [weak self] in
                    Utils().openAppSettings()
                    self?.clearError()
                } : nil
            )        
            logger.logError(error: error, category: category, file: #file, function: #function, line: #line)
        }
        
        /// Clear current error state
        func clearError() {
            currentError = nil
            showError = false
            errorPageModel = nil
        }
    }
}


