import Foundation

// MARK: - Error Page Model
/// Model for error pages
struct ErrorPageModel {
    let errorTitle: String
    let errorDescription: String
    let iconName: String
    let retryAction: (() -> Void)?
    let secondaryAction: (() -> Void)?
    let secondaryActionTitle: String?
    
    init(
        errorTitle: String,
        errorDescription: String,
        iconName: String,
        retryAction: (() -> Void)? = nil,
        secondaryAction: (() -> Void)? = nil,
        secondaryActionTitle: String? = nil
    ) {
        self.errorTitle = errorTitle
        self.errorDescription = errorDescription
        self.iconName = iconName
        self.retryAction = retryAction
        self.secondaryAction = secondaryAction
        self.secondaryActionTitle = secondaryActionTitle
    }
}

// MARK: - Error Page Factory
/// Factory for creating error pages from errors
struct ErrorPageFactory {
    
    static func makeErrorPage(
        from error: Error,
        retryAction: (() -> Void)? = nil,
        secondaryAction: (() -> Void)? = nil
    ) -> ErrorPageModel {
        
        // Handle different error types (Firefox pattern)
        switch error {
        case let locationError as LocationError:
            return makeLocationErrorPage(locationError, retryAction: retryAction, secondaryAction: secondaryAction)
            
        case let searchError as SearchError:
            return makeSearchErrorPage(searchError, retryAction: retryAction)
            
        case let databaseError as DatabaseError:
            return makeDatabaseErrorPage(databaseError, retryAction: retryAction)
            
        default:
            return makeGenericErrorPage(retryAction: retryAction)
        }
    }
    
    // MARK: - Specific Error Pages
    
    private static func makeLocationErrorPage(
        _ error: LocationError,
        retryAction: (() -> Void)?,
        secondaryAction: (() -> Void)?
    ) -> ErrorPageModel {
        switch error {
        case .permissionDenied:
            return ErrorPageModel(
                errorTitle: "Location Access Needed",
                errorDescription: "Linc needs your location to show nearby places and give directions.",
                iconName: "location.slash.fill",
                retryAction: nil,
                secondaryAction: secondaryAction,
                secondaryActionTitle: "Open Settings"
            )
            
        case .locationUnavailable:
            return ErrorPageModel(
                errorTitle: "Location Unavailable",
                errorDescription: "We can't get your location right now. Make sure Location Services are enabled.",
                iconName: "location.slash.circle.fill",
                retryAction: retryAction
            )
            
        case .locationUpdateFailed:
            return ErrorPageModel(
                errorTitle: "Location Update Failed",
                errorDescription: "There was a problem updating your location. Please try again.",
                iconName: "exclamationmark.triangle.fill",
                retryAction: retryAction
            )
        }
    }
    
    private static func makeSearchErrorPage(
        _ error: SearchError,
        retryAction: (() -> Void)?
    ) -> ErrorPageModel {
        switch error {
        case .networkUnavailable:
            return ErrorPageModel(
                errorTitle: "No Internet Connection",
                errorDescription: "Check your connection and try again.",
                iconName: "wifi.slash",
                retryAction: retryAction
            )
            
        case .searchFailed:
            return ErrorPageModel(
                errorTitle: "Search Failed",
                errorDescription: "Something went wrong while searching. Please try again.",
                iconName: "exclamationmark.magnifyingglass",
                retryAction: retryAction
            )
            
        case .noResultsFound:
            return ErrorPageModel(
                errorTitle: "No Results Found",
                errorDescription: "We couldn't find any locations matching your search. Try a different search term.",
                iconName: "mappin.slash",
                retryAction: nil
            )
            
        case .invalidQuery:
            return ErrorPageModel(
                errorTitle: "Invalid Search",
                errorDescription: "Please enter a valid location or place name.",
                iconName: "text.magnifyingglass",
                retryAction: nil
            )
        }
    }
    
    private static func makeDatabaseErrorPage(
        _ error: DatabaseError,
        retryAction: (() -> Void)?
    ) -> ErrorPageModel {
        switch error {
        case .saveFailed:
            return ErrorPageModel(
                errorTitle: "Save Failed",
                errorDescription: "We couldn't save this location. Please try again.",
                iconName: "bookmark.slash.fill",
                retryAction: retryAction
            )
            
        case .deleteFailed:
            return ErrorPageModel(
                errorTitle: "Delete Failed",
                errorDescription: "We couldn't delete this location. Please try again.",
                iconName: "trash.slash.fill",
                retryAction: retryAction
            )
            
        case .fetchFailed:
            return ErrorPageModel(
                errorTitle: "Load Failed",
                errorDescription: "We couldn't load your saved locations. Please try again.",
                iconName: "externaldrive.fill.badge.exclamationmark",
                retryAction: retryAction
            )
        }
    }
    
    private static func makeGenericErrorPage(
        retryAction: (() -> Void)?
    ) -> ErrorPageModel {
        return ErrorPageModel(
            errorTitle: "Something Went Wrong",
            errorDescription: "An unexpected error occurred. Please try again.",
            iconName: "exclamationmark.circle.fill",
            retryAction: retryAction
        )
    }
}
