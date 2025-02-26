//
//  ViewModel.swift
//  lincride
//
//  Created by Adeoluwa on 26/02/2025.
//

import Foundation
import SwiftUI

extension SearchView {
    @Observable
    class SearchViewViewModel {
        var isEditing = false
        private(set) var locationIsSaved = false
        private(set) var savedLocations = [SearchSuggestion]()
        
        func savedSuggestedLocation(_ location: SearchSuggestion) {
            savedLocations.append(location)
        }
        func setLocationIsSaved(_ locationIsSaved: Bool) {
            self.locationIsSaved = locationIsSaved
        }
    }
}
