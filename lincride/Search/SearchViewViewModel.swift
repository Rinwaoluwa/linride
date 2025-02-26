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
        private(set) var savedLocations = [String]()
        
        func savedSuggestedLocation(_ location: String) {
            savedLocations.append(location)
        }
        func setLocationIsSaved(_ locationIsSaved: Bool) {
            self.locationIsSaved = locationIsSaved
        }
    }
}
