import Foundation

// MARK: - Location Errors
/// Errors related to location services and permissions
/// Inspired by Firefox's domain-specific error pattern
enum LocationError: Error, LocalizedError, CustomStringConvertible {
    case permissionDenied
    case locationUnavailable
    case locationUpdateFailed
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Location access is needed to use LincRide"
        case .locationUnavailable:
            return "Unable to get your location"
        case .locationUpdateFailed:
            return "Location service error"
        }
    }
    
    var description: String {
        switch self {
        case .permissionDenied:
            return "LocationError.permissionDenied"
        case .locationUnavailable:
            return "LocationError.locationUnavailable"
        case .locationUpdateFailed:
            return "LocationError.locationUpdateFailed"
        }
    }
}

// MARK: - Search Errors
/// Errors related to map search operations
enum SearchError: Error, LocalizedError, CustomStringConvertible {
    case networkUnavailable
    case searchFailed(String)
    case noResultsFound
    case invalidQuery
    
    var errorDescription: String? {
        switch self {
        case .networkUnavailable:
            return "No internet connection"
        case .searchFailed(let reason):
            return "Search failed: \(reason)"
        case .noResultsFound:
            return "No locations found for your search"
        case .invalidQuery:
            return "Please enter a valid search"
        }
    }
    
    var description: String {
        switch self {
        case .networkUnavailable:
            return "SearchError.networkUnavailable"
        case .searchFailed(let reason):
            return "SearchError.searchFailed(\(reason))"
        case .noResultsFound:
            return "SearchError.noResultsFound"
        case .invalidQuery:
            return "SearchError.invalidQuery"
        }
    }
}

// MARK: - Database Errors
/// Errors related to CoreData operations
/// Follows Firefox's DatabaseError pattern
enum DatabaseError: Error, LocalizedError, CustomStringConvertible {
    case saveFailed(String)
    case deleteFailed(String)
    case fetchFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .saveFailed:
            return "Unable to save location"
        case .deleteFailed:
            return "Unable to delete location"
        case .fetchFailed:
            return "Unable to load saved locations"
        }
    }
    
    var description: String {
        switch self {
        case .saveFailed(let reason):
            return "DatabaseError.saveFailed(\(reason))"
        case .deleteFailed(let reason):
            return "DatabaseError.deleteFailed(\(reason))"
        case .fetchFailed(let reason):
            return "DatabaseError.fetchFailed(\(reason))"
        }
    }
}

// MARK: - General App Error
/// General application errors
/// Catchall for unexpected issues
enum AppError: Error, LocalizedError, CustomStringConvertible {
    case unknown(Error)
    case featureUnavailable
    
    var errorDescription: String? {
        switch self {
        case .unknown:
            return "Something went wrong. Please try again."
        case .featureUnavailable:
            return "This feature is currently unavailable"
        }
    }
    
    var description: String {
        switch self {
        case .unknown(let error):
            return "AppError.unknown(\(error.localizedDescription))"
        case .featureUnavailable:
            return "AppError.featureUnavailable"
        }
    }
}
